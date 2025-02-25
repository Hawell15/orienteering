class CompetitionsController < ApplicationController
  before_action :set_competition, only: %i[show edit update destroy group_clasa update_group_clasa group_ecn_coeficients set_ecn update_group_ecn_coeficients new_runners pdf ecn_csv set_wre_categories]

  # GET /competitions or /competitions.json
  def index
    @competitions = Competition.all

    @competitions = @competitions.where.not(wre_id: nil) if params[:wre]
    @competitions = @competitions.where(distance_type: params[:distance_type]) if params[:distance_type].present?
    if params[:country].present?
      @competitions = if params[:country] == 'Internationale'
                        @competitions.where.not(country: 'Moldova')
                      else
                        @competitions.where(country: params[:country])
                      end
    end

    if params[:date_from].present? || params[:date_to].present?
      date_from = Date.parse(params[:date_from]) if params[:date_from].presence
      date_to = Date.parse(params[:date_to]) if params[:date_to].presence
      @competitions = @competitions.where(date: date_from..date_to)
    end

    if params[:sort_by].present?
      direction = params[:direction] == 'desc' ? 'desc' : 'asc'
      @competitions = @competitions.order(params[:sort_by] => direction)
    end
    if params[:search].present?
      @competitions = @competitions.where(' LOWER(competition_name) LIKE :search',
                                          search: "%#{params[:search].downcase}%")
    end

    @competitions = @competitions.order(date: :desc).paginate(page: params[:page], per_page: 10)
  end

  # GET /competitions/1 or /competitions/1.json
  def show; end

  # GET /competitions/new
  def new
    @competition = Competition.new
  end

  def pdf
    respond_to do |format|
      format.html do
        html_string = ''
        html_string = "<div style='text-align: center;'><h1>#{@competition.competition_name}</h1></div>"
        html_string << "<div style='text-align: center;'><h2>#{@competition.date.strftime('%d.%m.%Y')}</h2></div>"
        html_string << "<div style='text-align: center;'><h2>Rezultate</h2></div>"

        @competition.groups.order(:group_name).each do |group|
          # Render the partial for each group and append it to the html_string with a page break
          html_string << render_to_string(partial: 'results/results_table2', locals: { group: })
          html_string << '<div style="page-break-before: always;"></div>'
        end

        # Generate PDF from the concatenated html_string
        pdf = WickedPdf.new.pdf_from_string(html_string)

        # Send the generated PDF as the response
        send_data pdf, filename: 'competition_results.pdf', type: 'application/pdf'
      end
    end
  end

  # GET /competitions/1/edit
  def edit; end

  # POST /competitions or /competitions.json
  def create
    respond_to do |format|
      parser = CompetitionFormParser.new(competition_params)
      @competition = parser.convert

      format.html { redirect_to competition_url(@competition), notice: 'Competitia a fost creata cu succes' }
      format.json { render :show, status: :created, location: @competition }
    end
  end

  # PATCH/PUT /competitions/1 or /competitions/1.json
  def update
    remove_groups
    add_groups

    respond_to do |format|
      if @competition.update(competition_params.except(:group_list))
        format.html { redirect_to competition_url(@competition), notice: 'Competitia a fost actualizata' }
        format.json { render :show, status: :ok, location: @competition }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @competition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /competitions/1 or /competitions/1.json
  def destroy
    @competition.destroy

    respond_to do |format|
      format.html { redirect_to competitions_url, notice: 'Competition was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def group_clasa; end

  def group_ecn_coeficients; end

  def update_group_clasa
    check_exprired_cagegories
    results = Result.joins(:group).where("group.competition_id": @competition.id).update_all(category_id: 10)

    @competition.update(group_clasa_params)

    @competition.groups.each do |group|
      next if group.results.blank?
      parser = if @competition.distance_type&.include?("Stafeta")
        RelayGroupCategoriesUpdater
      else
        GroupCategoriesUpdater
      end.new(group).get_rang_and_categories
    end

    redirect_to competition_url(@competition)
  end

   def set_wre_categories
    check_exprired_cagegories
    results = Result.joins(:group).where("group.competition_id": @competition.id)
    results.update_all(category_id: 10)
    results.each do |result|
      category_id = get_wre_category(result)
      ResultAndEntryProcessor.new({category_id: category_id}, result, nil, get_status(category_id, result.runner)).update_result
    end

    redirect_to competition_url(@competition)
  end

  def set_ecn
    @competition.update(ecn: !@competition.ecn)

    unless @competition.ecn
      @competition.groups.each do |group|
        group.ecn_coeficient = 0.0
        group.results.each do |result|
          result.ecn_points = 0.0
        end
      end
    end

    redirect_to competition_url(@competition)
  end

  def update_group_ecn_coeficients
    @competition.update(group_ecn_coeficients_params)

    @competition.groups.each do |group|
      next if group.ecn_coeficient.zero?

      winner_time = group.results.order(:place).first.time
      coeficient  = group.ecn_coeficient

      group.results.each do |result|
        ecn_points = (coeficient * winner_time / result.time * 100).round(2)
        ResultAndEntryProcessor.new( { ecn_points: ecn_points }, result ).update_result
      end
    end

    redirect_to competition_url(@competition)
  end

  def ecn_ranking
    respond_to do |format|
      format.html do
        @year = params[:year] || Time.now.year
        gender = params[:gender].presence || 'M'

        @runners = Runner.where(gender:).joins(:results)
                         .where('results.ecn_points > 0')
                         .where('extract(year  from date) = ?', @year)
                         .group('runners.id')
                         .order('SUM(results.ecn_points) DESC')
                         .select('runners.id, runners.runner_name, runners.surname, runners.dob, runners.club_id, runners.gender, SUM(results.ecn_points) AS total_points, COUNT(results.ecn_points) AS ecn_results_count,
                          RANK() OVER (ORDER BY SUM(results.ecn_points) DESC) AS place')
        @runners = @runners.select { |rn| rn.total_points > 0 }
      end

      format.json do
        limit = params[:size] || 20
        hash = {}
        data = ["M", "W"].each do |gender|
          runners = Runner.where(gender:).joins(:results, :club)
                         .where('results.ecn_points > 0')
                         .group('runners.id, clubs.club_name')
                         .order('SUM(results.ecn_points) DESC')
                         .select('runners.id, runners.runner_name, runners.surname, runners.dob, runners.club_id, runners.gender,
                          clubs.club_name,
                          ROUND(SUM(results.ecn_points)::numeric, 2) AS total_points, COUNT(results.ecn_points) AS ecn_results_count,
                          RANK() OVER (ORDER BY SUM(results.ecn_points) DESC) AS place').limit( limit)
            runner_gender = gender == "M" ? "Masculin" : "Femenin"
            hash[runner_gender] = runners
          end

        render json: hash
      end
    end
  end

  def new_runners
    @all_runners = Runner.all

    @runners = Runner.where(created_at: @competition.created_at..@competition.created_at + 10.minutes).includes(:club)
  end

  def ecn_csv
    csv_data = generate_competition_csv
    send_data csv_data, filename: "competition_results.csv", type: "text/csv"
  end

  def generate_competition_csv
    CSV.generate(col_sep: ",") do |csv|
    # Add the header rows
      csv << ["Denumirea Competiției", "", "", "", "", "", "", "", "Parola", "Lasm1177Unasm"]
      csv << [@competition.competition_name, "", "", "", "", "", "", "", "", ""]
      csv << ["Locație", "", "", "", "", "", "", "", "", ""]
      csv << [@competition.location, "", "", "", "", "", "", "", "", ""]
      csv << ["Data", "", "Tipul", "Trasator", "", "", "Organizator", "", "", ""]
      csv << [@competition.date, "", @competition.distance_type, "", "", "", "", "", "", ""]

      @competition.groups.each do |group|
        csv << ["", "", "", "", "", "", "", "", "", ""]

        csv << ["Categorie", group.group_name, "Lungime", "", "Nr. PC", "", "Coeficient", group.ecn_coeficient, "Campionat Național", "", ""]
        csv << ["ID", "Loc", "Nume, Prenume", "Cat. sportivă", "Rezultat", "Cat. îndeplinită", "Club", "Country", "", "", ""]
        group.results.each do |result|
         @default_category ||= Category.find(10)
          current_category = (result.runner.entries.select { |entry| entry["status"] == Entry::CONFIRMED  && entry["date"] < result.date }.sort_by(&:date).reverse.first&.category || @default_category).category_name

        csv << [result.runner.id, result.place, "#{result.runner.runner_name} #{result.runner.surname}", current_category, Time.at(result.time).utc.strftime('%H:%M:%S'), result.category.category_name, result.runner.club.club_name, "", "", "", ""]
      end
    end

    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_competition
    @competition = Competition.find(params[:id])
  end

  def add_groups
    return if competition_params[:group_list].blank?

    group_names = competition_params[:group_list].split(',').map(&:strip)
    Group.add_groups(group_names, @competition)
  end

  def remove_groups
    return if competition_params[:group_list].blank?

    group_names = @competition.groups.pluck(:group_name) - competition_params[:group_list].split(',').map(&:strip)
    Group.delete_groups(group_names, @competition)
  end

  # Only allow a list of trusted parameters through.
  def competition_params
    params.require(:competition).permit(:competition_name, :date, :location, :country, :distance_type, :wre_id, :checksum, :group_list, :size)
  end

  def group_clasa_params
    params.require(:competition).permit(groups_attributes: %i[id clasa])
  end

  def group_ecn_coeficients_params
    params.require(:competition).permit(groups_attributes: %i[id ecn_coeficient])
  end

  def check_exprired_cagegories
    Runner.where('category_valid < ?', @competition.date).each do |runner|
      category_id =  runner.category_id == 6 && (Date.today.year - runner.dob.year > 19) ? 10 : runner.category_id + 1
      ResultAndEntryProcessor.new({ runner_id: runner.id, category_id: category_id, date: runner.category_valid, group_id: 2}, nil, nil, Entry::CONFIRMED).add_result
    end
  end

  def get_wre_category(result)
    delta = result.date < "01.01.2024".to_date ? 50 : 0

    category_id = case result.wre_points
    when 700..899                       then 4
    when 900..(1049 + delta)            then 3
    when (1050 + delta)..(1249 + delta) then 2
    when (1250 + delta)..1500           then 1
    else 10
    end
  end

  def get_status(category_id, runner)
    return Entry::CONFIRMED if category_id > 3

    category_id < runner.best_category_id ? Entry::PENDING : Entry::CONFIRMED
  end

end

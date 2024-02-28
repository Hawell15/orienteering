class CompetitionsController < ApplicationController
  before_action :set_competition, only: %i[show edit update destroy group_clasa update_group_clasa group_ecn_coeficients set_ecn update_group_ecn_coeficients]

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

    @competitions = @competitions.paginate(page: params[:page], per_page: 10)
  end

  # GET /competitions/1 or /competitions/1.json
  def show; end

  # GET /competitions/new
  def new
    @competition = Competition.new
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
    @competition.update(group_clasa_params)

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
        result.update(ecn_points: (coeficient * winner_time/result.time * 100).round(2))
      end
    end

    redirect_to competition_url(@competition)
  end

  def ecn_ranking
    gender = params[:gender].presence || "M"

    @runners = Runner.where(gender: gender).joins(:results)
    .where("results.ecn_points > 0") # Add a where clause to filter results where ecn_points is greater than 0
    .group('runners.id')
    .order('SUM(results.ecn_points) DESC')
    .select('runners.*, SUM(results.ecn_points) AS total_points, COUNT(results.ecn_points) AS ecn_results_count')

      @runners = @runners.select { |rn| rn.total_points > 0 }
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
    params.require(:competition).permit(:competition_name, :date, :location, :country, :distance_type, :wre_id,
                                        :checksum, :group_list)
  end

  def group_clasa_params
    params.require(:competition).permit(groups_attributes: %i[id clasa])
  end

  def group_ecn_coeficients_params
    params.require(:competition).permit(groups_attributes: %i[id ecn_coeficient])
  end
end

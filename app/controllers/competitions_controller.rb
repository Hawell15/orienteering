class CompetitionsController < ApplicationController
  before_action :set_competition, only: %i[show edit update destroy]

  # GET /competitions or /competitions.json
  def index
    @competitions = Competition.paginate(page: params[:page], per_page: 10)
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
    date_params = competition_params.slice('date(1i)', 'date(2i)', 'date(3i)').values.map(&:to_i)
    date = Date.new(*date_params)

    @competition = Competition.find_competition(competition_params.to_h.merge(date:)) || Competition.new(competition_params.except(:group_list))

    respond_to do |format|
      if @competition.persisted?
        format.html { redirect_to competition_url(@competition), notice: 'Competitia cu aceste date deja exista' }
        format.json do
          render json: { error: 'Competition with these data already exists' }, status: :unprocessable_entity
        end
      elsif @competition.save
        add_groups

        format.html { redirect_to competition_url(@competition), notice: 'Competitia a fost creata cu succes' }
        format.json { render :show, status: :created, location: @competition }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @competition.errors, status: :unprocessable_entity }
      end
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
end

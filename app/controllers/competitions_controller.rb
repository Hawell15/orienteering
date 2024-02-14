class CompetitionsController < ApplicationController
  before_action :set_competition, only: %i[show edit update destroy group_clasa update_group_clasa]

  # GET /competitions or /competitions.json
  def index
    @competitions = if params[:wre]
       Competition.where.not(wre_id: nil)
    else
      Competition.all
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

  def group_clasa
  end

  def update_group_clasa
    @competition.update(group_clasa_params)

    redirect_to competition_url(@competition)
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
    params.require(:competition).permit(groups_attributes: [:id, :clasa])
  end

end

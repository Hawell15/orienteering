class GroupsController < ApplicationController
  before_action :set_group, only: %i[show edit update destroy count_rang]

  # GET /groups or /groups.json
  def index
    @groups = Group.all

    @groups = @groups.where(competition_id: params[:comp_id]) if params[:comp_id].present?

    if params[:date_from].present? || params[:date_to].present?
      date_from = Date.parse(params[:date_from]) if params[:date_from].presence
      date_to = Date.parse(params[:date_to]) if params[:date_to].presence
      @groups = @groups.joins(:competition).where('competition.date' => date_from..date_to)
    end
    @groups = @groups.paginate(page: params[:page], per_page: 10)

    if params[:sort_by].present?
      direction = params[:direction] == 'desc' ? 'desc' : 'asc'
      @groups = if %w[competition_name date].include?(params[:sort_by])
                  @groups.joins(:competition).order("competitions.#{params[:sort_by]} #{direction}")
                else
                  @groups.order(params[:sort_by] => direction)
                end
    end

    return unless params[:search].present?

    @groups = @groups.where('LOWER(group_name) LIKE :search',
                            search: "%#{params[:search].downcase}%")
  end

  # GET /groups/1 or /groups/1.json
  def show
    @results = filter_results({ group_id: @group.id, sort_by: "place", direction: "asc" }.merge(params.to_unsafe_h)).includes(:group, :category)
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit; end

  # POST /groups or /groups.json
  def create
    respond_to do |format|
      parser = GroupFormParser.new(group_params)
      @group = parser.convert

      format.html { redirect_to group_url(@group), notice: 'Group was successfully created.' }
      format.json { render :show, status: :created, location: @group }
    end
  end

  # PATCH/PUT /groups/1 or /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to group_url(@group), notice: 'Group was successfully updated.' }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1 or /groups/1.json
  def destroy
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url, notice: 'Group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def count_rang
    GroupCategoriesUpdater.new(@group).get_rang_and_categories

    redirect_to request.referer
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def group_params
    params.require(:group).permit(:group_name, :competition_id, :rang, :clasa,
                                  competition_attributes: %i[id competition_name date location country distance_type wre_id])
  end
end

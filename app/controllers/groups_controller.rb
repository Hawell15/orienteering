class GroupsController < ApplicationController
  before_action :set_group, only: %i[show edit update destroy count_rang]

  # GET /groups or /groups.json
  def index
    @groups = Group.all
    params[:date][:to] = '31/12/2999' if params[:date].present? && params.dig('date', 'to').blank?
    params[:date][:from] = '01/01/0000' if params[:date].present? && params.dig('date', 'from').blank?
    @groups = filter_groups(params.to_unsafe_h)

    @groups = @groups.paginate(page: params[:page], per_page: 20)
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
    if @group.competition.distance_type[/Stafeta/]
      RelayGroupCategoriesUpdater.new(@group).get_rang_and_categories
    else
      GroupCategoriesUpdater.new(@group).get_rang_and_categories
    end

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

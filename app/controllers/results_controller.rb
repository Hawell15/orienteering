class ResultsController < ApplicationController
  before_action :set_result, only: %i[show edit update destroy]

  # GET /results or /results.json
  def index
    @results = Result.all

    @results = @results.where(runner_id: params[:runner_id]) if params[:runner_id].present?

    if params[:competition_id].present?
      @results = @results.joins(:group).where('group.competition_id' => params[:competition_id])
    end

    @results = @results.where(category_id: params[:category_id]) if params[:category_id].present?
    @results = @results.where('wre_points > 0') if params[:wre]

    if params[:date_from].present? || params[:date_to].present?
      date_from = Date.parse(params[:date_from]) if params[:date_from].presence
      date_to   = Date.parse(params[:date_to]) if params[:date_to].presence
      @results  = @results.where(date: date_from..date_to)
    end

    if params[:sort_by].present?
      direction = params[:direction] == 'desc' ? 'desc' : 'asc'
      @results = if params[:sort_by] == 'runner_name'
                   @results.joins(:runner).order('runner_name' => direction, 'surname' => direction)
                 elsif params[:sort_by] == 'competition_name'
                   @results.joins(group: :competition).order("competitions.competition_name #{direction}")
                 elsif params[:sort_by] == 'group_name'
                   @results.joins(:group).order("groups.group_name #{direction}")
                 else
                   @results.order(params[:sort_by] => direction)
                 end
    end

    @results = @results.paginate(page: params[:page], per_page: 20)
  end

  # GET /results/1 or /results/1.json
  def show; end

  # GET /results/new
  def new
    @result = Result.new
  end

  def modal_new
    params_hash = params.to_unsafe_h.except('authenticity_token', 'controller', 'action', 'runner').to_hash
    redis = Redis.new(url: 'redis://localhost:6379/0')
    redis.hset('new_res', params['runner']['uuid'], params_hash.to_json)

    respond_to do |format|
      format.js { render 'close_modal' }
    end
  end

  # GET /results/1/edit
  def edit; end

  # POST /results or /results.json
  def create
    respond_to do |format|
      parser = ResultFormParser.new(result_params)
      @result = parser.convert

      format.html { redirect_to result_url(@result), notice: 'Result was successfully created.' }
      format.json { render :show, status: :created, location: @result }
    end
  end

  # PATCH/PUT /results/1 or /results/1.json
  def update
    respond_to do |format|
      if @result.update(params_for_results)
        format.html { redirect_to result_url(@result), notice: 'Result was successfully updated.' }
        format.json { render :show, status: :ok, location: @result }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /results/1 or /results/1.json
  def destroy
    @result.destroy

    respond_to do |format|
      format.html { redirect_to results_url, notice: 'Result was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_result
    @result = Result.find(params[:id])
  end

  def params_for_results
    res_params = result_params

    if %w[0 1].include?(res_params.dig('group_attributes', 'competition_id'))
      res_params['group_id'] = res_params.dig('group_attributes', 'competition_id')
      res_params.delete('group_attributes')
    else
      res_params.delete('date')
    end

    res_params.delete('group_attributes') unless res_params.dig('group_attributes', 'group_name')

    res_params
  end

  # Only allow a list of trusted parameters through.
  def result_params
    params.require(:result).permit(:place, :runner_id, :time, :category_id, :group_id, :wre_points, :date,
                                   group_attributes: [:id, :group_name, :competition_id, { competition_attributes: %i[id competition_name date location country distance_type wre_id] }])
  end
end

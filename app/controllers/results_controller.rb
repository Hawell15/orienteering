class ResultsController < ApplicationController
  before_action :set_result, only: %i[show edit update destroy]

  has_scope :runner_id
  has_scope :competition_id
  has_scope :category_id
  has_scope :wre, type: :boolean
  has_scope :date, using: %i[from to], type: :hash

  # GET /results or /results.json
  def index
    @results = filter_results(params.to_unsafe_h)
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
    redis = Redis.new(url: ENV['REDIS_URL'], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })

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
      if ResultAndEntryProcessor.new(params_for_results.to_h, @result).update_result
        request.referer[/\/competitions\/\d+/]
        format.html do
          redirect_uri = request.referer[/\/competitions\/\d+/] ? request.referer : result_url(@result)
          redirect_to redirect_uri, notice: 'Result was successfully updated.'
        end
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

  def from_competition
    result_time = convert_time(result_params[:time])
    result = ResultAndEntryProcessor.new(result_params.except(:time).merge(time: result_time).to_h).add_result
    redirect_to "#{request.referer}#menu#{result.group.group_name}"

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
    res_params["time"] = convert_time(res_params["time"])
    res_params
  end

  # Only allow a list of trusted parameters through.
  def result_params
    params.require(:result).permit(:place, :runner_id, :time, :category_id, :group_id, :wre_points, :ecn_points, :date,
                                   group_attributes: [:id, :group_name, :competition_id, { competition_attributes: %i[id competition_name date location country distance_type wre_id] }])
  end

    def convert_time(string)
    return string unless string[/:|\.|,/]

    seconds, minutes, hours = string.split(/:|\.|,/).map(&:to_i).reverse

    (hours || 0) * 3600 + minutes * 60 + seconds
  end
end

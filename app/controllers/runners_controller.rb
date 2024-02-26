class RunnersController < ApplicationController
  before_action :set_runner, only: %i[show edit update destroy]
  # has_scope :sorting, using: [:sorting, :direction]
  has_scope :club_id
  has_scope :category_id
  has_scope :best_category_id
  has_scope :gender
  has_scope :search
  has_scope :dob, using: %i[from to], type: :hash
  has_scope :wre, type: :boolean

  # GET /runners or /runners.json
  def index
    @runners = apply_scopes(Runner).all

    params[:dob][:to] = '31/12/2999' if params[:dob].present? && params.dig('dob', 'to').blank?
    params[:dob][:from] = '01/01/0000' if params[:dob].present? && params.dig('dob', 'from').blank?

    @runners = @runners.sorting(params[:sort_by], params[:direction]) if params[:sort_by]
    @runners = @runners.paginate(page: params[:page], per_page: 20)
  end

  # GET /runners/1 or /runners/1.json
  def show
    @results = @runner.results
    filtering_params = params.slice(:runner_id, :competition_id, :category_id, :wre, :sort_by, :date)
    filtering_params.each do |key, value|
      next if value.blank?

      @results = case key
      when "wre"     then @results.wre
      when "sort_by" then @results.sorting(value, params[:direction])
      when "date"     then @results.date(value[:from].presence, value[:to].presence)
      else @results.public_send(key, value)
      end
    end
  end

  # GET /runners/new
  def new
    @runner = Runner.new
  end

  # GET /runners/1/edit
  def edit; end

  # POST /runners or /runners.json
  def create
    respond_to do |format|
      parser = RunnerFormParser.new(runner_params)
      @runner = parser.convert
      add_result

      format.html { redirect_to runner_url(@runner), notice: 'Runner was successfully created.' }
      format.json { render :show, status: :created, location: @runner }
    end
  end

  # PATCH/PUT /runners/1 or /runners/1.json
  def update
    respond_to do |format|
      if @runner.update(runner_params)
        add_result

        format.html { redirect_to runner_url(@runner), notice: 'Runner was successfully updated.' }
        format.json { render :show, status: :ok, location: @runner }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @runner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /runners/1 or /runners/1.json
  def destroy
    @runner.destroy

    respond_to do |format|
      format.html { redirect_to runners_url, notice: 'Runner was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_runner
    @runner = Runner.find(params[:id])
  end

  def add_result
    redis = Redis.new(url: 'redis://localhost:6379/0')
    return unless (res_details = redis.hget('new_res', params.dig('runner', 'uuid')))

    redis.hdel('new_res', params.dig('runner', 'uuid'))
    result = ResultFormParser.new(JSON.parse(res_details).merge("runner_id": @runner.id, "category_id": @runner.category_id)).convert

    @runner.update!(category_valid: result.date + 2.years)
  end

  # Only allow a list of trusted parameters through.
  def runner_params
    params.require(:runner).permit(:id, :runner_name, :surname, :dob, :club_id, :gender, :wre_id, :best_category_id,
                                   :category_id, :category_valid, :sprint_wre_rang, :sprint_wre_place, :forest_wre_place, :forest_wre_rang, :checksum)
  end
end

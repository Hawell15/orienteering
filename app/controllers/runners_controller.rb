class RunnersController < ApplicationController
  before_action :set_runner, only: %i[show edit update destroy]

  # GET /runners or /runners.json
  def index
    @runners = Runner.all

    @runners = @runners.where.not(wre_id: nil)                             if params[:wre]
    @runners = @runners.where(club_id: params[:club_id])                   if params[:club_id].present?
    @runners = @runners.where(category_id: params[:category_id])           if params[:category_id].present?
    @runners = @runners.where(best_category_id: params[:best_category_id]) if params[:best_category_id].present?
    @runners = @runners.where(gender: params[:gender])                     if params[:gender].present?


  if params[:dob_from].present? || params[:dob_to].present?
    dob_from = Date.parse(params[:dob_from]) if params[:dob_from].presence
    dob_to = Date.parse(params[:dob_to]) if params[:dob_to].presence
    @runners = @runners.where(dob: dob_from..dob_to)
  end

    if params[:sort_by].present?
      direction = params[:direction] == 'desc' ? 'desc' : 'asc'
      @runners = if params[:sort_by] == "runner"
        @runners.order("runner_name" => direction, "surname" => direction)
      elsif params[:sort_by] == "club"
        @runners.joins(:club).order("clubs.club_name #{direction}")
      else
       @runners.order(params[:sort_by] => direction)
     end
   end

    @runners = @runners.where("runner_name LIKE :search OR surname LIKE :search OR (runner_name || ' ' || surname) LIKE :search OR (surname || ' ' || runner_name) LIKE :search", search: "%#{params[:search]}%") if params[:search].present?

    @runners = @runners.paginate(page: params[:page], per_page: 20)
  end

  # GET /runners/1 or /runners/1.json
  def show; end

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

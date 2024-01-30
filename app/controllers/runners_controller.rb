class RunnersController < ApplicationController
  before_action :set_runner, only: %i[show edit update destroy]

  # GET /runners or /runners.json
  def index
    @runners = Runner.all

    @runners = case params[:sort]
               when 'runner'
                 @runners.order(:runner_name, :surname)
               else
                 @runners.order(params[:sort])
               end

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
    @runner = Runner.new(runner_params)
    respond_to do |format|
      if @runner.save
        add_result
        format.html { redirect_to runner_url(@runner), notice: 'Runner was successfully created.' }
        format.json { render :show, status: :created, location: @runner }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @runner.errors, status: :unprocessable_entity }
      end
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
    result_params = params_for_results(res_details)
    Result.add_result(result_params)
    redis.hdel('new_res', params.dig('runner', 'uuid'))
  end

  def params_for_results(res_details)
    res_params =  JSON.parse(res_details)
    res_params["runner_id"] = @runner.id
    res_params["category_id"] = @runner.category_id



     if ["0", "1"].include?(res_params.dig("group_attributes", "competition_id"))
        res_params["date"] = "#{res_params['date(1i)']}-#{res_params['date(2i)']}-#{res_params['date(3i)']}"
        res_params["group_id"] = res_params.dig("group_attributes", "competition_id")
        res_params.delete("group_attributes")
      end

      res_params.delete("date(3i)")
      res_params.delete("date(2i)")
      res_params.delete("date(1i)")

      unless res_params.dig("group_attributes", "group_name")
        res_params.delete("group_attributes")
      end



      res_params
  end

  # Only allow a list of trusted parameters through.
  def runner_params
    params.require(:runner).permit(:id, :runner_name, :surname, :dob, :club_id, :gender, :wre_id, :best_category_id,
                                   :category_id, :category_valid, :sprint_wre_rang, :sprint_wre_place, :forest_wre_place, :forest_wre_rang, :checksum)
  end
end

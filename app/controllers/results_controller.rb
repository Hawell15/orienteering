class ResultsController < ApplicationController
  before_action :set_result, only: %i[ show edit update destroy ]

  # GET /results or /results.json
  def index
    @results = Result.paginate(page: params[:page], per_page: 20)
  end

  # GET /results/1 or /results/1.json
  def show
  end

  # GET /results/new
  def new
    @result = Result.new
  end

def modal_new
  params_hash = params.to_unsafe_h.except("authenticity_token", "controller", "action", "runner").to_hash
  redis = Redis.new(url: 'redis://localhost:6379/0')
  redis.hset("new_res", params["runner"]["uuid"], params_hash.to_json)

  respond_to do |format|
    format.js { render 'close_modal' }
  end
end
  # GET /results/1/edit
  def edit
  end

  # POST /results or /results.json
  def create
    @result = Result.new(params_for_results)

    respond_to do |format|
      if @result.save
        format.html { redirect_to result_url(@result), notice: "Result was successfully created." }
        format.json { render :show, status: :created, location: @result }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /results/1 or /results/1.json
  def update
    respond_to do |format|
      if @result.update(params_for_results)
        format.html { redirect_to result_url(@result), notice: "Result was successfully updated." }
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
      format.html { redirect_to results_url, notice: "Result was successfully destroyed." }
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

      if ["0", "1"].include?(res_params.dig("group_attributes", "competition_id"))
        res_params["group_id"] = res_params.dig("group_attributes", "competition_id")
        res_params.delete("group_attributes")
      else
        res_params.delete("date")
      end

      unless res_params.dig("group_attributes", "group_name")
        res_params.delete("group_attributes")
      end

      res_params
    end

    # Only allow a list of trusted parameters through.
    def result_params
      params.require(:result).permit(:place, :runner_id, :time, :category_id, :group_id, :wre_points, group_attributes: [:id, :group_name, :competition_id, competition_attributes: [:id, :competition_name, :date, :location, :country, :distance_type, :wre_id]])
    end
end

class RelayResultsController < ApplicationController
  before_action :set_relay_result, only: %i[ show edit update destroy ]

  # GET /relay_results or /relay_results.json
  def index
    @relay_results = RelayResult.all
  end

  # GET /relay_results/1 or /relay_results/1.json
  def show
  end

  # GET /relay_results/new
  def new
    @relay_result = RelayResult.new
  end

  # GET /relay_results/1/edit
  def edit
  end

  # POST /relay_results or /relay_results.json
  def create
    @relay_result = RelayResult.new(relay_result_params)

    respond_to do |format|
      if @relay_result.save
        format.html { redirect_to relay_result_url(@relay_result), notice: "Relay result was successfully created." }
        format.json { render :show, status: :created, location: @relay_result }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @relay_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /relay_results/1 or /relay_results/1.json
  def update
    respond_to do |format|
      if @relay_result.update(relay_result_params)
        format.html { redirect_to relay_result_url(@relay_result), notice: "Relay result was successfully updated." }
        format.json { render :show, status: :ok, location: @relay_result }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @relay_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /relay_results/1 or /relay_results/1.json
  def destroy
    @relay_result.destroy

    respond_to do |format|
      format.html { redirect_to relay_results_url, notice: "Relay result was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_relay_result
      @relay_result = RelayResult.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def relay_result_params
      params.require(:relay_result).permit(:place, :team, :time, :category_id, :group_id, :date, :results)
    end
end

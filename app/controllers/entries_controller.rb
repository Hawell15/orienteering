class EntriesController < ApplicationController
  before_action :set_entry,  only: %i[confirm reject pending edit update]

  # GET /entries or /entries.json
  def index
     @entries = if params[:status]
       Entry.where(status: params[:status])
    else
      Entry.where.not(status: "confirmed")
    end
  end

  def

  def edit; end

  def update
    respond_to do |format|
      if @entry.update(entry_params)
        format.html { redirect_to entries_path, notice: "Indeplinirea a fot actualizata" }
        format.json { render :show, status: :ok, location: @entry }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end


  # GET /entries/1 or /entries/1.json
  def confirm
    @entry.update(status: "confirmed")
    redirect_to entries_path, notice: "Indeplinirea confirmata"
  end

  def reject
    @entry.destroy
    redirect_to entries_path, notice: "Indeplinirea stearsa"
  end

  def pending
    @entry.update(status: "pending")
    redirect_to entries_path, notice: "Indeplinirea in asteptare"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entry
      @entry = Entry.find(params[:id])
    end

    def entry_params
      params.require(:entry).permit(:category_id, :runner_id, :result_id, :status, :date)
    end
end

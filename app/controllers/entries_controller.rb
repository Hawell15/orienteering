class EntriesController < ApplicationController
  before_action :set_entry,  only: [:confirm, :reject, :pending]

  # GET /entries or /entries.json
  def index
     @entries = if params[:status]
       Entry.where(status: params[:status])
    else
      Entry.all
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
end

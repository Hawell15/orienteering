class EntriesController < ApplicationController
  before_action :set_entry, only: %i[confirm reject pending edit update]

  has_scope :status, type: :array
  has_scope :runner_id
  has_scope :competition_id
  has_scope :from_competition_id
  has_scope :wre, type: :boolean
  has_scope :date, using: %i[from to], type: :hash

  # GET /entries or /entries.json
  def index
    params[:status] = %w[unconfirmed pending] unless params[:status].present?

    params[:date][:to] = '31/12/2999' if params[:date].present? && params.dig('date', 'to').blank?

    params[:date][:from] = '01/01/0000' if params[:date].present? && params.dig('date', 'from').blank?

    sort_options = {
      'runner_name' => 'runner_name, surname',
      'runner_category_id' => 'runners.category_id',
      'category_id' => 'entries.category_id',
      'status' => 'status',
      'competition_name' => 'competitions.competition_name',
      'wre_points' => 'wre_points',
      'date' => 'entries.date'
    }
    @entries = apply_scopes(Entry).all

    if params[:sort_by].present? && sort_options.key?(params[:sort_by])
      direction = params[:direction] == 'desc' ? 'desc' : 'asc'
      order_clause = sort_options[params[:sort_by]]
      @entries = @entries.joins(:runner, result: { group: :competition })
        .order(order_clause.split(',').map do |el|
          "#{el.strip} #{direction}"
        end.join(','))
    end

    @entries = @entries.includes(:runner, :category, result: { group: :competition })
  end

  def def(edit); end

  def update
    respond_to do |format|
      if @entry.update(entry_params)
        format.html { redirect_to entries_path, notice: 'Indeplinirea a fot actualizata' }
        format.json { render :show, status: :ok, location: @entry }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  def confirm
    @entry.update(status: 'confirmed')

    redirect_to request.referer, notice: 'Indeplinirea confirmata'
  end

  def reject
    if @entry.result.group_id == 1
      @entry.result.destroy
    else
      @entry.destroy
    end

    redirect_to request.referer, notice: 'Indeplinirea stearsa'
  end

  def pending
    @entry.update(status: 'pending')
    redirect_to request.referer, notice: 'Indeplinirea in asteptare'
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

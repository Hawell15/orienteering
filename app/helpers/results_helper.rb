module ResultsHelper
  def filter_results(params)
    params = params.with_indifferent_access
    results = Result.includes(runner: [entries: :category], category: [], group: { competition: [] })
    # results = results.order(date: :desc) unless params[:sort_by]

    filtering_params = params.slice(:runner_id, :group_id, :competition_id, :category_id, :wre, :sort_by, :date)

    filtering_params.each do |key, value|
      next if value.blank?
      results = case key
      when "wre"     then results.wre
      when "sort_by" then results.sorting(value, params[:direction])
      when "date"     then results.date(value[:from].presence, value[:to].presence)
      else results.public_send(key, value)
      end
    end

    results
  end
end

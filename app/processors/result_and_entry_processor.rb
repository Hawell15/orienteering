class ResultAndEntryProcessor
  def initialize(params = nil, result = nil, entry = nil, status = "unconfirmed")
    @params = params
    @result = result
    @entry  = entry
    @status = status
  end

   def add_result
    params = @params.with_indifferent_access

    check_params =
      {
        runner_id: params['runner_id'],
        group_id: params['group_id']
      }

    check_params.merge!(date: params['date']) if params['date']

    @result = Result.find_by(check_params)
    return result if result

    @result = Result.create!(params)
    add_entry
    result
  end

  def add_entry
    if should_create_entry?
      Entry.create!({
        result: result,
        date: result.date,
        category: result.category,
        runner: result.runner,
        status: status
      }.compact)
    end

    if result.category_id == 10 && check_three_results?(result.runner)
      Entry.create!({
        result: result,
        date: result.date,
        category_id: 9,
        runner: result.runner,
        status: "confirmed"
      }.compact)
    end
  end

  def update_result
    params = @params.with_indifferent_access

    result.update!(params)

    # if params.keys.any? { |key| ['runner_id', 'category_id', 'date'].include?(key) }
      result.entry&.destroy
      add_entry
    # end
    result
  end

  private

  def should_create_entry?
    return false if result.category_id == 10
    return true  if result.group_id == 2
    return true  if result.category_id < result.runner.category_id
    return true  if result.category_id == result.runner.category_id && result.date + result.category.validaty_period.years > result.runner.category_valid

    false
  end

  def check_three_results?(runner)
    return false if result.date < "2024-03-25".to_date
    return false unless runner.category_id > 8
    return false unless runner.junior_runner?

    results = runner.results.where(date: "2024-03-25".to_date .. result.date)

    return false if results.count < 3

    true
  end

  def result
    @result
  end

  def status
    @status
  end

  def entry
    @entry
  end
end

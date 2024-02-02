class RunnerFormParser < BaseParser
  attr_accessor :params, :hash

  def initialize(params)
    @params        = params
    @hash          = {}
    @return_data   = "runner"
    @return_result = nil
  end

  def convert
    json = @params.to_hash.compact.reject { |_, v| v.empty? }
    extract_competition_details(json)

    parser(@hash)
    @return_result
  end

  def extract_competition_details(params)
    @hash = {
      groups: extract_groups_details(params)
    }
  end

  def extract_groups_details(params)
    [results: extract_results(params)]

  end

  def  extract_results(params)
    [runner: extract_runner(params)]
  end

  def extract_runner(params)
    if params["dob(1i)"]
      date_params = params.slice('dob(1i)', 'dob(2i)', 'dob(3i)').values.map(&:to_i)
      date        = Date.new(*date_params).as_json
    end

    {
      runner_name:      params["runner_name"],
      surname:          params["surname"],
      dob:              date,
      gender:           params["gender"],
      category_id:      params["category_id"],
      best_category_id: params["best_category_id"],
      club_id:          params["club_id"],
      wre_id:           params["wre_id"]
    }.compact
  end

end

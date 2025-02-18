class ResultFormParser < BaseParser
  attr_accessor :params, :hash

  def initialize(params)
    @params        = params
    @hash          = {}
    @return_data   = "result"
    @return_result = nil
  end

  def convert
    json = @params.to_hash.compact.reject { |_, v| v.blank? }.with_indifferent_access
    extract_competition_details(json)
    parser(@hash)
    @return_result
  end

  def extract_competition_details(params)

    json = params["group_attributes"].slice("competition_id").merge(params["group_attributes"]["competition_attributes"]&.to_h || {}).compact.reject { |_, v| v.blank? }

    if json["date(1i)"]
      date_params = json.slice('date(1i)', 'date(2i)', 'date(3i)').values.map(&:to_i)
      date        = Date.new(*date_params).as_json
    end


    @hash = {
      competition_id:   json["competition_id"],
      competition_name: json["competition_name"],
      date:             date,
      distance_type:    json["distance_type"],
      location:         json["location"],
      country:          json["country"],
      wre_id:           json["wre_id"],
      groups:           extract_groups_details(params)
    }.compact
  end

  def extract_groups_details(params)
    json = params["group_attributes"]

    if (params["group_id"]  = ["1", "2"].detect { |id| id == params.dig("group_attributes", "competition_id") })
    end

    [{
      group_name: json["group_name"],
      rang:       json["rang"],
      clasa:      json["clasa"],
      group_id:   params["group_id"],
      results:    extract_results(params)
    }.compact]
  end

  def  extract_results(json)
    if json["date(1i)"] && ["1", "2"].include?(params.dig("group_attributes", "competition_id"))
      date_params = json.slice('date(1i)', 'date(2i)', 'date(3i)').values.map(&:to_i)
      date        = Date.new(*date_params).as_json
    end

    [{
        place:       json["place"],
        time:        json["time"],
        runner_id:   json["runner_id"],
        category_id: json["category_id"],
        wre_points:  json["wre_points"],
        date:        date,
        status:      Entry::CONFIRMED
    }.compact]
  end

end

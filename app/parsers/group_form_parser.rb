class GroupFormParser < BaseParser
  attr_accessor :params, :hash

  def initialize(params)
    @params        = params
    @hash          = {}
    @return_data   = "group"
    @return_result = nil
  end

  def convert
    json = @params.to_hash.compact.reject { |_, v| v.empty? }
    extract_competition_details(json)
    parser(@hash)
    @return_result
  end

  def extract_competition_details(params)
    json = params.slice("competition_id").merge(params["competition_attributes"]&.to_h || {})

    if json["date(1i)"]
      date_params = json.slice('date(1i)', 'date(2i)', 'date(3i)').values.map(&:to_i)
      date        = Date.new(*date_params).as_json
    end

    @hash = {
      competition_id:   json["competition_id"],
      competition_name: json["competition_name"],
      date:             date.as_json,
      distance_type:    json["distance_type"],
      location:         json["location"],
      country:          json["country"],
      wre_id:           json["wre_id"],
      groups:           extract_groups_details(params)
    }.compact
  end

  def extract_groups_details(json)
    [{
      group_name: json["group_name"],
      rang:       json["rang"],
      clasa:      json["clasa"]
    }]
  end
end

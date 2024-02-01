class FormParser < BaseParser
  attr_accessor :params, :hash

  def initialize(params, return_data)
    @params        = params
    @hash          = {}
    @return_data   = return_data
    @return_result = nil
  end

  def convert
    json = @params.to_hash
    extract_competition_details(json)
    parser(@hash)
    @return_result
  end

  def extract_competition_details(json)
    date_params = json.slice('date(1i)', 'date(2i)', 'date(3i)').values.map(&:to_i)
    date        = Date.new(*date_params)

    @hash = {
      competition_name: json["competition_name"],
      date:             date.as_json,
      distance_type:    json["distance_type"],
      location:         json["location"],
      country:          json["country"],
      wre_id:           json["wre_id"],
      groups:           extract_groups_details(json["group_list"])
    }
  end

  def extract_groups_details(json)
    json.split(',').map(&:strip).map do |group_details|
      { group_name: group_details }
    end
  end
end

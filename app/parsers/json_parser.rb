class JsonParser < BaseParser
  attr_accessor :file, :hash

  def initialize(path)
    @path = path
    @hash = {}
  end

  def convert
    json = JSON.parse(File.read(@path))
    extract_competition_details(json)
    parser(@hash)
  end

  def extract_competition_details(json)
    @hash = {
      competition_name: json["title"],
      date:             json["date"].to_date.as_json,
      distance_type:    json["groups"].first["distance_type"],
      groups:           extract_groups_details(json["groups"])
    }

  end

  def extract_groups_details(json)
    json.map do |group|
      {
        group_name: group["name"],
        clasa:      convert_group_class(group["distance_class"]),
        results:    extract_results(group["results"], extract_gender(group["name"].first))
      }
    end
  end

  def extract_results(json, gender)
    json.map do |result|
      next if result.blank?
      {
        place:  result["place"],
        time:   convert_time(result["time"]),
        runner: extract_runner(result, gender)
      }
    end
  end

  def extract_runner(result, gender)
    runner_name, surname = result["runner_name"].split(" ", 2)
    current_category     = convert_category(result["currenct_category"])

    {
      runner_name:      runner_name,
      surname:          surname,
      dob:              convert_dob(result["date_of_birth"]),
      gender:           gender,
      category_id:      current_category,
      best_category_id: current_category,
      club:             result["club"]
    }.compact
  end

  def extract_runner_id(runner_id)
    return unless runner_id
    runner_id.to_i.zero? ? false : true

  end

  def convert_dob(string)
    string = Time.now.beginning_of_year if string == "Null"
    string.to_date.as_json
  end
end

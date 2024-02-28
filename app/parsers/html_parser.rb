class HtmlParser < BaseParser
  attr_accessor :file, :hash

  def initialize(path)
    @path          = path
    @hash          = {}
    @return_data   = "competition"
    @return_result = nil
  end

  def convert
    html = Nokogiri::HTML(File.read(@path))
    json = JSON.parse(html.at_css("div#content script").text.sub("\n    var race = ", "").split("\;").first)

    extract_competition_details(json)

    parser(@hash)
    @return_result
  end

  def extract_competition_details(json)
    @hash = {
      competition_name: json.dig('data', 'title'),
      date:             json.dig('data', 'start_datetime').to_date.as_json,
      distance_type:    json.dig('data', 'description').strip,
      groups:           extract_groups_details(json)
    }

  end

  def extract_groups_details(json)
    json["groups"].map do |group|
      {
        group_name: group['name'],
        results:    extract_results(json, extract_gender(group["name"].first), group)
      }
    end
  end

  def extract_results(json, gender, group)
    json['persons'].select { |pers| pers['group_id'] == group['id'] }.map do |runner|
      result = json['results'].detect { |res| res['person_id'] == runner['id'] }
      next if result.nil? || result['place'].to_i < 1 || runner.blank?

      {
        place:  result['place'],
        time:   result['result_msec'] / 1000,
        runner: extract_runner(runner, gender, json)
      }
    rescue
      byebug
    end
  end

  def extract_runner(runner, gender, json)
    current_category     = convert_category(runner['qual'])
    club = json['organizations'].detect { |org| org['id'] == runner['organization_id'] }['name']

    {
      runner_name: runner['surname'],
      surname:     runner['name'],
      dob:         runner['birth_date'] || "0000-01-01",
      gender:      gender,
      category_id: current_category,
      club:        club,
      date:        (json.dig('data', 'start_datetime').to_date - 1.day).as_json
    }.compact
  end

  def convert_category(category_id)
    case category_id
    when 9 then 1
    when 8 then 2
    when 7 then 3
    when 6 then 6
    when 5 then 5
    when 4 then 4
    when 3 then 9
    when 2 then 8
    when 1 then 7
    when 0 then 10
    end
  end
end

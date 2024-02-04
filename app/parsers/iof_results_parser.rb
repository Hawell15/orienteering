class IofResultsParser < BaseParser
  require 'net/http'

  attr_accessor :hash

  def initialize
    @hash          = {}
    @return_data   = nil
    @return_result = nil
  end

  def convert
    data = get_data
    extract_competition_details(data)

    @hash.each { |comp| parser(comp)}
    # parser(@hash)
  end

  def extract_competition_details(json)
    @hash = json.map { |js| js.slice("raceDate", "raceName", "raceId", "raceFormat") }.uniq.map do |competition|
      {
        competition_name: competition["raceName"],
        date:             competition["raceDate"].to_date.as_json,
        distance_type:    competition["raceFormat"],
        wre_id:           competition["raceId"],
        groups:           extract_groups_details(json.select { |js| js["raceId"] == competition["raceId"]})
      }
    end.compact
  end

  def extract_groups_details(json)
    json.pluck("gender").uniq.map do |group|
      {
        group_name: "#{group.first.upcase}21E",
        results:  extract_results(json.select { |js| js["gender"] == group })
      }
    end
  end

  def extract_results(json)
    json.map do |result|
      next if result["rank"].zero?

      {
        place:      result["rank"],
        time:       convert_time(result["result"]),
        wre_points: result["points"].to_i,
        runner_id:  result["runner_id"]
      }
    end.compact
  end

  def add_runners(hash)
    runner = super(hash.except(:sprint_wre_rang, :forest_wre_rang, :sprint_wre_place, :forest_wre_place))
    update_wre_data(runner, hash)
    runner
  end

  def extract_runner_details(runner)
    {
      runner_name:      runner["Last Name"],
      surname:          runner["First Name"],
      dob:              runner["dob"],
      gender:           runner["Gender"],
      club_id:          0,
      sprint_wre_rang:  runner["Sprint WRS points"],
      forest_wre_rang:  runner["WRS points"],
      sprint_wre_place: runner["Sprint WRS Position"],
      forest_wre_place: runner["WRS Position"],
      wre_id:           runner["IOF ID"]
    }.compact
  end

  def get_data
    runners_with_wre_id = Runner.where.not(wre_id: nil).select(:id, :wre_id, :gender)

    runners_with_wre_id.map do |runner|
      get_runner_results(runner)
    end.flatten
  end

  def get_runner_results(runner)
    ["F", "FS"].map do |distance_type|
      json = JSON.parse(Net::HTTP.get(URI("https://ranking.orienteering.org/api/person/#{runner.wre_id}/results/#{distance_type}")))
      json.each do |hash|
        hash["gender"] = runner.gender
        hash["runner_wre_id"] = runner.wre_id
        hash["runner_id"] = runner.id
      end
    end.flatten
  end

  def get_dob
    url = URI("https://eventor.orienteering.org/Athletes")

    https = Net::HTTP.new(URI("https://eventor.orienteering.org/Athletes").host, url.port)
    https.use_ssl = true
    response = Nokogiri::HTML(https.post(url, 'CountryId=498&MaxNumberOfResults=500').body)

    dob_hash = {}

    response.at_css("div#athleteList tbody").css("tr").each do |tr|
      dob_hash["#{tr.at_css("td").text}"] = tr.css("td")[2].text.presence || Time.now.year
    end
    dob_hash
  end

  def merge_data(forest_data, sprint_data)
    runners_array = forest_data

    sprint_data.each do |data|
      if (detected_hash = runners_array.detect { |runner| runner["IOF ID"] == data["IOF ID"]})
        detected_hash.merge!(data)
      else
        runners_array << data
      end
    end
    runners_array
  end

  def update_wre_data(runner, hash)
    runner.update!(hash.slice(:wre_id, :sprint_wre_rang, :forest_wre_rang, :sprint_wre_place, :forest_wre_place))

  end


end

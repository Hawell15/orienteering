class RunnersParser
  def initialize(path)
    @path          = path
  end

  def convert
    html = Nokogiri::HTML(File.read(@path))
    json = JSON.parse(html.at_css("div#content script").text.sub("\n    var race = ", "").split("\;").first)
    extract_runners(json)
  end

  def extract_runners(json)
    runners = json['persons'].map { |h| h.slice("name", "surname", "birth_date") }
    aaa = runners.map do |runner|
      rn = Runner.find_by(
        runner_name: Runner.convert_from_russian(runner['surname']),
        surname: Runner.convert_from_russian(runner["name"])
      )
      next unless rn
      next unless rn.dob == "0000-01-01".to_date
      rn.update!(dob: runner["birth_date"])
    end.compact
  end

  def self.get_dob_from_group
    Runner.where(dob: "01-01-000".to_date).each do |runner|
      results = runner.results
      min_age = results.map { |res| res.group.group_name[/\d+/].to_i }.min

      next if !min_age || min_age > 18 || min_age == 0

      filtered_results = results.select { |res| res.group.group_name[/\d+/].to_i == min_age }
      max_year = filtered_results.map { |res| res.group.competition.date.year }.max
      dob_year = max_year - min_age

      runner.update(dob: "31-12-#{dob_year}".to_date)
    end

  end
end


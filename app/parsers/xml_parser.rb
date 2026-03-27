# frozen_string_literal: true

class XmlParser
  def initialize(path)
    @path = path
  end

  def convert
    doc = Nokogiri::XML(File.read(@path))

    ns = {
      'iof' => 'http://www.orienteering.org/datastandard/3.0',
      'orgeo' => 'http://orgeo.ru/iof-xml-extensions/3.0'
    }
    current_ranking = ranking_ecn
    doc.xpath('//iof:PersonEntry', ns).each do |entry|
      runner_name = Runner.convert_from_russian(entry.at_xpath('.//iof:Person/iof:Name/iof:Family', ns)&.text)
      surname     =  Runner.convert_from_russian(entry.at_xpath('.//iof:Person/iof:Name/iof:Given', ns)&.text)
      dob         =  entry.at_xpath('.//iof:Person/iof:BirthDate', ns)&.text
      gender      =  entry.at_xpath('.//iof:Person', ns)&.[]('sex')&.sub('F', 'W')

      runner_params = {
        runner_name:,
        surname:,
        dob:,
        gender:
      }

      runner = Runner.find_by(checksum: Runner.get_checksum(runner_name, surname, dob,
                                                            gender)) || Runner.get_runner_by_matching(runner_params)

      next unless runner

      ranking = current_ranking[runner.id]
      next unless ranking

      ranking += 1000 if gender == 'W'

      bib_node = entry.at_xpath('.//orgeo:BibNumber', ns)
      bib_node.content = ranking
    end

    doc.to_xml(encoding: 'UTF-8')
  end

  def ranking_ecn
    from_date = 365.days.ago.to_date
    limit_number = Competition
                   .where(ecn: true)
                   .where('competitions.date >= ?', from_date)
                   .count - 4
    hash = {}

    %w[M W].each do |gender|
      subquery = Result.select(
        'results.*, ROW_NUMBER() OVER (PARTITION BY runner_id ORDER BY ecn_points DESC) AS rn'
      ).where('results.ecn_points > 0').where('results.date >= ?', from_date)

      runners = Runner.where(gender:)
                      .joins("JOIN (#{subquery.to_sql}) AS best_results ON best_results.runner_id = runners.id AND best_results.rn <= #{limit_number}")
                      .group('runners.id')
                      .select(<<~SQL)
                        runners.id,
                        SUM(best_results.ecn_points) AS total_points,
                        COUNT(best_results.ecn_points) AS ecn_results_count,
                         RANK() OVER (ORDER BY SUM(best_results.ecn_points) DESC) AS place
                      SQL
                      .order('total_points DESC').as_json

      runners.map { |runner| hash[runner['id']] = runner['place'] }
    end

    hash
  end
end

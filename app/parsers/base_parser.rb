class BaseParser
  attr_accessor :return_data, :return_result

  def parser(hash)
    add_competition(hash)
  end

  def add_competition(hash)
    if hash.except(:groups).present?
      competition = Competition.add_competition(hash.except(:groups))
    end
    add_groups(hash[:groups], competition)
    @return_result = competition if @return_data == "competition"
  end

  def add_groups(hash, competition)
    hash.each do |group_hash|
      if [group_hash.except(:results), competition].any?(&:present?)
        group = Group.add_group(group_hash.merge(competition_id: competition.id).except(:results))
      end
      @return_result = group if @return_data == "group"
      add_result(group_hash[:results], group)
    end
  end

  def add_runners(hash)
    return unless hash

    club_id = hash[:club_id] || Club.add_club({ club_name: hash[:club] }).id

    runner = Runner.add_runner(hash.merge(club_id: club_id).except(:club))
    @return_result = runner if @return_data == "runner"

    runner
  end

  def add_result(hash, group)
    return unless hash

    hash.each do |result_hash|
      next unless result_hash

      status = "unconfirmed"
      status = result_hash[:status] || status

      runner_id = result_hash[:runner_id] || add_runners(result_hash[:runner]).id
      if result_hash.except(:runner).present?
        result    = Result.add_result(result_hash.merge({ runner_id: runner_id, group_id: group.id }).except(:runner, :status), status)
      end

      @return_result = result if @return_data == "result"
    end
  end

  private

  def convert_group_class(string)
    case string
    when /juniori/         then 'Juniori'
    when /(c|с)ategoria I/ then 'Seniori'
    when /CMSRM/           then 'CMSRM'
    when /MSRM/            then 'MSRM'
    else 'Fara Categorii'
    end
  end

  def convert_time(string)
    seconds, minutes, hours = string.split(/:|\.|,/).map(&:to_i).reverse

    (hours || 0) * 3600 + minutes * 60 + seconds
  end

  def extract_gender(string)
    case string.downcase
    when 'm', 'men'                   then 'M'
    when 'w', 'women', 'f', 'feminin' then 'W'
    end
  end

  def convert_category(string)
    string.gsub!('І', 'I') # NOTE: from Ukranian I to English
    string.gsub!('-u', ' j')
    string.gsub!('Ij', 'I j')
    string.gsub!(/MS$/, 'MSRM')

    string = case string
             when 'BR'    then 'f/c'
             when 'KMSRM' then 'CMSRM'
             else string
             end

    Category.find_by(category_name: string)
  end

  def detect_gender(string)
    case string
    when "Nichita", "Ilia", "Mircea" then "M"
    when "Irene", /a$/i then "F"
    else "M"
    end
  end
end

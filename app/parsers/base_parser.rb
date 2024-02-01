class BaseParser
  def parser(hash)
    add_competition(hash)
  end

  def add_competition(hash)
    competition = Competition.add_competition(hash.except(:groups))
    add_groups(hash[:groups], competition)
  end

  def add_groups(hash, competition)

    hash.each do |group_hash|
      group = Group.add_group(group_hash.merge(competition_id: competition.id).except(:results))
      add_result(group_hash[:results], group)
    end
  end

  def add_runners(hash)
    club  = Club.add_club({ club_name: hash[:club] })
    Runner.add_runner(hash.merge(club_id: club.id).except(:club))
  end

  def add_result(hash, group)
    hash.each do |result_hash|
      next unless result_hash

      runner = add_runners(result_hash[:runner])
      Result.add_result(result_hash.merge({ runner_id: runner.id, group_id: group.id }).except(:runner))
    rescue
    end

  end

  private

  def convert_group_class(string)
    case string
    when /juniori/         then "Juniori"
    when /(c|с)ategoria I/ then "Seniori"
    when /CMSRM/           then "CMSRM"
    when /MSRM/            then "MSRM"
    else "Fara Categorii"
    end
  end

  def convert_time(string)
    hours, minutes, seconds    = string.split(/:|\.|,/).map(&:to_i)

    hours * 3600 + minutes * 60 + seconds
  end

  def extract_gender(string)
    case string.downcase
    when "m", "men"                   then "M"
    when "w", "women", "f", "feminin" then "W"
    end
  end

  def convert_category(string)
    string.gsub!("І", "I") # NOTE: from Ukranian I to English
    string.gsub!("-u", " j")
    string.gsub!("Ij", "I j")
    string.gsub!("S", "SRM")


    string = case string
    when "BR"    then "f/c"
    when "KMSRM" then "CMSRM"
    end

    Category.find_by(category_name: string)

  end
end

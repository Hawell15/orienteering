class RelayHtmlParser < HtmlParser
  def add_relay_result(group)
    group.results.group_by(&:place).values.each do |relay_result|
      results_id = relay_result.pluck("id").compact
      next if results_id.count.zero?
      unless results_id.count == results_count(group)
        Result.where(id: results_id).map(&:destroy)
        next
      end
      team = @hash[:groups].detect { |gr|gr[:group_name].delete(" ") == group.group_name }[:results].compact.detect { |res| res[:place] == relay_result.first[:place] }[:runner][:club]

      RelayResult.find_or_create_by!(
        place:       relay_result.first.place,
        time:        relay_result.pluck("time").sum,
        team:        team,
        category_id: 10,
        group_id:    group.id,
        results_id:  relay_result.pluck("id")
        )
    end
  end

  def check_result?(result)
    result.match?(/\d{2}:\d{2}:\d{2}/)
  end

  def results_count(group)
    group.competition.distance_type == "Stafeta" ? 3 : 4
  end

  def extract_groups_details(json)
    json["groups"].reject { |group| group["name"][/complimentare/i] }.map do |group|

      {
        group_name: group['name'].delete(" "),
        results:    extract_results(json, extract_gender(group["name"].first), group)
      }
    end
  end

  def distance_type(_json)
    "Sprint Stafeta"
  end
end

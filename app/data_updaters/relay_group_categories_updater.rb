class RelayGroupCategoriesUpdater < GroupCategoriesUpdater
  def winner_time
    @winner_time ||= @group.relay_results.order(:place).first.time
  end

  def main_results
    @main_results ||= @group.relay_results.order(:place)
  end

  def update_result_category(res, category_id)
    Result.where(id: res.results_id).each do |result|
      status = get_status(res, category_id)

      ResultAndEntryProcessor.new({category_id: category_id}, result, nil, status).update_result
    end
  end

  def rang_results
    Result.where(id: main_results.first(relay_team_count).pluck("results_id").flatten)
  end

  def set_junior_category?(res)
     Result.where(id: res.results_id).all? { |res| res.runner.junior_runner? }
  end

  def min_results_size
    2
  end

  def relay_team_count
    @group.competition.distance_type == "Sprint Stafeta" ? 3 : 4
  end
end

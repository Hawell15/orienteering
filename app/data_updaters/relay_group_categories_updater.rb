class RelayGroupCategoriesUpdater < GroupCategoriesUpdater
  def winner_time
    @winner_time ||= @group.relay_results.order(:place).first.time
  end

  def main_results
    @main_results ||= @group.relay_results.order(:place)
  end

  def update_result_category(res, time_hash)
    category_id = super

    Result.where(id: res.results_id).update_all(category_id: category_id)
  end

  def rang_results
    Result.where(id: main_results.first(4).pluck("results_id").flatten)
  end

  def set_junior_category?(res)
     Result.where(id: res.results_id).all? { |res| res.runner.junior_runner? }
  end

  def min_results_size
    2
  end
end

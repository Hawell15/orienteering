class ExpireCategoryJob < ApplicationJob
  queue_as :default

  def perform(*args)

    Runner.where('category_valid < ?', Date.today).each do |runner|
      Result.add_result({ runner_id: runner.id, category_id: runner.category_id + 1, date: runner.category_valid, group_id: 2}, "confirmed")
    end
  end
end

class ExpireCategoryJob < ApplicationJob
  queue_as :default

  def perform(*args)

    Runner.where('category_valid < ?', Date.today).each do |runner|
      category_id =  runner.category_id == 6 && (Date.today.year - runner.dob.year > 19) ? 10 : runner.category_id + 1
      ResultAndEntryProcessor.new({ runner_id: runner.id, category_id: category_id, date: runner.category_valid, group_id: 2}, "confirmed").add_result
    end
  end
end

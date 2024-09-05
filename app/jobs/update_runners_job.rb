class UpdateRunnersJob < ApplicationJob
  queue_as :default
  include RunnersHelper

  def perform(*args)
    Runner.all.each do |runner|
      runner.update_runner_category
    end
  end
end

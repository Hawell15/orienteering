class IofResultsJob < ApplicationJob
  queue_as :default

  def perform
    parser = IofResultsParser.new
    parser.convert
    TelegramMessageJob.perform_now
  end
end

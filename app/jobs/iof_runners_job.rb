class IofRunnersJob < ApplicationJob
  queue_as :default

  def perform
    parser = IofRunnersParser.new
    parser.convert
    TelegramMessageJob.perform_now
  end
end

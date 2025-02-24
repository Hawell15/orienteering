class IofResultsJob < ApplicationJob
  queue_as :default

  def perform
    parser = IofResultsParser.new
    parser.convert
    NotifyTelegramJob.perform_now("Descarcarea rezultatelor IOF s-a finisat")
  end
end

class IofRunnersJob < ApplicationJob
  queue_as :default

  def perform
    parser = IofRunnersParser.new
    parser.convert
    NotifyTelegramJob.perform_now("Actualizarea datelor sportivilor IOF s-a finisat")
  end
end

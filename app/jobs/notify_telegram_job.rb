require 'telegram/bot'

class NotifyTelegramJob < ApplicationJob
  queue_as :default

  def perform(message)
    # Telegram::Bot::Client.run(ENV['TELEGRAM_TOKEN']) do |bot|
      # bot.api.send_message(chat_id: "-1002114647707", text: message)
    # end
  end
end

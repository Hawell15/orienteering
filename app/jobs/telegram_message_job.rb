require 'telegram/bot'

class TelegramMessageJob < ApplicationJob
  queue_as :default

  def perform
    # Telegram::Bot::Client.run(ENV['TELEGRAM_TOKEN']) do |bot|
      # bot.api.send_message(chat_id: "-1002114647707", text: Time.now)
    # end
  end
end

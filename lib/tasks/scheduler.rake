task :message_telegram => :environment do
  TelegramMessageJob.perform_now
end

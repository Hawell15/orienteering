every 11.minute do
  runner "TelegramMessageJob.perform_now"
end

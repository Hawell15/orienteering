every 1.minute do
  runner "TelegramMessageJob.perform_now"
end

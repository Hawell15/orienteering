task :iof_runners => :environment do
  IofRunnersJob.perform_now
end

task :iof_results => :environment do
  IofResultsJob.perform_now
end

task :expire_categories => :environment do
  ExpireCategoryJob.perform_now
  NotifyTelegramJob.perform_now("Verificarea categorii expirate s-a finisat")
end


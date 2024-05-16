class UpdateRunnersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Runner.all.each do |runner|
      entry = Entry.where(runner_id: runner.id).where(status: "confirmed").where('date < ?', (Time.now + 1.day).to_date ).order(date: :desc).first
      hash = {}

      next unless entry

      if runner.category_id != entry.category_id
        hash[:category_id] = entry.category_id
      end

      if runner.category_valid != entry.date + 2.years
        hash[:category_valid] = entry.date + 2.years
      end
      next if hash.empty?

      runner.update!(hash)
    end
  end
end

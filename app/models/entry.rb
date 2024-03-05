class Entry < ApplicationRecord
  belongs_to :runner
  belongs_to :category
  belongs_to :result
  before_save :notify_telegram

  scope :status,    -> status    { where status: status }
  scope :runner_id, -> runner_id { where runner_id: runner_id }
  scope :date,      -> from, to  { where date: from..to }
  scope :competition_id, ->(competition_id) { joins(result: :group).where('group.competition_id' => competition_id) }
  scope :from_competition_id, ->(competition_id) {
    where created_at: Competition.find(competition_id).created_at..Competition.find(competition_id).created_at + 5.minutes
  }

  def self.add_entry(params, status = "unconfirmed")
    return if params["category_id"] == 10

    params = params.with_indifferent_access

    return if  Entry.find_by(runner_id: params["runner_id"], result_id: params["result_id"])

    Entry.create!(params.merge(status: status))
    if status == "confirmed"
      Runner.update_runner_category_from_entry(params)
    end
  end

  private

  def notify_telegram
    return if self.status != "confirmed"
    message = "#{self.runner.runner_name} #{self.runner.surname} \nModificare categorie din: #{self.runner.category.category_name} in: #{self.category.category_name} \nvalabila pina la: #{self.category_id == 10 ? "" : (self.date + 2.years).as_json} \nCompetitia: #{self.result.group.competition.competition_name} Grupa: #{self.result.group.group_name}"

    NotifyTelegramJob.perform_now(message)
  end
end

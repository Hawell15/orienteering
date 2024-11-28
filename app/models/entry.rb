class Entry < ApplicationRecord
  belongs_to :runner
  belongs_to :category
  belongs_to :result
  after_save :notify_telegram, :update_runner_category
  after_destroy :update_runner_category

  scope :status,    -> status    { where status: status }
  scope :runner_id, -> runner_id { where runner_id: runner_id }
  scope :date,      -> from, to  { where date: from..to }
  scope :competition_id, ->(competition_id) { joins(result: :group).where('group.competition_id' => competition_id) }
  scope :wre, -> { joins(:runner, result: { group: :competition }).where.not(competitions: { wre_id: nil }) }

  scope :from_competition_id, ->(competition_id) {
    where created_at: Competition.find(competition_id).created_at..Competition.find(competition_id).created_at + 5.minutes
  }

  def update_runner_category
    return unless self.status == "confirmed"

    self.runner.update_runner_category
  end

  private

  def notify_telegram
    return unless Rails.env.production?
    return unless self.status == "confirmed"

    message = "#{self.runner.runner_name} #{self.runner.surname} \nModificare categorie din: #{self.runner.category.category_name} in: #{self.category.category_name} \nvalabila pina la: #{self.category_id == 10 ? "" : (self.date + 2.years).as_json} \nCompetitia: #{self.result.group.competition.competition_name} Grupa: #{self.result.group.group_name}"

    NotifyTelegramJob.perform_now(message)
  end
end

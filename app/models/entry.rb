class Entry < ApplicationRecord
  belongs_to :runner
  belongs_to :category
  belongs_to :result

  scope :status,    -> status    { where status: status }
  scope :runner_id, -> runner_id { where runner_id: runner_id }
  scope :date,      -> from, to  { where date: from..to }

  def self.add_entry(params, status = "unconfirmed")
    return if params["category_id"] == 10

    params = params.with_indifferent_access

    Entry.create!(params.merge(status: status))
    if status == "confirmed"
      Runner.update_runner_category_from_entry(params)
    end
  end
end

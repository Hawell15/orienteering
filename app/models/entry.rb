class Entry < ApplicationRecord
  belongs_to :runner
  belongs_to :category
  belongs_to :result

  def self.add_entry(params, status = "unconfirmed")
    return if params["category_id"] == 10

    params = params.with_indifferent_access

    Entry.create!(params.merge(status: status))
    if status == "confirmed"
      Runner.update_runner_category_from_entry(params)
    end
  end
end

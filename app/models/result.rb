class Result < ApplicationRecord
  belongs_to :runner
  belongs_to :category
  belongs_to :group

  accepts_nested_attributes_for :group

  before_save :add_date

  private

  def add_date
    return if self.date

    self.date = self.group.competition.date
  end

  def self.add_result(params)
    params.slice!("place", "runner_id", "time", "category_id", "group_id", "date", "wre_points", "group_attributes")
    Result.create!(params)
  end
end

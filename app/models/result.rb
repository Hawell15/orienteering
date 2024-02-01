class Result < ApplicationRecord
  belongs_to :runner
  belongs_to :category
  belongs_to :group

  accepts_nested_attributes_for :group

  before_save :add_date

  def self.add_result(params)
    params = params.with_indifferent_access

    check_params =
      {
        runner_id: params["runner_id"],
        group_id:  params["group_id"],
      }

    check_params.merge!(date: params["date"]) if params["date"]

    Result.find_or_create_by(check_params) do |result|
      result.place       = params["place"]       if params["place"]
      result.runner_id   = params["runner_id"]
      result.time        = params["time"]        if params["time"]
      result.category_id = params["category_id"] if params["category_id"]
      result.group_id    = params["group_id"]
      result.date        = params["date"]        if params["category_id"]
      result.wre_points  = params["wre_points"]  if params["category_id"]
    end
  end

  private

  def add_date
    return if self.date

    self.date = self.group.competition.date
  end
end

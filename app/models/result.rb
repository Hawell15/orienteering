class Result < ApplicationRecord
  attr_accessor :status
  belongs_to :runner
  belongs_to :category
  belongs_to :group
  has_one :entry, dependent: :destroy

  accepts_nested_attributes_for :group

  before_save :add_date
  scope :runner_id,      ->(runner_id) { where runner_id: runner_id}
  scope :group_id,      ->(group_id) { where group_id: group_id}
  scope :competition_id, ->(competition_id) { joins(:group).where('group.competition_id' => competition_id) }
  scope :category_id,    ->(category_id) { where category_id: }
  scope :date,           ->(from, to) { where date: from..to }
  scope :wre,            -> { where('wre_points > 0') }
  scope :sorting,        lambda { |sort_by, direction|
    case sort_by
    when 'runner_name'
      joins(:runner).order('runner_name' => direction, 'surname' => direction)
    when 'competition_name'
      joins(group: :competition).order("competitions.competition_name #{direction}")
    when 'group_name'
      joins(:group).order("groups.group_name #{direction}")
    when 'current_category_id'
      select("results.*, (SELECT entries.category_id FROM entries WHERE entries.runner_id = results.runner_id AND entries.status = #{Entry::CONFIRMED} AND entries.date < results.date ORDER BY entries.date DESC LIMIT 1) AS cat_id")
                       .order("cat_id #{direction}")
    else
      order("#{sort_by} #{direction}")
    end
  }

  private

  def add_date
    return if date

    self.date = group.competition.date
  end
end

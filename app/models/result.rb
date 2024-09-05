class Result < ApplicationRecord
  attr_accessor :status
  belongs_to :runner
  belongs_to :category
  belongs_to :group
  has_one :entry, dependent: :destroy

  accepts_nested_attributes_for :group

  before_save :add_date
  after_save :add_entry

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
      select("results.*, (SELECT entries.category_id FROM entries WHERE entries.runner_id = results.runner_id AND entries.status = 'confirmed' AND entries.date < results.date ORDER BY entries.date DESC LIMIT 1) AS cat_id")
                       .order("cat_id #{direction}")
    else
      order("#{sort_by} #{direction}")
    end
  }

  def self.add_result(params, status = 'unconfirmed')
    instance = self.new(params)
    instance.status = status
    instance.save

    params = params.with_indifferent_access

    check_params =
      {
        runner_id: params['runner_id'],
        group_id: params['group_id']
      }

    check_params.merge!(date: params['date']) if params['date']

    result = Result.find_or_create_by(check_params) do |result|
      result.place       = params['place'] if params['place']
      result.runner_id   = params['runner_id']
      result.time        = params['time']        if params['time']
      result.category_id = params['category_id'] if params['category_id']
      result.group_id    = params['group_id']
      result.date        = params['date']        if params['category_id']
      result.wre_points  = params['wre_points']  if params['category_id']
    end

    result
  end

  private

  def add_date
    return if date

    self.date = group.competition.date
  end

  def add_entry
    Entry.check_add_entry(self, @status)
  end
end

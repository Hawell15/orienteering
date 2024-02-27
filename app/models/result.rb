class Result < ApplicationRecord
  belongs_to :runner
  belongs_to :category
  belongs_to :group

  accepts_nested_attributes_for :group

  before_save :add_date

  scope :runner_id,      ->(runner_id) { where runner_id: }
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
    else
      order("#{sort_by} #{direction}")
    end
  }

  def self.add_result(params, status = 'unconfirmed')
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

    if result.group_id == 2 || (result.category_id.to_i < result.runner.category_id.to_i) ||
       (result.category_id.to_i == result.runner.category_id.to_i && result.date > result.runner.category_valid)
      Entry.add_entry(result.slice(:runner_id, :date, :category_id).merge(result_id: result.id), status)
    end

    result
  end

  private

  def add_date
    return if date

    self.date = group.competition.date
  end
end

class Group < ApplicationRecord
  belongs_to :competition
  has_many :results, dependent: :destroy

  before_save :remove_spaces

  accepts_nested_attributes_for :competition

  scope :competition_id, ->(competition_id) { where competition_id: competition_id}
  scope :date,           ->(from, to) {
    joins(:competition).where("competitions.date" => from..to)
  }
  scope :sorting,        lambda { |sort_by, direction|
    case sort_by
    when 'competition_name', 'date'
      joins(:competition).order("competitions.#{sort_by} #{direction}")
    else
      order("#{sort_by} #{direction}")
    end
  }
   scope :search, lambda { |search|
                  where('LOWER(group_name) LIKE :search',
                            search: "%#{search.downcase}%")
                 }


  def self.add_groups(groups, competition)
    groups.each { |group_name| add_group({ group_name: group_name, competition: competition }) }
  end

  def self.add_group(params)
    params = params.with_indifferent_access
    return Group.find(params["group_id"]) if params["group_id"]

    Group.find_or_create_by(params)
  end

  def self.delete_groups(groups, competition)
    groups.each { |group_name| delete_group(group_name, competition) }
  end

  def self.delete_group(group_name, competition)
    group = Group.find_by(group_name: group_name, competition: competition)
    return unless group

    group.destroy
  end

  def remove_spaces
    self.group_name = self.group_name.remove(" ")
  end

  def self.three_results_group_id
    1346
  end
end

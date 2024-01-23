class Group < ApplicationRecord
  belongs_to :competition
  has_many :results, dependent: :destroy

  accepts_nested_attributes_for :competition

  def self.add_groups(groups, competition)
    groups.each { |group_name| add_group({ group_name: group_name, competition: competition }) }
  end

  def self.add_group(params)
    group = Group.find_by(params)
    return group if group

    Group.create!(params)
  end

  def self.delete_groups(groups, competition)
    groups.each { |group_name| delete_group(group_name, competition) }
  end

  def self.delete_group(group_name, competition)
    group = Group.find_by(group_name: group_name, competition: competition)
    return unless group

    group.destroy
  end
end

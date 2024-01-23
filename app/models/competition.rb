class Competition < ApplicationRecord
  has_many :groups , dependent: :destroy

  before_save :add_checksum

  def add_checksum
    self.checksum = (Digest::SHA2.new << "#{self.competition_name}-#{self.date.as_json}-#{self.distance_type}").to_s
  end

  def self.get_checksum(competition_name, date, distance_type)
    (Digest::SHA2.new << "#{competition_name}-#{date.as_json}-#{distance_type}").to_s
  end

  def self.find_competition(params)
    Competition.find_by(checksum: get_checksum(*params.values_at("competition_name", "date", "distance_type")))
  end
end

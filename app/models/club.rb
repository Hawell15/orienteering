class Club < ApplicationRecord
  has_many :runners
  has_many :users

  before_save :add_formatted_name
  before_save :add_formatted_alternative_names
  scope :search, -> (search) { where('LOWER(club_name) LIKE :search OR LOWER(territory) LIKE :search OR LOWER(representative) LIKE :search OR LOWER(email) LIKE :search OR LOWER(phone)CONCAT LIKE :search',
                          search: "%#{search.downcase}%")}
   scope :sorting, ->(sort_by, direction) { order("#{sort_by} #{direction}")}


  def self.add_club(params)
    params = params.with_indifferent_access

    formatted_name = format_name(params["club_name"])
    club = Club.find(1) if formatted_name.blank?
    club ||= Club.find_by(formatted_name: formatted_name) if formatted_name
    club ||= Club.where("alternative_club_name LIKE ?", "%#{formatted_name}%").first
    club ||= Club.create!(params)
  end

  private

  def add_formatted_name
    self.formatted_name = format_name(self.club_name)
  end

  def add_formatted_alternative_names
    return unless  self.alternative_club_name

    self.alternative_club_name = self.alternative_club_name.split(",").map(&method(:format_name)).uniq.join(",")
  end

   def format_name(name)
    return unless name

    name.downcase.gsub("k", "c").gsub("ș", "s").gsub("ț", "t").gsub("ă", "a").gsub("î", "i").gsub("â", "i").gsub(/[^a-z]+/, '')
  end

  def self.format_name(name)
    return unless name

    name.downcase.gsub("k", "c").gsub("ș", "s").gsub("ț", "t").gsub("ă", "a").gsub("î", "i").gsub("â", "i").gsub(/[^a-z]+/, '')
  end
end

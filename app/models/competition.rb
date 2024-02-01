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

  def self.add_competition(params)
    params = params.with_indifferent_access

    if params["competition_id"]
      Competition.find(params["competition_id"])
    else
      checksum = get_checksum(*params.values_at("competition_name", "date", "distance_type"))

      Competition.find_or_create_by(checksum: checksum) do |comp|
        comp.competition_name = params[:competition_name]
        comp.date             = params[:date]
        comp.distance_type    = params[:distance_type]
        comp.location         = params[:location]
        comp.country          = params[:country]
        comp.wre_id           = params[:wre_id]
      end
    end
  end
end

class Runner < ApplicationRecord
  belongs_to :club
  belongs_to :category
  has_many :results
  has_many :entries

  accepts_nested_attributes_for :results

  before_save :add_checksum
  scope :wre, -> { where.not(wre_id: nil) }
  scope :club_id, -> (club_id) { where(club_id: club_id) }
  scope :category_id, -> (category_id) { where(category_id: category_id) }
  scope :best_category_id, -> (best_category_id) { where(best_category_id: best_category_id) }
  scope :gender, -> (gender) { where(gender: gender) }
  scope :search, -> (search) { where("LOWER(CONCAT(runner_name, ' ', surname)) LIKE :search OR LOWER(CONCAT(surname, ' ', runner_name)) LIKE :search", search: "%#{search.downcase}%")
}
  scope :dob, -> (from, to) { where dob: from..to }

  scope :sorting, ->(sort_by, direction) {
    case sort_by
    when "runner"
      order("runner_name #{direction}, surname #{direction}")
    when "club"
      joins(:club).order("clubs.club_name #{direction}")
    else
      order("#{sort_by} #{direction}")
    end
  }

  scope :matching_runner, ->(options) {
    where("wre_id = :wre_id or id = :id or checksum = :checksum",
      wre_id: options[:wre_id],
      id: options[:id],
      checksum: get_checksum(*options.values_at("runner_name", "surname", "dob", "gender")))
  }

  def self.add_runner(params, skip_matching = false )
    params = params.with_indifferent_access

    runner = matching_runner(params).first
    runner ||= get_runner_by_matching(params) unless skip_matching
    runner ||= Runner.create!(params.except("category_id", "date"))
    if params["category_id"] && params["category_id"].to_i < runner.category_id.to_i
      Result.add_result({ runner_id: runner.id, group_id: 1, category_id: params["category_id"], date: params["date"].as_json })
    end
    runner
  end

  def self.get_checksum(runner_name, surname, dob, gender)
    (Digest::SHA2.new << "#{runner_name}-#{surname}-#{dob.to_date.year}-#{gender}").to_s
  end

  def get_checksum(runner_name, surname, dob, gender)
    (Digest::SHA2.new << "#{runner_name}-#{surname}-#{dob.to_date.year}-#{gender}").to_s
  end

  def self.update_runner_category_from_entry(params)
    runner = Runner.find(params["runner_id"])

    category_valid = params["category_id"] == 10 ? "2100-01-01" : (params["date"].to_date + 2.years).as_json

    runner.update!(
      category_id: params["category_id"],
      best_category_id: [runner.best_category_id, params["category_id"]].min,
      category_valid: category_valid
      )
  end

  private

  def add_checksum
    self.checksum = get_checksum(self.runner_name, self.surname, self.dob, self.gender)
  end

  def self.get_runner_by_matching(options)
    threshold = 0.7
    runners = Runner.where(gender: options[:gender]).all.map do |runner|
      next if (runner.dob.year -  options[:dob].to_date.year).abs > 1

      name_threshold = Text::Levenshtein.distance(runner.runner_name.downcase, options[:runner_name].downcase) / runner.runner_name.length.to_f
      surname_threshold = Text::Levenshtein.distance(runner.surname.downcase, options[:surname].downcase) / runner.surname.length.to_f
      next nil unless (name_threshold + surname_threshold)/2 < (1 -threshold)

      [(name_threshold + surname_threshold)/2, runner]
    end
    runners.compact.max_by { |el| el.first}&.last
  end
end

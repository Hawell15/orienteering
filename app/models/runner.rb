class Runner < ApplicationRecord
  belongs_to :club
  belongs_to :category
  has_many :results

  accepts_nested_attributes_for :results

  before_save :add_checksum

  scope :matching_runner, ->(options) {
    where("wre_id = :wre_id or id = :id or checksum = :checksum",
      wre_id: options[:wre_id],
      id: options[:id],
      checksum: get_checksum(*options.values_at("runner_name", "surname", "dob", "gender")))
  }

  def self.add_runner(params)
    params = params.with_indifferent_access

    runner = matching_runner(params).first
    runner ||= get_runner_by_matching(params)
    runner ||= Runner.create!(params.except("category_id"))

    if params["category_id"] && params["category_id"] < runner.category_id
      Result.add_result_and_entry({ runner_id: runner.id, group_id: 0, category_id: params["category_id"], date: Competition.last.date.as_json })

    end
    runner
  end

  def self.get_checksum(runner_name, surname, dob, gender)
    (Digest::SHA2.new << "#{runner_name}-#{surname}-#{dob.to_date.year}-#{gender}").to_s
  end

  def get_checksum(runner_name, surname, dob, gender)
    (Digest::SHA2.new << "#{runner_name}-#{surname}-#{dob.to_date.year}-#{gender}").to_s
  end

  private

  def add_checksum
    self.checksum = get_checksum(self.runner_name, self.surname, self.dob, self.gender)
  end

  def self.get_runner_by_matching(options)
    threshold = 0.7
    runners = Runner.where(gender: options[:gender]).all.map do |runner|
      name_threshold = Text::Levenshtein.distance(runner.runner_name.downcase, options[:runner_name].downcase) / runner.runner_name.length.to_f
      surname_threshold = Text::Levenshtein.distance(runner.surname.downcase, options[:surname].downcase) / runner.surname.length.to_f
      next nil unless (name_threshold + surname_threshold)/2 < (1 -threshold)

      [(name_threshold + surname_threshold)/2, runner]
    end
    runners.compact.max_by { |el| el.first}&.last
  end
end

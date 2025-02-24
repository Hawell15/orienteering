module RunnerMatching
  extend ActiveSupport::Concern

  included do
    scope :matching_runner, lambda { |options|
      where('wre_id = :wre_id OR id = :id OR checksum = :checksum',
            wre_id: options[:wre_id],
            id: options[:id],
            checksum: Runner::Checksum.get_checksum(*options.values_at('runner_name', 'surname', 'dob', 'gender')))
    }
  end

  def self.get_runner_by_matching(options)
    runners = Runner.where(gender: options[:gender])

    if options[:dob].to_date > Date.new(0, 1, 1)
      start_date = options[:dob].to_date.beginning_of_year - 1.year
      end_date = options[:dob].to_date.beginning_of_year + 1.year
      runners = runners.where(dob: start_date..end_date).or(runners.where(dob: Date.new(0, 1, 1)))
    end

    threshold = 0.8

    matching_runners = runners.map do |runner|
      next if runner.id == 99999999
      if Text::Soundex.soundex(runner.runner_name) == Text::Soundex.soundex(options[:runner_name]) &&
         Text::Soundex.soundex(runner.surname) == Text::Soundex.soundex(options[:surname])
        return runner
      end

      name_threshold = Text::Levenshtein.distance(runner.runner_name.downcase,
                                                  options[:runner_name].downcase) / runner.runner_name.length.to_f
      surname_threshold = Text::Levenshtein.distance(runner.surname.downcase,
                                                     options[:surname].downcase) / runner.surname.length.to_f
      next unless (name_threshold + surname_threshold) / 2 < (1 - threshold)

      [(name_threshold + surname_threshold) / 2, runner]
    end

    matching_runners.compact.max_by { |el| el.first }&.last
  end
end

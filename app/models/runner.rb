class Runner < ApplicationRecord
  belongs_to :club
  belongs_to :category
  belongs_to :best_category, class_name: 'Category'
  has_many :results, dependent: :destroy
  has_many :entries, dependent: :destroy

  accepts_nested_attributes_for :results

  before_save :add_checksum
  before_save :check_dob
  scope :wre, -> { where.not(wre_id: nil) }
  scope :club_id, ->(club_id) { where(club_id:) }
  scope :category_id, ->(category_id) { where(category_id:) }
  scope :best_category_id, ->(best_category_id) { where(best_category_id:) }
  scope :gender, ->(gender) { where(gender:) }
  scope :search, lambda { |search|
                   where("LOWER(CONCAT(runner_name, ' ', surname)) LIKE :search OR LOWER(CONCAT(surname, ' ', runner_name)) LIKE :search", search: "%#{search.downcase}%")
                 }
  scope :dob, ->(from, to) { where dob: from..to }

  scope :licensed, ->(*value) {
    value = value.first
    if value.present?
      case value.to_s
      when "true"
        where(license: true)
      when "false"
        where(license: false)
      else
        all
      end
    else
      all
    end
  }

  scope :sorting, lambda { |sort_by, direction|
    case sort_by
    when 'runner'
      order("runner_name #{direction}, surname #{direction}")
    when 'club'
      joins(:club).order("clubs.club_name #{direction}")
    else
      order("#{sort_by} #{direction}")
    end
  }

  scope :matching_runner, lambda { |options|
    where('wre_id = :wre_id or id = :id or checksum = :checksum',
          wre_id: options[:wre_id],
          id: options[:id],
          checksum: get_checksum(*options.values_at('runner_name', 'surname', 'dob', 'gender')))
  }

  def self.add_runner(params, skip_matching = false)
    params = params.with_indifferent_access

    params['runner_name'] = convert_from_russian(params['runner_name'])
    params['surname']     = convert_from_russian(params['surname'])

    runner = matching_runner(params).first
    runner ||= get_runner_by_matching(params) unless skip_matching
    params['id'] ||= (Runner.last&.id || 0) + 1
    runner ||= Runner.create!(params.except('category_id', 'date'))

    runner
  end

  def self.get_checksum(runner_name, surname, dob, gender)
    (Digest::SHA2.new << "#{runner_name}-#{surname}-#{dob.to_date.year}-#{gender}").to_s
  end

  def get_checksum(runner_name, surname, dob, gender)
    (Digest::SHA2.new << "#{runner_name}-#{surname}-#{dob.to_date.year}-#{gender}").to_s
  end

  def entry_on_date(date = Date.today)
    entry = entries
      .joins(:category)
      .where('entries.date + (categories.validaty_period * INTERVAL \'1 year\') > ?', date)
      .where(entries: { status: Entry::CONFIRMED })
      .order(:category_id, date: :desc).first

    entry = nil if entry && entry.category_id.in?((7..9).to_a) && !self.junior_runner?

    entry
  end

  def update_runner_category(date = Date.today)
    entry = entry_on_date

    hash = {}

    if entry && self.best_category_id > entry.category_id
      hash[:best_category_id] = entry.category_id
    end

    if self.category_id != 10 && (!entry || entry.category_id == 10)
      hash[:category_id]    = 10
      hash[:category_valid] = "2100-01-01".to_date
    elsif entry && self.category_id != entry.category_id
      hash[:category_id] = entry.category_id
      hash[:category_valid] = entry.date + entry.category.validaty_period.years

    elsif entry && self.category_valid.to_date != entry.date + category.validaty_period.years
      hash[:category_valid] = entry.date + category.validaty_period.years
    end

    return if hash.empty?

    self.update!(hash)
  end

  def junior_runner?
    Time.now.year - dob.year < 18
  end

  private

  def add_checksum
    self.checksum = get_checksum(runner_name, surname, dob, gender)
  end

  def check_dob
    return unless self.dob.to_date == "01-01-2025".to_date

    self.dob = "01-01-0000".to_date
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

  def self.convert_from_russian(name)
    return name unless contains_cyrillic?(name)

    name.gsub!('ья', 'ia')
    name.gsub!('ия', 'ia')
    name.gsub!('ея', 'еa')
    name.gsub!('Ки', 'Chi')
    name.gsub!('Ке', 'Chе')
    name.gsub!('кс', 'x')
    name.gsub!('Кс', 'X')
    name.gsub!('ки', 'chi')
    name.gsub!('ке', 'chе')
    name.gsub!('Че', 'Ce')
    name.gsub!('че', 'ce')
    name.gsub!('Ги', 'Ghi')
    name.gsub!('Ге', 'Ghe')
    name.gsub!('ги', 'ghi')
    name.gsub!('ге', 'ghe')

    russian_to_romanian =
      {
        'А' => 'A',
        'Б' => 'B',
        'В' => 'V',
        'Г' => 'G',
        'Д' => 'D',
        'Е' => 'E',
        'Ё' => 'Io',
        'Ж' => 'J',
        'З' => 'Z',
        'И' => 'I',
        'Й' => 'I',
        'К' => 'C',
        'Л' => 'L',
        'М' => 'M',
        'Н' => 'N',
        'О' => 'O',
        'П' => 'P',
        'Р' => 'R',
        'С' => 'S',
        'Т' => 'T',
        'У' => 'U',
        'Ф' => 'F',
        'Х' => 'H',
        'Ц' => 'Ț',
        'Ч' => 'Ci',
        'Ш' => 'Ș',
        'Щ' => 'Ș',
        'Ъ' => 'I',
        'Ы' => 'Î',
        'Ь' => 'I',
        'Э' => 'Ă',
        'Ю' => 'Iu',
        'Я' => 'Ia',
        'а' => 'a',
        'б' => 'b',
        'в' => 'v',
        'г' => 'g',
        'д' => 'd',
        'е' => 'e',
        'ё' => 'io',
        'ж' => 'j',
        'з' => 'z',
        'и' => 'i',
        'й' => 'i',
        'к' => 'c',
        'л' => 'l',
        'м' => 'm',
        'н' => 'n',
        'о' => 'o',
        'п' => 'p',
        'р' => 'r',
        'с' => 's',
        'т' => 't',
        'у' => 'u',
        'ф' => 'f',
        'х' => 'h',
        'ц' => 'ț',
        'ч' => 'ci',
        'ш' => 'ș',
        'щ' => 'ș',
        'ъ' => 'i',
        'ы' => 'î',
        'ь' => 'i',
        'э' => 'ă',
        'ю' => 'iu',
        'я' => 'ia'
      }
    name.chars.map { |char| russian_to_romanian[char] || char }.join
  end

  def self.contains_cyrillic?(str)
    cyrillic_pattern = /\p{Cyrillic}/

    !!(str =~ cyrillic_pattern)
  end
end

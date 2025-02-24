module Runner::Processing
  extend ActiveSupport::Concern

  def update_runner_category(date = Date.today)
    entry = entries
      .joins(:category)
      .where('entries.date + (categories.validaty_period * INTERVAL \'1 year\') > ?', date)
      .where(entries: { status: Entry::CONFIRMED })
      .order(:category_id, date: :desc).first

    entry = nil if entry && entry.category_id.in?((7..9).to_a) && !junior_runner?
    hash = {}

    if entry && best_category_id > entry.category_id
      hash[:best_category_id] = entry.category_id
    end

    if category_id != 10 && (!entry || entry.category_id == 10)
      hash[:category_id] = 10
      hash[:category_valid] = "2100-01-01".to_date
    elsif entry && category_id != entry.category_id
      hash[:category_id] = entry.category_id
      hash[:category_valid] = entry.date + entry.category.validaty_period.years
    elsif entry && category_valid.to_date != entry.date + category.validaty_period.years
      hash[:category_valid] = entry.date + category.validaty_period.years
    end

    update!(hash) unless hash.empty?
  end
end

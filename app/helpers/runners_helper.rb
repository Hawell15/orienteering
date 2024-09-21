module RunnersHelper
  def filter_runners(params)
     params = params.with_indifferent_access
     runners = Runner.includes(:category, :best_category, :club).order(:id)

     filtering_params = params.slice(:category_id, :club_id, :best_category_id, :gender, :wre, :search, :sort_by, :dob)

    filtering_params.each do |key, value|
      next if value.blank?

    runners = case key
      when "wre"     then runners.wre
      when "sort_by" then runners.sorting(value, params[:direction])
      when "dob"     then runners.dob(value[:from].presence, value[:to].presence)
      else runners.public_send(key, value)
      end
    end
    runners
  end

  def update_runner_category(runner)
    entry = Entry.where(runner_id: runner.id).where(status: "confirmed").where('date < ?', (Time.now + 1.day).to_date ).order(date: :desc).first

    return if !entry && runner.category_id == 10

    hash = {}

    if runner.best_category_id > entry.category_id
      hash[:best_category_id] = entry.category_id
    end


    if runner.category_id != 10 && (!entry || entry.category_id == 10)
      hash[:category_id]    = 10
      hash[:category_valid] = "2100-01-01".to_date
    elsif runner.category_id != entry.category_id
      hash[:category_id] = entry.category_id
      hash[:category_valid] = entry.date + entry.category.validaty_period.years

    elsif runner.category_valid.to_date != entry.date + category.validaty_period.years
      hash[:category_valid] = entry.date + category.validaty_period.years
    end

    return if hash.empty?

    runner.update!(hash)
  end
end

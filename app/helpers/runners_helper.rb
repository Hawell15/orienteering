module RunnersHelper
  def filter_runners(params)
     params = params.with_indifferent_access
     runners = Runner.includes(:category, :best_category, :club)

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

end

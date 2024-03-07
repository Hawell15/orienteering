module GroupsHelper
   def filter_groups(params)
    params = params.with_indifferent_access
    groups = Group.includes(:competition)
    groups = groups.sorting("competition_name",:desc) unless params[:sort_by]

    filtering_params = params.slice(:competition_id, :sort_by, :date, :search)

    filtering_params.each do |key, value|
      next if value.blank?

      groups = case key
      when "sort_by" then groups.sorting(value, params[:direction])
      when "date"     then groups.date(value[:from].presence, value[:to].presence)
      else groups.public_send(key, value)
      end
    end

    groups
  end
end

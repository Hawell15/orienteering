module Runner::Sortable
  extend ActiveSupport::Concern

  included do
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
  end
end

module Runner::Searchable
  extend ActiveSupport::Concern

  included do
    scope :wre, -> { where.not(wre_id: nil) }
    scope :club_id, ->(club_id) { where(club_id:) }
    scope :category_id, ->(category_id) { where(category_id:) }
    scope :best_category_id, ->(best_category_id) { where(best_category_id:) }
    scope :gender, ->(gender) { where(gender:) }
    scope :dob, ->(from, to) { where dob: from..to }

    scope :search, lambda { |search|
      where("LOWER(CONCAT(runner_name, ' ', surname)) LIKE :search OR LOWER(CONCAT(surname, ' ', runner_name)) LIKE :search", search: "%#{search.downcase}%")
    }
  end
end

class Group < ApplicationRecord
  belongs_to :competition
  has_many :results

  accepts_nested_attributes_for :competition
end

class Group < ApplicationRecord
  belongs_to :competition

  accepts_nested_attributes_for :competition
end

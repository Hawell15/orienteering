class Entry < ApplicationRecord
  belongs_to :runner
  belongs_to :category
  belongs_to :result
end

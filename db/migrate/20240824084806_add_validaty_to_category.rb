class AddValidatyToCategory < ActiveRecord::Migration[6.1]
  def change
    add_column :categories, :validaty_period, :integer, default: 2
  end
end

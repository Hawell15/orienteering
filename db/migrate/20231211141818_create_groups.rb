class CreateGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :groups do |t|
      t.string :group_name
      t.reference :competition
      t.integer :rang
      t.string :clasa

      t.timestamps
    end
  end
end

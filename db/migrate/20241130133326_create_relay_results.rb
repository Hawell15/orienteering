class CreateRelayResults < ActiveRecord::Migration[6.1]
  def change
    create_table :relay_results do |t|
      t.integer :place
      t.string :team
      t.integer :time
      t.references :category, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.date :date
      t.references :results, default: [], array: true

      t.timestamps
    end
  end
end

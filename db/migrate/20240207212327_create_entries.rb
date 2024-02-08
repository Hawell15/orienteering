class CreateEntries < ActiveRecord::Migration[6.1]
  def change
    create_table :entries do |t|
      t.date :date
      t.references :runner, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references :result, foreign_key: true
      t.string :status,  default: "unconfirmed"

      t.timestamps
    end
  end
end

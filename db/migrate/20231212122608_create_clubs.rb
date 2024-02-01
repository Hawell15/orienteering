class CreateClubs < ActiveRecord::Migration[6.1]
  def change
    create_table :clubs do |t|
      t.string :club_name
      t.string :territory
      t.string :representative
      t.string :email
      t.string :phone
      t.string :alternative_club_name
      t.string :formatted_name

      t.timestamps
    end
  end
end

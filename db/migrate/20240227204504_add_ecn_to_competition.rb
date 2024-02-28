class AddEcnToCompetition < ActiveRecord::Migration[6.1]
  def change
    add_column :competitions, :ecn, :boolean, default: false
  end
end

class AddEcnCoeficientToGroup < ActiveRecord::Migration[6.1]
  def change
    add_column :groups, :ecn_coeficient, :float, default: 0.0
  end
end

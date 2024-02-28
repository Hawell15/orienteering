class AddEcnPointstToResult < ActiveRecord::Migration[6.1]
  def change
    add_column :results, :ecn_points, :float, default: 0.0
  end
end

class AddLicenseToRunner < ActiveRecord::Migration[6.1]
 def change
    add_column :runners, :license, :boolean, default: false
  end
end

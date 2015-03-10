class CreateAdmins < ActiveRecord::Migration
  def change
    create_table :admins do |t|
      t.string :name,             :limit => 32, :null => false
      t.string :crypted_password, :limit => 32, :null => false
      t.string :salt,             :limit => 32, :null => false

      t.timestamps null: false
    end
  end
end
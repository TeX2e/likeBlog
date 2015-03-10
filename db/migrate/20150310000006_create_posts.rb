class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.date :date, null: false
      t.string :title, null: false
      t.text :text, null: false
      t.boolean :publish, null: false

      t.timestamps null: false
    end
  end
end

class AddToPosts < ActiveRecord::Migration
  def change
  	#add_column :posts, :html_text, :stirng

  	# 次にテーブルを作る際は
  	# rails g model post date:date title:string text:string html_text:string publish:boolean
  end
end

class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_id
      t.string :user_name
      t.string :user_fullname
      t.integer :position_id
      t.integer :bankofhours_id

      t.timestamps
    end
  end
end

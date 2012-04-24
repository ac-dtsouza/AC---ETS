class CreateAdmins < ActiveRecord::Migration
  def change
    create_table :admins do |t|
      t.string :user_id

      t.timestamps
    end
  end
end

class RemoveUserFullnameFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :user_fullname
  end

  def down
    add_column :users, :user_fullname, :string
  end
end

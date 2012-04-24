class CreateChecks < ActiveRecord::Migration
  def change
    create_table :checks do |t|
      t.string :user_id
      t.timestamp :check

      t.timestamps
    end
  end
end

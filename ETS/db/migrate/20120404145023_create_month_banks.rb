class CreateMonthBanks < ActiveRecord::Migration
  def change
    create_table :month_banks do |t|
      t.integer :bankofhours_id
      t.float :start_hours
      t.float :end_hours
      t.datetime :month

      t.timestamps
    end
  end
end

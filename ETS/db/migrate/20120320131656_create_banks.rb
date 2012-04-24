class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
      t.integer :bankofhours_id
      t.float :bank_hours
      t.datetime :last_reset
      t.datetime :next_reset

      t.timestamps
    end
  end
end

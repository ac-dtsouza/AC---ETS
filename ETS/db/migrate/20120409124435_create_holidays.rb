class CreateHolidays < ActiveRecord::Migration
  def change
    create_table :holidays do |t|
      t.string :day
      t.string :desc

      t.timestamps
    end
  end
end

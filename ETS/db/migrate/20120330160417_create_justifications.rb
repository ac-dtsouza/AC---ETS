class CreateJustifications < ActiveRecord::Migration
  def change
    create_table :justifications do |t|
      t.string :user_id
      t.string :date
      t.string :motive

      t.timestamps
    end
  end
end

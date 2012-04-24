class CreateParameters < ActiveRecord::Migration
  def change
    create_table :parameters do |t|
      t.string :desc
      t.float :multiplier

      t.timestamps
    end
  end
end

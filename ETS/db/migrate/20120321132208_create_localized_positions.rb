class CreateLocalizedPositions < ActiveRecord::Migration
  def change
    create_table :localized_positions do |t|
      t.integer :position_id
      t.string :position_desc_en
      t.string :position_desc_pt
      t.integer :position_workload

      t.timestamps
    end
  end
end

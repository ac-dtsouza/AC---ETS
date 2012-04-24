class DropPositions < ActiveRecord::Migration
  def up
	drop_table :positions
  end

  def down
  end
end

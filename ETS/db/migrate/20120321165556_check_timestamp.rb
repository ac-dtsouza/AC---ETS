class CheckTimestamp < ActiveRecord::Migration
  def up
	rename_column(:checks, :check, :check_timestamp)
  end

  def down
  end
end

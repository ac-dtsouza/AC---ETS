class RollbackWithoutHolidayLocale < ActiveRecord::Migration
  def up
	rename_column :holidays, :desc_pt, :desc
	remove_column :holidays, :desc_en
  end

  def down
  end
end

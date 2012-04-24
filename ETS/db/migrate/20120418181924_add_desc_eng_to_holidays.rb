class AddDescEngToHolidays < ActiveRecord::Migration
  def change
	rename_column :holidays, :desc, :desc_pt
    add_column :holidays, :desc_eng, :string
  end
end

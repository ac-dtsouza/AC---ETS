class RenameDescEng < ActiveRecord::Migration
  def up
	rename_column :holidays, :desc_eng, :desc_en
  end

  def down
	rename_column :holidays, :desc_en, :desc_eng
  end
end

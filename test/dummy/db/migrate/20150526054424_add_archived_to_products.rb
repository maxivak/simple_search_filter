class AddArchivedToProducts < ActiveRecord::Migration
  def up
    add_column :products, :is_archived, :boolean, :default => false
  end

  def down
    remove_column :products, :is_archived
  end
end

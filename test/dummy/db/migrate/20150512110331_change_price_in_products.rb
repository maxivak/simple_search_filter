class ChangePriceInProducts < ActiveRecord::Migration
  def up
    change_column :products, :price, :decimal, :precision => 10, :scale => 4
  end

  def down
    change_column :products, :price, :decimal
  end

end

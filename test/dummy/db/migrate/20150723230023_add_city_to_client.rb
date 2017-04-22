class AddCityToClient < ActiveRecord::Migration
  def up
    add_column :clients, :city, :string
  end

  def down
    remove_column :clients, :city
  end

end

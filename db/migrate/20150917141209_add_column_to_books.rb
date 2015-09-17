class AddColumnToBooks < ActiveRecord::Migration
  def change
    add_column :books, :image, :string, :after => :description
  end
end

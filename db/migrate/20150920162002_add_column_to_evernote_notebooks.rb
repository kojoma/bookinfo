class AddColumnToEvernoteNotebooks < ActiveRecord::Migration
  def change
    add_column :evernote_notebooks, :name, :string
  end
end

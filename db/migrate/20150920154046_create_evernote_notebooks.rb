class CreateEvernoteNotebooks < ActiveRecord::Migration
  def change
    create_table :evernote_notebooks do |t|
      t.string :guid

      t.timestamps null: false
    end
  end
end

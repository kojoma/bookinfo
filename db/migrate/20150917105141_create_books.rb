class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :isbn
      t.string :asin
      t.string :title
      t.string :publisher
      t.string :author
      t.text :description
      t.date :publish_date
      t.integer :number_of_pages
      t.integer :price

      t.timestamps null: false
    end
  end
end

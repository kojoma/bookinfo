json.array!(@books) do |book|
  json.extract! book, :id, :isbn, :asin, :title, :publisher, :author, :description, :image, :publish_date, :number_of_pages, :price, :evernote_post_at
  json.url book_url(book, format: :json)
end

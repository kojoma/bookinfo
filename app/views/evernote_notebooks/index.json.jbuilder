json.array!(@evernote_notebooks) do |evernote_notebook|
  json.extract! evernote_notebook, :id, :guid, :name
  json.url evernote_notebook_url(evernote_notebook, format: :json)
end

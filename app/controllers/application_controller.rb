class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # get evernote client
  def get_evernote_notestore
    developer_token = Rails.application.secrets.evernote_developer_token_sandbox

    # Set up the NoteStore client
    client = EvernoteOAuth::Client.new(
      token: developer_token,
      sandbox: true
    )

    return client.note_store
  end

  # get evernote notebook name
  def get_evernote_notebook_name(note_store, notebook_guid)
    notebook_name = ''
    notebooks     = note_store.listNotebooks

    notebooks.each do |notebook|
      if notebook.guid == notebook_guid
        notebook_name = notebook.name
      end
    end

    return notebook_name
  end
end

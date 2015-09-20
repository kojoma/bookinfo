class EvernoteNotebooksController < ApplicationController
  before_action :set_evernote_notebook, only: [:update]

  # GET /evernote_notebooks
  # GET /evernote_notebooks.json
  def index
    @evernote_notebook = EvernoteNotebook.find(1)
    if @evernote_notebook.blank?
      @evernote_notebook = EvernoteNotebook.new
    end

    # Set up the NoteStore client
    note_store = get_evernote_notestore

    # get evernote notebooks
    @notebooks = notebook_to_hash(note_store.listNotebooks)
  end

  # POST /evernote_notebooks
  # POST /evernote_notebooks.json
  def create
    @evernote_notebook = EvernoteNotebook.new(evernote_notebook_params)

    # get evernote notebook name
    note_store              = get_evernote_notestore
    notebook_name           = get_evernote_notebook_name(note_store, @evernote_notebook.guid)
    @evernote_notebook.name = notebook_name

    respond_to do |format|
      if @evernote_notebook.save
        format.html { redirect_to evernote_notebooks_path, notice: '送信先のノートブックを登録しました。' }
        format.json { render :index, status: :created, location: @evernote_notebook }
      else
        format.html { render :index }
        format.json { render json: @evernote_notebook.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /evernote_notebooks/1
  # PATCH/PUT /evernote_notebooks/1.json
  def update
    # get evernote notebook name
    note_store              = get_evernote_notestore
    notebook_name           = get_evernote_notebook_name(note_store, @evernote_notebook.guid)
    @evernote_notebook.name = notebook_name

    respond_to do |format|
      if @evernote_notebook.update(evernote_notebook_params)
        format.html { redirect_to evernote_notebooks_path, notice: '送信先のノートブックを更新しました。' }
        format.json { render :index, status: :ok, location: @evernote_notebook }
      else
        format.html { render :index }
        format.json { render json: @evernote_notebook.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_evernote_notebook
      @evernote_notebook = EvernoteNotebook.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def evernote_notebook_params
      params.require(:evernote_notebook).permit(:guid)
    end

    # evernote notebook convert to hash
    def notebook_to_hash(notebooks)
      notebook_hash = Hash.new
      notebooks.each do |notebook|
        notebook_hash.store(notebook.guid, notebook.name)
      end

      return notebook_hash
    end
end

class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy, :evernote_post]

  # GET /books
  # GET /books.json
  def index
    @books = Book.page(params[:page]).order(id: :desc)
  end

  # GET /books/1
  # GET /books/1.json
  def show
  end

  # GET /books/new
  def new
    @book = Book.new
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books
  # POST /books.json
  def create
    @book = Book.new(book_params)

    # 書籍情報を取得
    get_info

    if @res.present? && !@res.has_error? && @res.total_results != 0
      @book.isbn            = @res.first_item.get('ItemAttributes/ISBN')
      @book.asin            = @res.first_item.get('ASIN')
      @book.title           = @res.first_item.get('ItemAttributes/Title')
      @book.publisher       = @res.first_item.get('ItemAttributes/Manufacturer')
      @book.author          = @res.first_item.get('ItemAttributes/Author')
      @book.description     = @res.first_item.get('EditorialReviews/EditorialReview/Content')
      @book.image           = @res.first_item.get('MediumImage/URL')
      @book.publish_date    = @res.first_item.get('ItemAttributes/PublicationDate')
      @book.number_of_pages = @res.first_item.get('ItemAttributes/NumberOfPages')
      @book.price           = @res.first_item.get('ItemAttributes/ListPrice/Amount')

      # 取得したISBNが登録されてない場合のみ、取得した書籍を登録する
      @find_book = Book.find_by(isbn: @book.isbn)
      if @find_book.nil?
        respond_to do |format|
          if @book.save
            format.html { redirect_to @book, notice: @book.title + ' を新規登録しました。' }
            format.json { render :show, status: :created, location: @book }
          else
            format.html { render :new }
            format.json { render json: @book.errors, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|
          format.html { redirect_to @find_book, notice: @book.title + ' は既に登録されています。' }
          format.json { render :show, status: :created, location: @find_book }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to books_url, notice: '本が見つかりませんでした。' }
        format.json { head :no_content }
      end
    end
  end

  # PATCH/PUT /books/1
  # PATCH/PUT /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to @book, notice: @book.title + ' の更新に成功しました。' }
        format.json { render :show, status: :ok, location: @book }
      else
        format.html { render :edit }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1
  # DELETE /books/1.json
  def destroy
    @book.destroy
    respond_to do |format|
      format.html { redirect_to books_url, notice: @book.title + ' の削除に成功しました。' }
      format.json { head :no_content }
    end
  end

  # post to evernote
  def evernote_post
    # Set up the NoteStore client
    note_store = get_evernote_notestore

    # get notebook list
    notebooks = note_store.listNotebooks

    # setting to post of notebook
    evernote_notebook = EvernoteNotebook.find(1)
    notebooks.each do |notebook|
      if notebook.guid == evernote_notebook.guid
        @parent_notebook = notebook
      end
    end
    note_title = @book.title
    note_text  = '<br/>タイトル: '  + '<a href="http://www.amazon.co.jp/dp/' + @book.asin + '">' + @book.title + '</a>'
    note_text += '<br/>出版社: '    + @book.publisher
    note_text += '<br/>著者: '      + @book.author
    note_text += '<br/>ISBN: '      + @book.isbn
    if @book.description.present?
      note_text += '<br/>内容: '    + @book.description
    end
    note_text += '<br/>発売日: '    + @book.publish_date.to_s
    note_text += '<br/>ページ数: '  + @book.number_of_pages.to_s
    note_text += '<br/>価格: &yen;' + @book.price.to_s
    note_text += '<br/><hr/><br/>'
    note = make_note(note_store, @book.title, note_text, @parent_notebook)

    respond_to do |format|
      format.html { redirect_to books_url, notice: @book.title + ' をEvernoteに投稿しました。' }
      format.json { render :show, status: :created, location: @book }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      if params[:id].present?
        @book = Book.find(params[:id])
      else
        @book = Book.find(params[:book_id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def book_params
      params.require(:book).permit(:isbn, :asin, :title, :publisher, :author, :image, :description, :publish_date, :number_of_pages, :price, :evernote_post_at)
    end

    # save evernote_post_at to book
    def save_evernote_post_at
      @book.evernote_post_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      @book.save
    end

    # get book infomation from amazon
    def get_info
      Amazon::Ecs.debug = true
      @res = Amazon::Ecs.item_search(@book.isbn, {:search_index => 'Books', :response_group => 'Medium', :country => 'jp'})
    end

    # make note to evernote
    def make_note(note_store, note_title, note_body, parent_notebook=nil)
      # read the image, to make hash key in MD5
      file_path = save_image(@book.image)
      file_url  = @book.image
      mime_type = MIME::Types.type_for(file_path).to_s
      image     = File.open(file_path, "rb") { |io| io.read }
      hashFunc  = Digest::MD5.new
      hashHex   = hashFunc.hexdigest(image)

      # make mata data type to image
      data          = Evernote::EDAM::Type::Data.new()
      data.size     = image.size
      data.bodyHash = hashHex
      data.body     = image

      # dataと併せて添付ファイル形式を作る
      resource                     = Evernote::EDAM::Type::Resource.new()
      resource.mime                = "image/jpeg"
      resource.data                = data
      resource.attributes          = Evernote::EDAM::Type::ResourceAttributes.new()
      resource.attributes.fileName = file_url

      n_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
      n_body += "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
      n_body += "<en-note><en-media type=\"#{resource.mime}\" hash=\"#{hashHex}\"/>#{note_body}</en-note>"
      #n_body += "<en-note>#{note_body}<en-media type=\"#{mime_type}\" hash=\"#{hashHex}\"/></en-note>"

      ## Create note object
      our_note           = Evernote::EDAM::Type::Note.new
      our_note.title     = note_title
      our_note.content   = n_body
      our_note.resources = [ resource ]

      ## parent_notebook is optional; if omitted, default notebook is used
      if parent_notebook && parent_notebook.guid
        our_note.notebookGuid = parent_notebook.guid
      end

      ## Attempt to create note in Evernote account
      begin
        note = note_store.createNote(our_note)
      rescue Evernote::EDAM::Error::EDAMUserException => edue
        ## Something was wrong with the note data
        ## See EDAMErrorCode enumeration for error code explanation
        ## http://dev.evernote.com/documentation/reference/Errors.html#Enum_EDAMErrorCode
        puts "EDAMUserException: #{edue}"

        # image file delete
        File.unlink(file_path)
      rescue Evernote::EDAM::Error::EDAMNotFoundException => ednfe
        ## Parent Notebook GUID doesn't correspond to an actual notebook
        puts "EDAMNotFoundException: Invalid parent notebook GUID"

        # image file delete
        File.unlink(file_path)
      end

      # image file delete
      File.unlink(file_path)

      # save post datetime
      save_evernote_post_at

      ## Return created note object
      return note
    end

    # image file save to public directory
    def save_image(url)
      file_name = get_filename(url)
      dir_name  = '/vagrant/bookinfo/public/'
      file_path = dir_name + file_name

      mechanize = Mechanize.new
      page      = mechanize.get(url)
      page.save_as(file_path)

      return file_path
    end

    # parse file name from url
    def get_filename(url)
      url =~ /([^\/]+?)([\?#].*)?$/
      $&
    end
end

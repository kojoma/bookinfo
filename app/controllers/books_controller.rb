class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy]

  # GET /books
  # GET /books.json
  def index
    @books = Book.all
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
    end

    respond_to do |format|
      if @book.save
        format.html { redirect_to @book, notice: 'Book was successfully created.' }
        format.json { render :show, status: :created, location: @book }
      else
        format.html { render :new }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1
  # PATCH/PUT /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to @book, notice: 'Book was successfully updated.' }
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
      format.html { redirect_to books_url, notice: 'Book was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def book_params
      params.require(:book).permit(:isbn, :asin, :title, :publisher, :author, :image, :description, :publish_date, :number_of_pages, :price)
    end

    # get book infomation from amazon
    def get_info
      Amazon::Ecs.debug = true
      @res = Amazon::Ecs.item_search(@book.isbn, {:search_index => 'Books', :response_group => 'Medium', :country => 'jp'})
    end
end

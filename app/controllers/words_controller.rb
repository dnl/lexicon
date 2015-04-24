class WordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dictionary
  before_action :set_word, only: [:show, :edit, :update, :destroy]

  def index
    @words = @dictionary.words.search(search_params).sort_by(&:sort_term)
    @word = new_word
  end

  def new
    @word = new_word
  end

  def edit
  end

  def create
    @word = Word.new(word_params)
    if @word.save
      if request.xhr?
        render :create
      else
        redirect_to words_path
      end
    else
      render :new
    end
  end

  # PATCH/PUT /words/1
  def update
    if @word.update(word_params)
      if request.xhr?
        render :update
      else
        redirect_to words_path
      end
    else
      render :edit
    end
  end

  def destroy
    @word.destroy
    if request.xhr?
      render :destroy
    else
      redirect_to words_path
    end
  end

  private

    def set_word
      @word = current_user.words.find(params[:id])
    end

    def set_dictionary
      @dictionary = current_user.current_dictionary
      redirect_to dictionaries_path unless @dictionary
    end

    def test_params
      params.require(:test).permit(:given_answer)
    end

    def new_word
      Word.new(dictionary: @dictionary)
    end

    # Only allow a trusted parameter "white list" through.
    def word_params
      params.require(:word).permit(
        :word_class,
        :lexical_form,
        :translation
      ).merge(dictionary_id: @dictionary.id)
    end

    def search_params
      params.permit(
        :word_class,
        :regular,
        :translation
      )
    end
end

class WordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dictionary
  before_action :set_word, only: [:show, :edit, :update, :destroy]

  def index
    @words = @dictionary.words.root_words.order(:word).sort_by(&:word)
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
        if @word.previous_changes[:word_class].present? && @word.variant_keys.present?
          render :new
        else
          render :create
        end
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
        if @word.previous_changes[:word_class].present? && @word.variant_keys.present?
          render :edit
        else
          render :update
        end
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
      Word.new(dictionary: @dictionary, word_class: Word.where.not(word_class:nil).limit(1).order(id: :desc).pluck(:word_class).first)
    end

    # Only allow a trusted parameter "white list" through.
    def word_params
      params.require(:word).permit(
        :word_class,
        :word,
        :translation,
        :pronunciation,
        :variant => [],
        :properties => [],
        :variants_attributes => [
          :_destroy,
          :id,
          :word,
          :translation,
          :pronunciation,
          :variant => []
        ]
      ).merge(dictionary_id: @dictionary.id)
    end
end

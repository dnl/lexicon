class DictionariesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dictionary, only: [:show, :edit, :update, :destroy, :test]
  def index
    @dictionaries = current_user.dictionaries
  end

  def show
    redirect_to dictionary_words_path(@dictionary)
  end

  def test

  end

  def new
    @dictionary = Dictionary.new(user: current_user)
  end

  def edit
  end

  def create
    @dictionary = Dictionary.new(dictionary_params)
    if @dictionary.save
      redirect_to @dictionary, notice: 'Dictionary was successfully created.'
    else
      render :new
    end
  end

  def update
    if @dictionary.update(dictionary_params)
      redirect_to @dictionary, notice: 'Dictionary was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @dictionary.destroy
    redirect_to dictionaries_url, notice: 'Dictionary was successfully destroyed.'
  end

  private

    def set_dictionary
      @dictionary = current_user.dictionaries.find(params[:id])
    end

    def dictionary_params
      params.require(:dictionary).permit(:name).merge(user_id: current_user.id)
    end
end

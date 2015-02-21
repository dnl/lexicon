class DictionariesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dictionary, only: [:show, :edit, :update, :destroy, :choose]
  def index
    @dictionaries = current_user.dictionaries
    redirect_to new_dictionary_path if @dictionaries.length.zero?
  end

  def choose
    select_and_view
  end

  def new
    @dictionary = Dictionary.new(user: current_user)
  end

  def edit
  end

  def create
    @dictionary = Dictionary.new(dictionary_params)
    @dictionary.user = current_user
    if @dictionary.save
      select_and_view
    else
      render :new
    end
  end

  def update
    if @dictionary.update(dictionary_params)
      select_and_view
    else
      render :edit
    end
  end

  def destroy
    @dictionary.destroy
    redirect_to dictionaries_path, notice: 'Dictionary was successfully destroyed.'
  end

  private

    def set_dictionary
      @dictionary = current_user.dictionaries.find(params[:id])
    end

    def select_and_view
      current_user.update_column(:current_dictionary_id, @dictionary.id)
      redirect_to words_path
    end

    def dictionary_params
      params.require(:dictionary).permit(
        :name,
        :word_column_label,
        :translation_column_label,
        test_type_ids: [],
        test_method_ids: []
      )
    end
end

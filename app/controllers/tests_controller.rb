class TestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dictionary
  before_action :set_test, only: :update

  def new
    @test = get_new_test
  end

  def update
    @test.update(test_params)
    if request.xhr?
      @new_test = get_new_test
      render :new
    end
  end

  private

  def test_params
    params.require(:test).permit(:given_answer)
  end

  def set_test
    @test = current_user.tests.find(params[:id])
  end

  def get_new_test
    if @dictionary.words.count < 10
      flash[:error] = 'you must have 10 words to run a test'
      redirect_to words_path
      return
    end
    Test.generate(@dictionary)
  end

  def set_dictionary
    @dictionary = current_user.current_dictionary
    redirect_to dictionaries_path unless @dictionary
  end
end
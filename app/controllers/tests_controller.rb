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
    @test = @dictionary.tests.find(params[:id])
  end

  def get_new_test
    Test.generate(@dictionary)
  end

  def set_dictionary
    @dictionary = current_user.dictionaries.find(params[:dictionary_id])
  end
end
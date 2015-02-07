Rails.application.routes.draw do

  resources :words, except: :show
  resources :tests, only: [:new, :update]
  #not restful, but I like this url style.
  resources :dictionaries, except: :show do
    member do
      post 'choose'
    end
  end

  devise_for :users

  root to: "words#index"

end

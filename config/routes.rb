Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'dashboard#index'

  get ':topic' => 'dashboard#show'
  # get ':measurement/fieldset' => 'dashboard#show'

  # get 'home/visualize'
  # get 'home/forecast'
end

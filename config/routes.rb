Rails.application.routes.draw do
  get 'search/index'

  get 'search/results'

  get 'home/index'
  root 'home#index'
  match '/timeframe', to: 'home#timeframe', via: 'post', as: 'timeframe'
  match '/title', to: 'home#title', via: 'post', as: 'title'
end

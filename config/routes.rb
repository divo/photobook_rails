Rails.application.routes.draw do
  resources :photos
  resources :photo_albums
  get 'photo_albums/:id/print', to: 'photo_albums#print', as: 'print_photo_album'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end

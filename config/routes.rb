Rails.application.routes.draw do
  root 'static_pages#home'
  resources :photos
  resources :photo_albums
  get 'photo_albums/:id/print', to: 'photo_albums#print', as: 'print_photo_album'
  put 'photo_albums/:id/set_cover', to: 'photo_albums#set_cover', as: 'set_cover_photo_album'
  delete 'photo_albums/:id/delete_page', to: 'photo_albums#delete_page', as: 'delete_page_photo_album'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end

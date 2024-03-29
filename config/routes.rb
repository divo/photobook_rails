require 'sidekiq/web'

Rails.application.routes.draw do
  mount ActionCable.server, at: '/cable'

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  root 'static_pages#home'
  get 'getting_started', to: 'static_pages#getting_started', as: 'getting_started'
  get 'privacy', to: 'static_pages#privacy', as: 'privacy'
  get 'photo-books', to: 'static_pages#photo_book', as: 'photo_book'
  get 'create-an-album', to: 'static_pages#create_an_album', as: 'create_an_album'

  resources :photos
  resources :photo_albums do
    put 'pages/:image_id/set_caption', to: 'photo_albums#set_page_caption', as: 'set_caption'
  end

  get 'photo_albums/:id/print', to: 'photo_albums#print', as: 'print_photo_album'
  put 'photo_albums/:id/set_cover', to: 'photo_albums#set_cover', as: 'set_cover_photo_album'
  delete 'photo_albums/:id/delete_page', to: 'photo_albums#delete_page', as: 'delete_page_photo_album'

  post 'checkout/create', to: 'checkout#create', as: 'checkout_create'
  get 'checkout/success', to: 'checkout#success', as: 'checkout_success'
  get 'checkout/cancel', to: 'checkout#cancel', as: 'checkout_cancel'

  resources :stripe_webhooks, only: [:create]

  resources :gelato_webhooks, only: [:create]

  get 'orders/:order_id/verify/', to: 'orders#verify', as: 'verify_order'
  post 'orders/:order_id/verify/', to: 'orders#verify_order', as: 'verify_order_post'
end

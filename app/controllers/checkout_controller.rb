class CheckoutController < ApplicationController
  before_action :authenticate_user!

  skip_before_action :verify_authenticity_token, :only => [:create]

  DOMAIN = 'https://mementos.ink'

  def create
    @session = Stripe::Checkout::Session
                 .create({
                           success_url: "#{DOMAIN}/checkout/success.html",
                           cancel_url: "#{DOMAIN}/checkout/cancel.html",
                           payment_method_types: ['card'],
                           line_items: [{ # TODO: Get the below from the album
                                          price_data: {
                                            product_data: {
                                              name: 'Mementos',
                                            },
                                            unit_amount: 1000,
                                            currency: 'eur',
                                            tax_behavior: 'exclusive',
                                          },
                                          quantity: 1
                                        }],
                           mode: 'payment',
                           metadata: { photo_album_id: '123' }, # TODO: Get the from the album
                           customer_email: current_user.email,
                         })
    redirect_to @session.url, status: 303, allow_other_host: true
  end
end
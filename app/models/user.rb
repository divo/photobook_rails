class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # Only validate reCAPTCHA on sign-up
  validate :validate_recaptcha, on: :create

  has_soft_deletion default_scope: true
  before_soft_delete :validate_deletability
  after_soft_delete :send_deletion_email

  has_many :photo_albums, dependent: :destroy

  def currency_iso
    ISO3166::Country[country_code.downcase].currency.iso_code
  end

  def send_deletion_email
    RegistrationMailer.user_delete(self).deliver_later
  end

  def validate_deletability
    nil if photo_albums
           .reject { |o| o.state == 'draft' }
           .reject { |o| o.state == 'draft_canceled' }
           .empty?
  end
end

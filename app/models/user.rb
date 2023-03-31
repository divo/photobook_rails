class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :photo_albums, dependent: :destroy

  def currency_iso
    ISO3166::Country[self.country_code.downcase].currency.iso_code
  end
end

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :dictionaries, dependent: :destroy
  belongs_to :current_dictionary, class_name: 'Dictionary', foreign_key: :current_dictionary_id
  has_many :tests, through: :dictionaries
end

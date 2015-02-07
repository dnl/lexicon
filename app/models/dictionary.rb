class Dictionary < ActiveRecord::Base
  belongs_to :user
  validates :user, presence: true
  validates :name, presence: true
  validates :name, uniqueness: {scope: :user_id}
  has_many :words, dependent: :destroy
  has_many :tests, dependent: :destroy

end

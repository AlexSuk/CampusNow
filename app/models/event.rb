class Event < ApplicationRecord

	has_many :tags, through: :event_tags
	validates :name, presence: true, length: { maximum: 50 }
	validates :description, presence: true
end

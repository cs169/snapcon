# frozen_string_literal: true

# == Schema Information
#
# Table name: rooms
#
#  id             :bigint           not null, primary key
#  discussion_url :string
#  guid           :string           not null
#  name           :string           not null
#  order          :integer
#  size           :integer
#  url            :string
#  venue_id       :integer          not null
#
class Room < ApplicationRecord
  include RevisionCount
  belongs_to :venue
  has_many :event_schedules, dependent: :destroy
  has_many :tracks

  has_paper_trail ignore: [:guid], meta: { conference_id: :conference_id }

  before_create :generate_guid

  validates :name, :venue_id, presence: true

  validates :size, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :order, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  default_scope { order(order: :asc) }

  # Cache Busting on the events page, touch all events.
  after_update :touch_conference_program
  delegate :conference, to: :venue

  def embed_url
    return if url.blank?

    if url.match?(/zoom.us/) & !url.match?('/zoom.us/wc')
      return url.gsub('/j', '/wc/join')
    end

    url
  end

  private

  def generate_guid
    guid = SecureRandom.urlsafe_base64
    self.guid = guid
  end

  def conference_id
    venue.conference_id
  end

  def touch_conference_program
    conference.program.touch
  end
end

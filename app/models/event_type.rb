# frozen_string_literal: true

# == Schema Information
#
# Table name: event_types
#
#  id                       :bigint           not null, primary key
#  color                    :string
#  description              :string
#  enable_public_submission :boolean          default(TRUE), not null
#  length                   :integer          default(30)
#  maximum_abstract_length  :integer          default(500)
#  minimum_abstract_length  :integer          default(0)
#  submission_template      :text
#  title                    :string           not null
#  created_at               :datetime
#  updated_at               :datetime
#  program_id               :integer
#
class EventType < ApplicationRecord
  belongs_to :program, touch: true
  has_many :events, dependent: :restrict_with_error

  has_paper_trail meta:   { conference_id: :conference_id },
                  ignore: %i[updated_at]

  validates :title, presence: true
  validates :length, numericality: { greater_than: 0 }
  validates :minimum_abstract_length, presence: true
  validates :maximum_abstract_length, presence: true
  validate :length_step
  validates :color, format: /\A#[0-9A-F]{6}\z/

  before_validation :capitalize_color
  before_validation :strip_title

  alias_attribute :name, :title

  scope :available_for_public, -> { where(enable_public_submission: true) }

  private

  ##
  # Check if length is a divisor of program schedule cell size. Used as validation.
  #
  def length_step
    if program && length % program.schedule_interval != 0
      errors.add(:length,
                 "must be a divisor of #{program.schedule_interval}")
    end
  end

  def capitalize_color
    self.color = color.upcase if color.present?
  end

  def conference_id
    program.conference_id
  end

  def strip_title
    self.title = title.strip unless title.nil?
  end
end

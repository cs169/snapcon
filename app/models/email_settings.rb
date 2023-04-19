# frozen_string_literal: true

# == Schema Information
#
# Table name: email_settings
#
#  id                                            :bigint           not null, primary key
#  accepted_body                                 :text
#  accepted_subject                              :string
#  booths_acceptance_body                        :text
#  booths_acceptance_subject                     :string
#  booths_rejection_body                         :text
#  booths_rejection_subject                      :string
#  cfp_dates_updated_body                        :text
#  cfp_dates_updated_subject                     :string
#  conference_dates_updated_body                 :text
#  conference_dates_updated_subject              :string
#  conference_registration_dates_updated_body    :text
#  conference_registration_dates_updated_subject :string
#  confirmed_without_registration_body           :text
#  confirmed_without_registration_subject        :string
#  program_schedule_public_body                  :text
#  program_schedule_public_subject               :string
#  registration_body                             :text
#  registration_subject                          :string
#  rejected_body                                 :text
#  rejected_subject                              :string
#  send_on_accepted                              :boolean          default(FALSE)
#  send_on_booths_acceptance                     :boolean          default(FALSE)
#  send_on_booths_rejection                      :boolean          default(FALSE)
#  send_on_cfp_dates_updated                     :boolean          default(FALSE)
#  send_on_conference_dates_updated              :boolean          default(FALSE)
#  send_on_conference_registration_dates_updated :boolean          default(FALSE)
#  send_on_confirmed_without_registration        :boolean          default(FALSE)
#  send_on_program_schedule_public               :boolean          default(FALSE)
#  send_on_registration                          :boolean          default(FALSE)
#  send_on_rejected                              :boolean          default(FALSE)
#  send_on_submitted_proposal                    :boolean          default(FALSE)
#  send_on_venue_updated                         :boolean          default(FALSE)
#  submitted_proposal_body                       :text
#  submitted_proposal_subject                    :string
#  venue_updated_body                            :text
#  venue_updated_subject                         :string
#  created_at                                    :datetime
#  updated_at                                    :datetime
#  conference_id                                 :integer
#
class EmailSettings < ApplicationRecord
  belongs_to :conference

  has_paper_trail on: [:update], ignore: [:updated_at], meta: { conference_id: :conference_id }

  def generate_event_mail(event, event_template)
    values = EmailTemplateParser.retrieve_values(event.program.conference, event.submitter, event)
    EmailTemplateParser.parse_template(event_template, values)
  end

  def generate_email_on_conf_updates(conference, user, conf_update_template)
    values = EmailTemplateParser.retrieve_values(conference, user)
    EmailTemplateParser.parse_template(conf_update_template, values)
  end

  def generate_booth_mail(booth, booth_template)
    values = EmailTemplateParser.retrieve_values(booth.conference, booth.submitter, nil, booth)
    EmailTemplateParser.parse_template(booth_template, values)
  end

  private

  def parse_template(text, values)
    values.each do |key, value|
      if value.is_a?(Date)
        text = text.gsub "{#{key}}", value.strftime('%Y-%m-%d') if text.present?
      else
        text = text.gsub "{#{key}}", value unless text.blank? || value.blank?
      end
    end
    text
  end
end

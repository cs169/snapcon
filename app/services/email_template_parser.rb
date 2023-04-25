class EmailTemplateParser
  def initialize(conference, user)
    @conference = conference
    @user = user
  end

  def retrieve_values(event = nil, booth = nil, quantity = nil, ticket = nil)
    h = {
      'email'                  => @user.email,
      'name'                   => @user.name,
      'conference'             => @conference.title,
      'conference_start_date'  => @conference.start_date,
      'conference_end_date'    => @conference.end_date,
      'registrationlink'       => Rails.application.routes.url_helpers.conference_conference_registration_url(
        @conference.short_title, host: ENV.fetch('OSEM_HOSTNAME', 'localhost:3000')
      ),
      'conference_splash_link' => Rails.application.routes.url_helpers.conference_url(
        @conference.short_title, host: ENV.fetch('OSEM_HOSTNAME', 'localhost:3000')
      ),

      'schedule_link'          => Rails.application.routes.url_helpers.conference_schedule_url(
        @conference.short_title, host: ENV.fetch('OSEM_HOSTNAME', 'localhost:3000')
      )
    }
    if @conference.program.cfp
      h['cfp_start_date'] = @conference.program.cfp.start_date
      h['cfp_end_date'] = @conference.program.cfp.end_date
    else
      h['cfp_start_date'] = 'Unknown'
      h['cfp_end_date'] = 'Unknown'
    end
    if @conference.venue
      h['venue'] = @conference.venue.name
      h['venue_address'] = @conference.venue.address
    else
      h['venue'] = 'Unknown'
      h['venue_address'] = 'Unknown'
    end
    if @conference.registration_period
      h['registration_start_date'] = @conference.registration_period.start_date
      h['registration_end_date'] = @conference.registration_period.end_date
    end
    if event
      h['eventtitle'] = event.title
      h['proposalslink'] = Rails.application.routes.url_helpers.conference_program_proposals_url(
        @conference.short_title, host: ENV.fetch('OSEM_HOSTNAME', 'localhost:3000')
      )
      h['committee_review'] = event.committee_review
      h['committee_review_html'] = ApplicationController.helpers.markdown(event.committee_review)
    end
    if booth
      h['booth_title'] = booth.title
    end
    if quantity
      h['ticket_quantity'] = quantity.to_s
    end
    if ticket
      h['ticket_title'] = ticket.title
      h['ticket_purchase_id'] = ticket.id.to_s
    end
    h
  end

  def self.parse_template(text, values)
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

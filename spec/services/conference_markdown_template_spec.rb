# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ConferenceMarkdownTemplate do
  describe '.interpolate' do
    it 'returns empty string for blank text' do
      conference = build(:conference)
      expect(described_class.interpolate('', conference)).to eq('')
      expect(described_class.interpolate(nil, conference)).to eq('')
    end

    it 'returns original text when conference is blank' do
      expect(described_class.interpolate('{conference}', nil)).to eq('{conference}')
    end

    it 'substitutes conference values, CFP (events), venue, registration, and public event type count' do
      conference = create(:full_conference)
      conference.program.event_types.first.update!(enable_public_submission: false)
      create(:event_type, program: conference.program, title: 'Poster', enable_public_submission: true)

      events_cfp = conference.program.cfps.find_by!(cfp_type: 'events')
      template = <<~TEXT.squish
        {conference} / {conference_short}
        {conference_name} / {short_name}
        {start_date}–{end_date} {timezone}
        CFP {cfp_start_date}–{cfp_end_date} deadline {cfp_deadline}
        {venue} — {venue_address}
        Reg {registration_start_date}–{registration_end_date}
        Public types: {num_public_event_types}
      TEXT

      result = described_class.interpolate(template, conference)

      expect(result).to include(conference.title)
      expect(result).to include(conference.short_title)
      expect(result).to include("#{conference.start_date.strftime('%Y-%m-%d')}–#{conference.end_date.strftime('%Y-%m-%d')}")
      expect(result).to include(conference.timezone)
      expect(result).to include("#{events_cfp.start_date.strftime('%Y-%m-%d')}–#{events_cfp.end_date.strftime('%Y-%m-%d')}")
      expect(result).to include(conference.venue.name)
      expect(result).to include(conference.venue.address)
      expect(result).to include(
        "#{conference.registration_period.start_date.strftime('%Y-%m-%d')}–#{conference.registration_period.end_date.strftime('%Y-%m-%d')}"
      )
      expect(result).to include('Public types: 2')
    end

    it 'uses empty strings for optional sections when not configured (but still counts default public event types)' do
      conference = create(:conference)
      conference.program.cfps.destroy_all
      conference.venue&.destroy
      conference.registration_period&.destroy
      conference.reload

      template = 'CFP:{cfp_end_date}|Venue:{venue}|Reg:{registration_end_date}|Types:{num_public_event_types}'
      result = described_class.interpolate(template, conference)

      expect(result).to eq('CFP:|Venue:|Reg:|Types:2')
    end
  end
end

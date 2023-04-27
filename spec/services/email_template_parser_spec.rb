require 'spec_helper'

describe EmailTemplateParser do
    let(:conference) { double("Conference", title: "Test Conference", short_title: "test-conf", start_date: Date.today, end_date: Date.today + 2.days, program: double("Program", cfp: double("Cfp", start_date: Date.today - 10.days, end_date: Date.today - 8.days))) }
    let(:user) { double("User", name: "John Doe", email: "john.doe@example.com") }
    let(:event) { double("Event", title: "Test Event", committee_review: "Some review text") }
    let(:booth) { double("Booth", title: "Test Booth") }
    let(:quantity) { 5 }
    let(:ticket) { double("Ticket", title: "Test Ticket", id: 1234) }
  
    describe "#retrieve_values" do
      it "returns a hash with user and conference values" do
        parser = EmailTemplateParser.new(conference, user)
        values = parser.retrieve_values
        expect(values['email']).to eq(user.email)
        expect(values['name']).to eq(user.name)
        expect(values['conference']).to eq(conference.title)
        expect(values['conference_start_date']).to eq(conference.start_date)
        expect(values['conference_end_date']).to eq(conference.end_date)
      end
  
      it "returns a hash with registration and venue values" do
        conference.registration_period = double("RegistrationPeriod", start_date: Date.today - 7.days, end_date: Date.today - 5.days)
        conference.venue = double("Venue", name: "Test Venue", address: "123 Main St")
        parser = EmailTemplateParser.new(conference, user)
        values = parser.retrieve_values
        expect(values['registration_start_date']).to eq(conference.registration_period.start_date)
        expect(values['registration_end_date']).to eq(conference.registration_period.end_date)
        expect(values['venue']).to eq(conference.venue.name)
        expect(values['venue_address']).to eq(conference.venue.address)
      end
  
      it "returns a hash with event, booth, quantity, and ticket values" do
        parser = EmailTemplateParser.new(conference, user)
        values = parser.retrieve_values(event, booth, quantity, ticket)
        expect(values['eventtitle']).to eq(event.title)
        expect(values['proposalslink']).to include(conference.short_title)
        expect(values['committee_review']).to eq(event.committee_review)
        expect(values['booth_title']).to eq(booth.title)
        expect(values['ticket_quantity']).to eq(quantity.to_s)
        expect(values['ticket_title']).to eq(ticket.title)
        expect(values['ticket_purchase_id']).to eq(ticket.id.to_s)
      end
    end
    
    describe '.parse_template' do
        let(:text) { 'Hello {name}, welcome to {conference}!' }
        let(:values) { { 'name' => 'John', 'conference' => 'Conference X' } }

        it 'replaces placeholders with values' do
        expect(described_class.parse_template(text, values)).to eq('Hello John, welcome to Conference X!')
        end

        context 'when value is a date' do
        let(:text) { 'The conference starts on {conference_start_date}.' }
        let(:values) { { 'conference_start_date' => Date.parse('2023-05-01') } }

        it 'formats the date correctly' do
            expect(described_class.parse_template(text, values)).to eq('The conference starts on 2023-05-01.')
        end
        end

        context 'when value is blank' do
        let(:text) { 'Welcome, {name}!' }
        let(:values) { { 'name' => nil } }

        it 'removes the placeholder' do
            expect(described_class.parse_template(text, values)).to eq('Welcome, !')
        end
        end

        context 'when text is blank' do
        let(:text) { '' }
        let(:values) { { 'name' => 'John', 'conference' => 'Conference X' } }

        it 'returns an empty string' do
            expect(described_class.parse_template(text, values)).to eq('')
        end
        end
    end
end


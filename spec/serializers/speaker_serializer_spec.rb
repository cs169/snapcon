# frozen_string_literal: true

require 'spec_helper'
describe SpeakerSerializer, type: :serializer do
  let(:speaker) { create(:user, name: 'John Doe', affiliation: 'JohnDoesInc', biography: nil) }
  let(:serializer) { SpeakerSerializer.new(speaker) }

  context 'speaker does not have biography' do
    it 'sets name and affiliation' do
      expected_json = {
        url:         "http://localhost:3000/users/#{speaker.id}",
        name:        'John Doe',
        affiliation: 'JohnDoesInc',
        biography:   nil
      }.to_json

      expect(serializer.to_json).to eq expected_json
    end
  end

  context 'speaker has biography' do
    before { speaker.update_attribute(:biography, 'Doest of all Jon Does') }

    it 'sets name, affiliation and biography' do
      expected_json = {
        url:         "http://localhost:3000/users/#{speaker.id}",
        name:        'John Doe',
        affiliation: 'JohnDoesInc',
        biography:   'Doest of all Jon Does'
      }.to_json

      expect(serializer.to_json).to eq expected_json
    end
  end
end

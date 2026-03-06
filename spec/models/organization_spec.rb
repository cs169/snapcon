# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id              :bigint           not null, primary key
#  code_of_conduct :text
#  description     :text
#  name            :string           not null
#  picture         :string
#
require 'spec_helper'

describe Organization do
  let(:organization) { create(:organization) }

  describe 'validation' do
    it 'is not valid without a name' do
      pending 'TODO-SNAPCON: Investigate validation test failure'
      expect(subject).to validate_presence_of(:name)
    end
  end

  describe 'associations' do
    it 'has many conferences with dependent destroy' do
      pending 'TODO-SNAPCON: Investigate association test failure'
      expect(subject).to have_many(:conferences).dependent(:destroy)
    end
  end
end

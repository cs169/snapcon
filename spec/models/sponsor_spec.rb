# frozen_string_literal: true

# == Schema Information
#
# Table name: sponsors
#
#  id                   :bigint           not null, primary key
#  description          :text
#  logo_file_name       :string
#  name                 :string
#  picture              :string
#  website_url          :string
#  created_at           :datetime
#  updated_at           :datetime
#  conference_id        :integer
#  sponsorship_level_id :integer
#
require 'spec_helper'

describe Sponsor do
  describe 'validations' do
    it 'is not valid without a name' do
      expect(subject).to validate_presence_of(:name)
    end

    it 'is not valid without a website url' do
      expect(subject).to validate_presence_of(:website_url)
    end
  end
end

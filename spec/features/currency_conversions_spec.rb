# frozen_string_literal: true

require 'spec_helper'

describe CurrencyConversion do
  let!(:conference) { create(:conference, title: 'ExampleCon') }
  let!(:admin) { create(:admin) }

  context 'as a organizer' do
    before do
      sign_in admin
    end

    after do
      sign_out
    end

    it 'add a currency conversion', feature: true do
      visit admin_conference_currency_conversions_path(conference.short_title)
      click_link 'Add Currency Conversion'

      fill_in 'currency_conversion_from_currency', with: 'USD'
      fill_in 'currency_conversion_to_currency', with: 'EUR'
      fill_in 'currency_conversion_rate', with: '0.89'

      click_button 'Create Currency conversion'
      page.find('#flash')
      expect(flash).to eq('Currency conversion was successfully created.')
      within('table#currency_conversions') do
        expect(page.has_content?('USD')).to be true
        expect(page.has_content?('EUR')).to be true
        expect(page.assert_selector('tr', count: 1)).to be true
      end
    end

    it 'Deletes Currency Conversion', feature: true, js: true do
      visit admin_conference_currency_conversions_path(conference.short_title)

      # Remove currency conversion
      within('table#currency_conversions tr:nth-of-type(1)') do
        click_link 'Delete'
      end
      page.accept_alert
      page.find('#flash')

      # Validations
      expect(flash).to eq('Difficulty level successfully deleted.')
      expect(page.assert_selector('tr', count: 0)).to be true
    end
  end
end

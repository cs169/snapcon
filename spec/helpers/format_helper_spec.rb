# frozen_string_literal: true

require 'spec_helper'

describe FormatHelper, type: :helper do
  describe 'markdown' do
    it 'returns empty string for nil' do
      expect(markdown(nil)).to eq ''
    end

    it "doesn't render links with unsafe URI schemes" do
      expect(markdown('[a](javascript:b)')).to eq "<p>[a](javascript:b)</p>\n"
    end

    it 'returns HTML for header markdown' do
      expect(markdown('# this is my header')).to eq "<h1>this is my header</h1>\n"
    end

    it 'escapes input HTML' do
      expect(markdown('<em>*a*</em>')).to eq "<p>&lt;em&gt;<em>a</em>&lt;/em&gt;</p>\n"
    end

    it 'removes unallowed elements' do
      expect(markdown('<em>*<style>a</style>*</em>', false)).to eq "<p><em><em>a</em></em></p>\n"
    end

    it 'sets nofollow on links' do
      expect(markdown('[a](https://example.com/)'))
        .to eq "<p><a href=\"https://example.com/\" rel=\"nofollow\">a</a></p>\n"
    end
  end
end

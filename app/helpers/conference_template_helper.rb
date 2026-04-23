# frozen_string_literal: true

module ConferenceTemplateHelper
  def conference_template_markdown(text, conference, escape_html: false)
    interpolated = ConferenceMarkdownTemplate.interpolate(text, conference)
    markdown(interpolated, escape_html)
  end
end

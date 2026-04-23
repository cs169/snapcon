# frozen_string_literal: true

# Interpolates `{token}` placeholders in conference-facing Markdown fields.
#
# This intentionally mirrors the `{key}` substitution style used by
# `EmailTemplateParser`, but only exposes conference-scoped values (no user).
class ConferenceMarkdownTemplate
  KNOWN_TEMPLATE_KEYS = %w[
    conference conference_short start_date end_date timezone
    cfp_start_date cfp_end_date
    venue venue_address
    registration_start_date registration_end_date
    num_public_event_types
  ].freeze

  def self.interpolate(text, conference)
    return '' if text.blank?
    return text if conference.blank?

    values = build_values(conference)
    substituted = EmailTemplateParser.parse_template(text, values)

    # Aliases / friendlier names for issue descriptions
    alias_map = {
      'conference_name' => 'conference',
      'short_name' => 'conference_short',
      'cfp_deadline' => 'cfp_end_date'
    }

    alias_map.each do |from, to|
      raw = values[to]
      replacement =
        if raw.is_a?(Date)
          raw.strftime('%Y-%m-%d')
        else
          raw.presence || ''
        end

      substituted = substituted.gsub("{#{from}}", replacement)
    end

    # `EmailTemplateParser.parse_template` skips blank values, which leaves tokens
    # like `{cfp_end_date}` in place when optional sections are empty. For
    # conference-facing Markdown we prefer removing those placeholders entirely.
    substituted = substitute_known_keys(substituted, values)

    substituted
  end

  def self.substitute_known_keys(text, values)
    return text if text.blank?

    KNOWN_TEMPLATE_KEYS.each do |key|
      next unless text.include?("{#{key}}")

      raw = values[key]
      replacement =
        if raw.is_a?(Date)
          raw.strftime('%Y-%m-%d')
        else
          raw.presence || ''
        end

      text = text.gsub("{#{key}}", replacement)
    end

    text
  end

  def self.build_values(conference)
    h = {
      'conference' => conference.title,
      'conference_short' => conference.short_title,
      'start_date' => conference.start_date,
      'end_date' => conference.end_date,
      'timezone' => conference.timezone
    }

    events_cfp = conference.program&.cfps&.find_by(cfp_type: 'events')
    if events_cfp
      h['cfp_start_date'] = events_cfp.start_date
      h['cfp_end_date'] = events_cfp.end_date
    else
      h['cfp_start_date'] = ''
      h['cfp_end_date'] = ''
    end

    if conference.venue
      h['venue'] = conference.venue.name
      h['venue_address'] = conference.venue.address
    else
      h['venue'] = ''
      h['venue_address'] = ''
    end

    if conference.registration_period
      h['registration_start_date'] = conference.registration_period.start_date
      h['registration_end_date'] = conference.registration_period.end_date
    else
      h['registration_start_date'] = ''
      h['registration_end_date'] = ''
    end

    if conference.program
      h['num_public_event_types'] = conference.program.event_types.available_for_public.count.to_s
    else
      h['num_public_event_types'] = '0'
    end

    h
  end
end

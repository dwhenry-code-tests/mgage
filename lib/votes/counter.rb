module Votes
  class Counter
    VALID_VALIDITY_VALUE = 'during'
    VALIDITY_REGEX = /Validity:([^ ]+)/
    CAMPAIGN_REGEX = /Campaign:([^ ]+)/
    CHOICE_REGEX = /Choice:([^ ]+)/
    VALIDATION_REGEX = /^VOTE \d+ #{CAMPAIGN_REGEX} #{VALIDITY_REGEX} #{CHOICE_REGEX} CONN:[^ ]+ MSISDN:[^ ]+ GUID:[^ ]+ Shortcode:[^ ]+$/

    attr_accessor :counts

    def initialize(io_stream)
      @io_stream = io_stream
      @counts = Hash.new { |h, k| h[k] = Hash.new(0) }
      process_file
    end

    def process_file
      while !@io_stream.eof do
        line = @io_stream.readline

        valid_line = validate_line(line)

        campaign = regex_value(line, CAMPAIGN_REGEX)
        choice = regex_value(line, CHOICE_REGEX)
        key = [campaign, choice]

        valid = valid_line && regex_value(line, VALIDITY_REGEX) == VALID_VALIDITY_VALUE
        validity = valid ? :votes : :invalid_votes

        @counts[key][validity] += 1
      end
    end

    private

    def validate_line(line)
      if line.valid_encoding?
        line =~ VALIDATION_REGEX
      else
        # this is required for future regex to work
        line.force_encoding('binary')

        # line with invalid encoding (ie. contain non UTF-8 characters)
        # are considered invalid
        false
      end
    end

    def regex_value(line, regex)
      match = line.match(regex)
      match && match[1]
    end
  end
end

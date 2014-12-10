module Votes
  class Importer
    def self.import(campaign_name, file_path)
      # count the votes
      io_stream = File.open(file_path)
      Counter.new(io_stream)

      # save votes to database
    end
  end

  class Counter
    VALIDITY_REGEX = /Validity:([^ ]+)/
    VALID_VALIDITY_VALUE = 'during'
    CAMPAIGN_REGEX = /Campaign:([^ ]+)/
    CHOICE_REGEX = /Choice:([^ ]+)/
    VALIDATION_REGEX = /^VOTE \d+ #{CAMPAIGN_REGEX} #{VALIDITY_REGEX} #{CHOICE_REGEX} CONN:[^ ]+ MSISDN:[^ ]+ GUID:[^ ]+ Shortcode:[^ ]+$/

    def initialize(io_stream)
      @io_stream = io_stream
      @result = Hash.new { |h, k| h[k] = Hash.new(0) }
    end

    def count
      while !@io_stream.eof do
        line = @io_stream.readline

        if line.valid_encoding?
          valid_line = line =~ VALIDATION_REGEX
        else
          # non utf-8 characters in the string mark it as invalid
          valid_line = false
          # this is required for future regex to work
          line.force_encoding('binary')
        end

        campaign = regex_value(line, CAMPAIGN_REGEX)
        choice = regex_value(line, CHOICE_REGEX)
        key = [campaign, choice]

        valid = valid_line && regex_value(line, VALIDITY_REGEX) == VALID_VALIDITY_VALUE
        validity = valid ? :valid : :invalid

        @result[key][validity] += 1
      end
      @result
    end

    private

    def regex_value(line, regex)
      match = line.match(regex)
      match && match[1]
    end
  end
end

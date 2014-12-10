module Votes
  class MissingFilename < StandardError; end
  class MissingFile < StandardError; end

  class Importer
    def self.import(file_path)
      if file_path.blank?
        raise Votes::MissingFilename
      elsif not File.exists?(file_path)
        raise Votes::MissingFile
      end

      begin
        io_stream = File.open(file_path)
        counter = Counter.new(io_stream)
      ensure
        io_stream.try(:close)
      end

      counter.counts.each do |(campaign_name, choice_name), counts|
        campaign = Campaign.find_or_create_by(name: campaign_name)
        choice = campaign.choices.find_or_initialize_by(name: choice_name)
        choice.votes ||= 0
        choice.invalid_votes ||= 0
        choice.votes += counts[:valid] if counts[:valid]
        choice.invalid_votes += counts[:invalid] if counts[:invalid]
        choice.save!
      end
    end
  end

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
        validity = valid ? :valid : :invalid

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

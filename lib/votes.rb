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
    REGEX = /^VOTE \d+ Campaign:([^ ]+) Validity:([^ ]*) Choice:([^ ]*) CONN:[^ ]+ MSISDN:[^ ]+ GUID:[^ ]+ Shortcode:[^ ]+$/

    def initialize(io_stream)
      @io_stream = io_stream
      @result = Hash.new { |h, k| h[k] = Hash.new(0) }
    end

    def count
      while !@io_stream.eof do
        line = @io_stream.readline

        if line.valid_encoding? && match = line.match(REGEX)
          campaign = match[1]
          choice = match[3] == '' ? nil : match[3]
          valid = (choice && match[2] == 'during')
          validity = valid ? :valid : :invalid
          key = choice && [campaign, choice]
          @result[key][validity] += 1
        else
          @result[nil][:invalid] += 1
        end
      end
      @result
    end
  end
end

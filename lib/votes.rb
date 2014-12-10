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
    REGEX = /^VOTE \d+ Campaign:[^ ]+ Validity:([^ ]*) Choice:([^ ]*) CONN:[^ ]+ MSISDN:[^ ]+ GUID:[^ ]+ Shortcode:[^ ]+$/
    def initialize(io_stream)
      @io_stream = io_stream
      @result = Hash.new { |h, k| h[k] = { valid: 0, invalid: 0 } }
    end

    def count
      while !@io_stream.eof do
        line = @io_stream.readline
        match = line.match(REGEX)
        if match
          validity = match[1] == 'during' ? :valid : :invalid
          choice = match[2]
          if choice == ''
            @result[nil][:invalid] += 1
          else
            @result[choice][validity] += 1
          end
        else
          @result[nil][:invalid] += 1
        end

      end
      @result
    end
  end
end

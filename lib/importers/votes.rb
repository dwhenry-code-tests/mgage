require 'counters/votes'

module Importers
  class Votes
    def self.import(campaign_name, file_path)
      # count the votes
      io_stream = File.open(file_path)
      Counters::Votes.new(io_stream)

      # save votes to database
    end
  end
end

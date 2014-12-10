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
    def initialize(io_stream)

    end

    def count
      {"Antony"=>{:valid=>1, :invalid=>0}}
    end
  end
end

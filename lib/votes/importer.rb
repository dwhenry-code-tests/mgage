require 'votes/counter'

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
        counter = Votes::Counter.new(io_stream)
      ensure
        io_stream.try(:close)
      end

      counter.counts.each do |(campaign_name, choice_name), counts|
        campaign = Campaign.find_or_create_by(name: campaign_name)
        choice = campaign.choices.find_or_initialize_by(name: choice_name)
        choice.votes ||= 0
        choice.invalid_votes ||= 0
        choice.votes += counts[:votes] if counts[:votes]
        choice.invalid_votes += counts[:invalid_votes] if counts[:invalid_votes]
        choice.save!
      end
    end
  end
end

require 'rails_helper'
require 'votes/importer'

describe Votes::Importer do
  let(:io_stream) { StringIO.new("") }
  let(:data_file_path) { Tempfile.new('temp').path }
  let(:counts) { { ['camp_1', 'choice_a'] => { votes: 10, invalid_votes: 5 } } }
  let(:counter) { double('Votes::Counter', counts: counts) }

  context 'when the file is valid' do
    before do
      allow(File).to receive(:open).with(data_file_path).and_return(io_stream)
      allow(Votes::Counter).to receive(:new).and_return(counter)
    end

    it 'gets the count of votes for each contestant' do
      expect(Votes::Counter).to receive(:new).with(io_stream)
      described_class.import(data_file_path)
    end
  end

  context 'when filename is nil' do
    it 'raises a MissingFilename error' do
      expect{ described_class.import(nil) }.to raise_error(Votes::MissingFilename)
    end
  end

  context 'when file does not exist' do
    it 'raises a MissingFile error' do
      expect{ described_class.import('apple') }.to raise_error(Votes::MissingFile)
    end
  end

  context 'saving votes to the database' do
    before do
      allow(File).to receive(:open).with(data_file_path).and_return(io_stream)
      allow(Votes::Counter).to receive(:new).and_return(counter)
    end

    context 'when campaign does not already exists' do
      it 'creates the campaign' do
        expect do
          described_class.import(data_file_path)
        end.to change {
          Campaign.count
        }.by(1)
      end

      it 'create vote data for the choices' do
        expect do
          described_class.import(data_file_path)
        end.to change {
          Choice.count
        }.by(1)
      end

      it 'sets the correct number of votes and invalid_votes' do
        described_class.import(data_file_path)
        choice = Choice.last
        # TODO: move to custom matchers and use rspec 3 `and` functionality
        expect(choice.votes).to eq(10)
        expect(choice.invalid_votes).to eq(5)
      end
    end

    context 'when campaign and choice already exists' do
      let(:campaign) { Campaign.create(name: 'camp_1') }
      let!(:choice) { Choice.create(name: 'choice_a', campaign: campaign, votes: 3, invalid_votes: 5) }

      it 'does not create a new campaign' do
        expect do
          described_class.import(data_file_path)
        end.not_to change {
          Campaign.count
        }
      end

      it 'does not create a new choice' do
        expect do
          described_class.import(data_file_path)
        end.not_to change {
          Choice.count
        }
      end

      it 'correctly updates the existing choice' do
        described_class.import(data_file_path)
        choice = Choice.last
        # TODO: move to custom matchers and use rspec 3 `and` functionality
        expect(choice.votes).to eq(3 + 10)
        expect(choice.invalid_votes).to eq(5 + 5)
      end
    end
  end
end


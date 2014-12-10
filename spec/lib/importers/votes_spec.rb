require 'spec_helper'
require 'importers/votes'
require 'counters/votes'

describe Importers::Votes do
  let(:io_stream) { double }
  let(:data_file_path) { double }
  let(:campaign_name) { double }
  before do
    allow(File).to receive(:open).with(data_file_path).and_return(io_stream)
  end

  it 'gets the count of votes for each contestant' do
    expect(Counters::Votes).to receive(:new).with(io_stream)
    described_class.import(campaign_name, data_file_path)
  end

  xit 'save the votes to the database' do

  end
end

require 'spec_helper'
require 'votes'

describe Votes::Importer do
  let(:io_stream) { double }
  let(:data_file_path) { double }
  let(:campaign_name) { double }
  before do
    allow(File).to receive(:open).with(data_file_path).and_return(io_stream)
  end

  it 'gets the count of votes for each contestant' do
    expect(Votes::Counter).to receive(:new).with(io_stream)
    described_class.import(campaign_name, data_file_path)
  end

  xit 'save the votes to the database' do

  end
end


describe Votes::Counter do
  context 'when only a single valid vote exists' do
    let(:input_stream) { String.new("VOTE 1168041805 Campaign:ssss_uk_01B Validity:during Choice:Antony CONN:MIG01TU MSISDN:00777778359999 GUID:E6109CA1-7756-45DC-8EE7-677CA7C3D7F3 Shortcode:63334\n")}

    it 'counts the votes' do
      counter = described_class.new(input_stream)
      expect(counter.count).to eq(
        "Antony" => {
          valid: 1,
          invalid: 0
        }
      )
    end
  end
end

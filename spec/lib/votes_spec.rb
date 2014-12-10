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
  let(:input_stream) { StringIO.new(input_strings.join()) }
  context 'when only a single valid vote exists' do
    let(:input_strings) { [vote_for("Antony")] }

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

  context 'when two different votes for exist' do
    let(:input_strings) { [vote_for('john'), vote_for('frank')] }

    it 'counts the votes' do
      counter = described_class.new(input_stream)
      expect(counter.count).to eq(
        "john" => { valid: 1, invalid: 0 },
        "frank" => { valid: 1, invalid: 0 },
      )
    end
  end

  context 'when pre vote exists' do
    let(:input_strings) { [pre_vote_for('john')] }

    it 'counts the votes' do
      counter = described_class.new(input_stream)
      expect(counter.count).to eq(
        "john" => { valid: 0, invalid: 1 },
      )
    end
  end

  context 'when validate vote without a name' do
    let(:input_strings) { [vote_for('')] }

    it 'counts the votes' do
      counter = described_class.new(input_stream)
      expect(counter.count).to eq(
        nil => { valid: 0, invalid: 1 },
      )
    end
  end

  context 'when line is not well formed' do
    let(:input_strings) { ["Validity:during Choice:john"] }

    it 'counts the votes' do
      counter = described_class.new(input_stream)
      expect(counter.count).to eq(
        nil => { valid: 0, invalid: 1 },
      )
    end
  end

  def vote_for(choice, validity='during')
    "VOTE 1168041805 Campaign:ssss_uk_01B Validity:#{validity} Choice:#{choice} CONN:MIG01TU MSISDN:00777778359999 GUID:E6109CA1-7756-45DC-8EE7-677CA7C3D7F3 Shortcode:63334\n"
  end

  def pre_vote_for(choice)
    vote_for(choice, 'pre')
  end
end

require 'spec_helper'
require 'tempfile'
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
        ["ssss_uk_01B", "Antony"] => { valid: 1 }
      )
    end
  end

  context 'when two different votes for exist' do
    let(:input_strings) { [vote_for('john'), vote_for('frank')] }

    it 'counts the votes' do
      counter = described_class.new(input_stream)
      expect(counter.count).to eq(
        ["ssss_uk_01B", "john"] => { valid: 1 },
        ["ssss_uk_01B", "frank"] => { valid: 1 },
      )
    end
  end

  context 'when `pre` validity vote' do
    let(:input_strings) { [pre_vote_for('john')] }

    it 'vote is invalid' do
      counter = described_class.new(input_stream)
      expect(counter.count).to eq(
        ["ssss_uk_01B", "john"] => { invalid: 1 },
      )
    end
  end

  context 'when `post` validity vote' do
    let(:input_strings) { [post_vote_for('john')] }

    it 'vote is invalid' do
      counter = described_class.new(input_stream)
      expect(counter.count).to eq(
        ["ssss_uk_01B", "john"] => { invalid: 1 },
      )
    end
  end

  context 'when valid vote without a name' do
    let(:input_strings) { [vote_for('')] }

    it 'vote is invalid' do
      counter = described_class.new(input_stream)
      expect(counter.count).to eq(
        ["ssss_uk_01B", nil] => { invalid: 1 },
      )
    end
  end

  context 'when line is not well formed' do
    let(:input_strings) { ["Validity:during Choice:john"] }

    it 'vote is invalid' do
      counter = described_class.new(input_stream)
      expect(counter.count).to eq(
        [nil, "john"] => { invalid: 1 },
      )
    end
  end

  context 'when line contains non-utf8 characters' do
    let(:input_strings) { ["VOTE 1168123287 Campaign:ssss_uk_02A Validity:during Choice:Antony CONN:MIG01XU MSISDN:00777779989999 GUID:029DBA7C-26E7-4F82-BAE9-2DEC2C665F6B Shortcode:63334\xA1\n"] }

    it 'vote is invalid' do
      counter = described_class.new(input_stream)
      expect(counter.count).to eq(
        ["ssss_uk_02A", "Antony"] => { invalid: 1 },
      )
    end
  end

  def vote_for(choice, validity='during')
    "VOTE 1168041805 Campaign:ssss_uk_01B Validity:#{validity} Choice:#{choice} CONN:MIG01TU MSISDN:00777778359999 GUID:E6109CA1-7756-45DC-8EE7-677CA7C3D7F3 Shortcode:63334\n"
  end

  def pre_vote_for(choice)
    vote_for(choice, 'pre')
  end

  def post_vote_for(choice)
    vote_for(choice, 'post')
  end
end

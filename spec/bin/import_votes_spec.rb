require 'rails_helper'

describe 'import_votes script' do
  let(:votes_file_path) { File.join(File.dirname(__FILE__), '/votes.txt') }

  context 'when called correctly' do
    it 'imports and stores data in the database' do
      `'#{Rails.root}/bin/import_votes' '#{votes_file_path}'`

      expect(Campaign.count).to eq(1)
      expect(Choice.count).to eq(3)
    end
  end

  context 'when called without a filename' do
    it 'imports and stores data in the database' do
      output = `'#{Rails.root}/bin/import_votes'`

      expect(output).to eq("Error during processing: Votes::MissingFilename\nUSAGE: bin/import_votes <filename>\n")
    end
  end
end

# spec/group_form_parser_spec.rb

require 'rails_helper'

RSpec.describe FosParser, type: :model do
  before(:each) do
      Runner.create!(runner_name: "Fala", surname: "Sergiu", dob: "1993-05-26", gender: "M", category_id: 6, id: 273)
  end

  describe '#convert' do
    it 'passes flow with json data' do
      parser = FosParser.new
      path   = Rails.root.join('test', 'fixtures', 'files', 'fos.html')
      allow(parser).to receive(:connect).and_return(Nokogiri::HTML(File.read(path)))

      expect { parser.convert }
      .to change { Competition.count }.by(0)
      .and change { Group.count }.by(0)
      .and change { Result.count }.by(2)
      .and change { Runner.count }.by(1)
      .and change { Club.count }.by(2)
      .and change { Entry.count }.by(2)


      expect(Runner.order("created_at").last.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"               => 1,
        "runner_name"      => "Golovei",
        "surname"          => "Andrei",
        "gender"           => "M",
        "dob"              => "1993-01-01".to_date,
        "checksum"         => (Digest::SHA2.new << "Golovei-Andrei-1993-M").to_s,
        "category_id"      => 2,
        "best_category_id" => 2,
        "category_valid"   => "2024-09-25".to_date,
        "club_id"          => 2
      })

      expect(Result.first.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"          => 1,
        "date"        => "2022-09-25".to_date,
        "runner_id"   => 1,
        "group_id"    => 1,
        "category_id" => 2,
        "time"        => 0
      })

      expect(Entry.last.attributes.except('created_at', 'updated_at').compact).to eq({
        "date"        => "2023-09-19".to_date,
        "id"          => 2,
        "runner_id"   => 273,
        "category_id" => 3,
        "result_id"   => 2,
        "status"      => "confirmed",
      })

    end
  end
end

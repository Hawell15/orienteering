# spec/group_form_parser_spec.rb

require 'rails_helper'

RSpec.describe ExcelResultsParser, type: :model do
  before(:each) do
      Runner.create!(runner_name: "Fala", surname: "Sergiu", dob: "1993-05-26", gender: "M", category_id: 6)
      Runner.create!(id: 240, category_id: 1)
  end

  describe '#convert' do
    it 'passes flow with json data' do
      path   = Rails.root.join('test', 'fixtures', 'files', 'rezultate.xlsx').to_s
      parser = ExcelResultsParser.new(path)
      expect { @competition = parser.convert }
      .to change { Competition.count }.by(3)
      .and change { Group.count }.by(3)
      .and change { Result.count }.by(3)
      .and change { Runner.count }.by(1)
      .and change { Club.count }.by(2)
      .and change { Entry.count }.by(2)

      expect(@competition).to eq(Competition.last)

      expect(@competition.attributes.except('created_at', 'updated_at').compact).to eq({
        'id'               => 4,
        'competition_name' => 'Camp Moldovei',
        'date'             => '2023-06-15'.to_date,
        'distance_type'    => 'Sprint',
        'checksum'         => (Digest::SHA2.new << "Camp Moldovei-2023-06-15-Sprint-").to_s,
        'location'         => 'Chisinau',
        'country'          => 'Moldova'
      })

      expect(Group.last.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"             => 4,
        "group_name"     => "M21",
        "competition_id" => 4
      })
      expect(Club.last.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"                    => 2,
        "club_name"             => "Dinamo OLD",
        "formatted_name"        => "dinamoold"
      })

      expect(Runner.last.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"               => 241,
        "runner_name"      => "TestRRR",
        "surname"          => "rrr",
        "gender"           => "W",
        "dob"              => "1995-10-23".to_date,
        "checksum"         => (Digest::SHA2.new << "TestRRR-rrr-1995-W").to_s,
        "category_id"      => 10,
        "best_category_id" => 5,
        "category_valid"   => "2100-01-01".to_date,
        "club_id"          => 2
      })

      expect(Result.second.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"          => 2,
        "date"        => "2023-12-10".to_date,
        "runner_id"   => 241,
        "group_id"    => 3,
        "category_id" => 5,
        "time"        => 2710,
        "place"       => 6
      })

      expect(Entry.first.attributes.except('created_at', 'updated_at').compact).to eq({
        "date"        => "2023-12-10".to_date,
        "id"          => 1,
        "runner_id"   => 241,
        "category_id" => 5,
        "result_id"   => 2,
        "status"      => "unconfirmed",
      })
    end
  end
end

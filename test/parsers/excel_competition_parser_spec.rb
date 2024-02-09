# spec/group_form_parser_spec.rb

require 'rails_helper'

RSpec.describe ExcelCompetitionParser, type: :model do
  before(:each) do
      Runner.create!(runner_name: "Ciobanu", surname: "Roman", dob: "1991-02-15", gender: "M", category_id: 6)
      Runner.create!(id: 273, category_id: 2)
  end

  describe '#convert' do
    it 'passes flow with json data' do
      path   = Rails.root.join('test', 'fixtures', 'files', 'competitie.xlsx').to_s
      parser = ExcelCompetitionParser.new(path)
      expect { @competition = parser.convert }
      .to change { Competition.count }.by(1)
      .and change { Group.count }.by(2)
      .and change { Result.count }.by(5)
      .and change { Runner.count }.by(1)
      .and change { Club.count }.by(2)
      .and change { Entry.count }.by(2)

      expect(@competition).to eq(Competition.last)

      expect(@competition.attributes.except('created_at', 'updated_at').compact).to eq({
        'id'               => 2,
        'competition_name' => 'Test dsadsa',
        'date'             => '2024-01-01'.to_date,
        'distance_type'    => 'Sprint',
        'checksum'         => (Digest::SHA2.new << "Test dsadsa-2024-01-01-Sprint-").to_s,
        'location'         => 'Chisinau',
        'country'          => 'Moldova'
      })

      expect(Group.last.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"             => 3,
        "group_name"     => "M21",
        "competition_id" => 2,
        "clasa"          => "MSRM"
      })
      expect(Club.last.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"                    => 2,
        "club_name"             => "Dinamo-Old",
        "formatted_name"        => "dinamoold"
      })

      expect(Runner.last.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"               => 321,
        "runner_name"      => "Grib",
        "surname"          => "Ana",
        "gender"           => "W",
        "dob"              => "1994-01-01".to_date,
        "checksum"         => (Digest::SHA2.new << "Grib-Ana-1994-W").to_s,
        "category_id"      => 10,
        "best_category_id" => 10,
        "category_valid"   => "2100-01-01".to_date,
        "club_id"          => 1
      })

      expect(Result.first.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"          => 1,
        "date"        => "2024-01-01".to_date,
        "runner_id"   => 321,
        "group_id"    => 0,
        "category_id" => 3,
        "time"        => 0
      })

      expect(Result.last.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"          => 5,
        "date"        => "2024-01-01".to_date,
        "runner_id"   => 273,
        "group_id"    => 3,
        "category_id" => 10,
        "place"       => 2,
        "time"        => 1271
      })

      expect(Entry.first.attributes.except('created_at', 'updated_at').compact).to eq({
        "date"        => "2024-01-01".to_date,
        "id"          => 1,
        "runner_id"   => 321,
        "category_id" => 3,
        "result_id"   => 1,
        "status"      => "unconfirmed",
      })

    end
  end
end

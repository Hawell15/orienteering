# spec/group_form_parser_spec.rb

require 'rails_helper'

RSpec.describe JsonParser, type: :model do
  before(:each) do
      Runner.create!(runner_name: "Ciobanu", surname: "Roman", dob: "1991-02-15", gender: "M", category_id: 6)
      Runner.create!(id: 2, category_id: 2)
      Runner.create!(runner_name: "Gutur", surname: "Daria", dob: "2009-02-15", gender: "W", category_id: 2)
  end

  describe '#convert' do
    it 'passes flow with json data' do
      path   = Rails.root.join('test', 'fixtures', 'files', 'rezultate.json')
      parser = JsonParser.new(path)
      expect { @competition = parser.convert }
      .to change { Competition.count }.by(1)
      .and change { Group.count }.by(2)
      .and change { Result.count }.by(6)
      .and change { Runner.count }.by(1)
      .and change { Club.count }.by(3)
      .and change { Entry.count }.by(2)

      expect(@competition).to eq(Competition.last)

      expect(@competition.attributes.except('created_at', 'updated_at').compact).to eq({
        'id'               => 2,
        'competition_name' => 'Some Competition',
        'date'             => '2023-10-14'.to_date,
        'distance_type'    => 'заданка',
        'checksum'         => (Digest::SHA2.new << "Some Competition-2023-10-14-заданка-").to_s
      })

      expect(Group.last.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"             => 3,
        "group_name"     => "W14",
        "competition_id" => 2,
        "clasa"          => "Juniori"
      })
      expect(Club.last.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"                    => 3,
        "club_name"             => "CMTT Chișinău",
        "formatted_name"        => "cmttchisinau"
      })

      expect(Runner.last.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"               => 4,
        "runner_name"      => "Hersun",
        "surname"          => "Valeria",
        "gender"           => "W",
        "dob"              => "2009-06-04".to_date,
        "checksum"         => (Digest::SHA2.new << "Hersun-Valeria-2009-W").to_s,
        "category_id"      => 10,
        "best_category_id" => 10,
        "category_valid"   => "2100-01-01".to_date,
        "club_id"          => 3
      })

      expect(Result.first.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"          => 1,
        "date"        => "2023-10-13".to_date,
        "runner_id"   => 1,
        "group_id"    => 0,
        "category_id" => 2,
        "time"        => 0
      })

      expect(Result.last.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"          => 6,
        "date"        => "2023-10-14".to_date,
        "runner_id"   => 4,
        "group_id"    => 3,
        "category_id" => 10,
        "place"       => 2,
        "time"        => 702
      })

      expect(Entry.first.attributes.except('created_at', 'updated_at').compact).to eq({
        "date"        => "2023-10-13".to_date,
        "id"          => 1,
        "runner_id"   => 1,
        "category_id" => 2,
        "result_id"   => 1,
        "status"      => "unconfirmed",
      })

    end
  end
end

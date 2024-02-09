# spec/group_form_parser_spec.rb

require 'rails_helper'

RSpec.describe HtmlParser, type: :model do
  before(:each) do
      Runner.create!(runner_name: "Fala", surname: "Sergiu", dob: "1993-06-23", gender: "M", category_id: 3)
      Runner.create!(runner_name: "Motnii", surname: "Sveatoslav", dob: "2007-02-15", gender: "M", category_id: 4)
  end

  describe '#convert' do
    it 'passes flow with json data' do
      path   = Rails.root.join('test', 'fixtures', 'files', 'rezultate.html')
      parser = HtmlParser.new(path)
      expect { @competition = parser.convert }
      .to change { Competition.count }.by(1)
      .and change { Group.count }.by(2)
      .and change { Result.count }.by(8)
      .and change { Runner.count }.by(3)
      .and change { Club.count }.by(3)
      .and change { Entry.count }.by(3)

      expect(@competition).to eq(Competition.last)

      expect(@competition.attributes.except('created_at', 'updated_at').compact).to eq({
        'id'               => 2,
        'competition_name' => 'Maratonul Nemuritorilor',
        'date'             => '2023-11-19'.to_date,
        'distance_type'    => 'Ultralong',
        'checksum'         => (Digest::SHA2.new << "Maratonul Nemuritorilor-2023-11-19-Ultralong-").to_s
      })

      expect(Group.last.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"             => 3,
        "group_name"     => "MMiddle",
        "competition_id" => 2,
      })
      expect(Club.last.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"                    => 3,
        "club_name"             => "Run Kompass, Молдова",
        "formatted_name"        => "runcompass"
      })

      expect(Runner.last.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"               => 5,
        "runner_name"      => "Cerescu",
        "surname"          => "Pavel",
        "gender"           => "M",
        "dob"              => "1963-01-01".to_date,
        "checksum"         => (Digest::SHA2.new << "Cerescu-Pavel-1963-M").to_s,
        "category_id"      => 10,
        "best_category_id" => 10,
        "category_valid"   => "2100-01-01".to_date,
        "club_id"          => 3
      })

      expect(Result.first.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"          => 1,
        "date"        => "2023-11-19".to_date,
        "runner_id"   => 3,
        "group_id"    => 0,
        "category_id" => 4,
        "time"        => 0
      })

      expect(Result.last.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"          => 8,
        "date"        => "2023-11-19".to_date,
        "runner_id"   => 2,
        "group_id"    => 3,
        "category_id" => 10,
        "place"       => 3,
        "time"        => 4799
      })

      expect(Entry.first.attributes.except('created_at', 'updated_at').compact).to eq({
        "date"        => "2023-11-19".to_date,
        "id"          => 1,
        "runner_id"   => 3,
        "category_id" => 4,
        "result_id"   => 1,
        "status"      => "unconfirmed",
      })

    end
  end
end

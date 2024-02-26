# spec/group_form_parser_spec.rb

require 'rails_helper'

RSpec.describe ResultFormParser, type: :model do
  before(:each) do
    Runner.create!("id": 1, "club_id": 1, "category_id": 6, "best_category_id": 6)
  end


  describe '#convert' do
    it 'passes flow with Fara Competitie lower category' do
      params = {"place"=>"", "runner_id"=>"1", "time"=>"0", "category_id"=>"7", "wre_points"=>"", "date(3i)"=>"1", "date(2i)"=>"2", "date(1i)"=>"2024", "group_attributes"=>{"competition_id"=>"1"}}
      result_form_parser = ResultFormParser.new(params)
      expect { @result = result_form_parser.convert}
      .to change { Competition.count }.by(0)
      .and change { Group.count }.by(0)
      .and change { Runner.count }.by(0)
      .and change { Result.count }.by(1)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(0)

      expect(@result).to eq(Result.last)

      expect(@result.attributes.except('created_at', 'updated_at').compact).to eq(
        {
          'id'          => 1,
          'date'        => "2024-2-1".to_date,
          'runner_id'   => 1,
          'group_id'    => 1,
          'category_id' => 7,
          'time'        => 0
        }
      )
    end

    it 'passes flow with Fara Competitie better category' do
      params = {"place"=>"", "runner_id"=>"1", "time"=>"0", "category_id"=>"5", "wre_points"=>"", "date(3i)"=>"1", "date(2i)"=>"2", "date(1i)"=>"2024", "group_attributes"=>{"competition_id"=>"1"}}
      result_form_parser = ResultFormParser.new(params)
      expect { @result = result_form_parser.convert}
      .to change { Competition.count }.by(0)
      .and change { Group.count }.by(0)
      .and change { Runner.count }.by(0)
      .and change { Result.count }.by(1)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(1)

      expect(@result).to eq(Result.last)

      expect(@result.attributes.except('created_at', 'updated_at').compact).to eq(
        {
          'id'          => 1,
          'date'        => "2024-2-1".to_date,
          'runner_id'   => 1,
          'group_id'    => 1,
          'category_id' => 5,
          'time'        => 0,
        }
      )

      expect(Entry.last.attributes.except('created_at', 'updated_at')).to eq({
        "id"          => 1,
        "date"        => "2024-02-01".to_date,
        "runner_id"   => 1,
        "category_id" => 5,
        "result_id"   => 1,
        "status"      => "confirmed"
      })
      expect(Runner.find(@result.runner_id).slice("category_id", "best_category_id", "category_valid")).to eq({
        'category_id'      => 5,
        'best_category_id' => 5,
        'category_valid'   => "2026-2-1".to_date
      })
    end

    it 'passes flow with Diminuare Categorie' do
      params = {"place"=>"", "runner_id"=>"1", "time"=>"0", "category_id"=>"7", "date(3i)"=>"1", "date(2i)"=>"2", "date(1i)"=>"2024", "group_attributes"=>{"competition_id"=>"2"}}
      result_form_parser = ResultFormParser.new(params)

      expect { @result = result_form_parser.convert}
      .to change { Competition.count }.by(0)
      .and change { Group.count }.by(0)
      .and change { Runner.count }.by(0)
      .and change { Result.count }.by(1)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(1)
      expect(@result).to eq(Result.last)

      expect(@result.attributes.except('created_at', 'updated_at').compact).to eq({
        'id'          => 1,
        'date'        => "2024-2-1".to_date,
        'runner_id'   => 1,
        'group_id'    => 2,
        'category_id' => 7,
        'time'        => 0,
      })

       expect(Entry.last.attributes.except('created_at', 'updated_at')).to eq({
        "id"          => 1,
        "date"        => "2024-02-01".to_date,
        "runner_id"   => 1,
        "category_id" => 7,
        "result_id"   => 1,
        "status"      => "confirmed"
      })

      expect(Runner.find(@result.runner_id).slice("category_id", "best_category_id", "category_valid")).to eq({
        'category_id'      => 7,
        'best_category_id' => 6,
        'category_valid'   => "2026-2-1".to_date
      })
    end

    it 'passes flow with existing Competition and Group lower category' do
      Competition.create!(id: 3, date: "2023-01-01")
      Group.create!(id: 3, competition_id: 3, group_name: "SomeGroup")

      params = {"place"=>"1", "runner_id"=>"1", "time"=>"3661", "category_id"=>"8", "group_id"=>"3", "wre_points"=>"111", "date(3i)"=>"2", "date(2i)"=>"2", "date(1i)"=>"2024", "group_attributes"=>{"competition_id"=>"3"}}
      result_form_parser = ResultFormParser.new(params)

      expect { @result = result_form_parser.convert}
      .to change { Competition.count }.by(0)
      .and change { Group.count }.by(0)
      .and change { Runner.count }.by(0)
      .and change { Result.count }.by(1)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(0)


      expect(@result.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id'          => 1,
          'date'        => "2023-1-1".to_date,
          'runner_id'   => 1,
          'group_id'    => 3,
          'category_id' => 8,
          'place'       => 1,
          'time'        => 3661,
          'wre_points'  => 111
        }
      )
      expect(@result).to eq(Result.last)
    end

    it 'passes flow with existing Competition and Group better category' do
      Competition.create!(id: 3, date: "2023-01-01")
      Group.create!(id: 3, competition_id: 3, group_name: "SomeGroup")

      params = {"place"=>"1", "runner_id"=>"1", "time"=>"3661", "category_id"=>"5", "group_id"=>"3", "wre_points"=>"111", "date(3i)"=>"2", "date(2i)"=>"2", "date(1i)"=>"2024", "group_attributes"=>{"competition_id"=>"3"}}
      result_form_parser = ResultFormParser.new(params)

      expect { @result = result_form_parser.convert}
      .to change { Competition.count }.by(0)
      .and change { Group.count }.by(0)
      .and change { Runner.count }.by(0)
      .and change { Result.count }.by(1)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(1)

      expect(@result).to eq(Result.last)

      expect(@result.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id'          => 1,
          'date'        => "2023-1-1".to_date,
          'runner_id'   => 1,
          'group_id'    => 3,
          'category_id' => 5,
          'place'       => 1,
          'time'        => 3661,
          'wre_points'  => 111
        }
      )

      expect(Entry.last.attributes.except('created_at', 'updated_at')).to eq({
        "id"          => 1,
        "date"        => "2023-01-01".to_date,
        "runner_id"   => 1,
        "category_id" => 5,
        "result_id"   => 1,
        "status"      => "confirmed"
      })
      expect(Runner.find(@result.runner_id).slice("category_id", "best_category_id", "category_valid")).to eq({
        'category_id'      => 5,
        'best_category_id' => 5,
        'category_valid'   => "2025-01-01".to_date
      })
    end

    it 'passes flow with existing Competition and New Group lower category' do
      Competition.create!(id: 3, date: "2023-01-01")
      Group.create!(id: 4, competition_id: 3, group_name: "SomeGroup")

        params = {"place"=>"1", "runner_id"=>"1", "time"=>"900", "category_id"=>"7", "wre_points"=>"", "date(3i)"=>"2", "date(2i)"=>"2", "date(1i)"=>"2024", "group_attributes"=>{"group_name"=>"M21", "competition_id"=>"3"}}
      result_form_parser = ResultFormParser.new(params)

      expect { @result = result_form_parser.convert}
      .to change { Competition.count }.by(0)
      .and change { Group.count }.by(1)
      .and change { Runner.count }.by(0)
      .and change { Result.count }.by(1)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(0)

      #
      expect(@result.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id' => 1,
          'runner_id' => 1,
          'time' => 900,
          'place' => 1,
          'group_id' => 3,
          'category_id' => 7,
          'wre_points' => nil,
          'date' => "2023-1-1".to_date
        }
      )
      expect(@result).to eq(Result.last)

      expect(Group.all[-1].attributes.except('created_at', 'updated_at')).to eq(
        {
          'id' => 3,
          'competition_id' => 3,
          'group_name' => 'M21',
          'clasa' => nil,
          'rang' => nil
        }
      )
    end

    it 'passes flow with existing Competition and New Group upper category' do
      Competition.create!(id: 3, date: "2023-01-01")
      Group.create!(id: 4, competition_id: 3, group_name: "SomeGroup")

        params = {"place"=>"1", "runner_id"=>"1", "time"=>"900", "category_id"=>"5", "wre_points"=>"", "date(3i)"=>"2", "date(2i)"=>"2", "date(1i)"=>"2024", "group_attributes"=>{"group_name"=>"M21", "competition_id"=>"3"}}
      result_form_parser = ResultFormParser.new(params)

      expect { @result = result_form_parser.convert}
      .to change { Competition.count }.by(0)
      .and change { Group.count }.by(1)
      .and change { Runner.count }.by(0)
      .and change { Result.count }.by(1)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(1)

       expect(Entry.last.attributes.except('created_at', 'updated_at')).to eq({
        "id"          => 1,
        "date"        => "2023-01-01".to_date,
        "runner_id"   => 1,
        "category_id" => 5,
        "result_id"   => 1,
        "status"      => "confirmed"
      })
      expect(Runner.find(@result.runner_id).slice("category_id", "best_category_id", "category_valid")).to eq({
        'category_id'      => 5,
        'best_category_id' => 5,
        'category_valid'   => "2025-01-01".to_date,
      })
    end

    it 'passes flow with New Competition and New Group lower category' do
      Competition.create!(id: 4, date: "2023-01-01")
      Group.create!(id: 4, competition_id: 4, group_name: "SomeGroup")

      params = {"place"=>"5", "runner_id"=>"1", "time"=>"3601", "category_id"=>"7", "wre_points"=>"", "date(3i)"=>"2", "date(2i)"=>"2", "date(1i)"=>"2024", "group_attributes"=>{"group_name"=>"M21", "competition_id"=>"", "competition_attributes"=>{"competition_name"=>"New Competition", "date(2i)"=>"1", "date(3i)"=>"2", "date(1i)"=>"2024", "location"=>"Chisinau", "country"=>"Moldova", "distance_type"=>"Long", "wre_id"=>""}}}
      result_form_parser = ResultFormParser.new(params)

      expect { @result = result_form_parser.convert}
      .to change { Competition.count }.by(1)
      .and change { Group.count }.by(1)
      .and change { Runner.count }.by(0)
      .and change { Result.count }.by(1)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(0)

      expect(@result.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id' => 1,
          'runner_id' => 1,
          'time' => 3601,
          'place' => 5,
          'group_id' => 3,
          'category_id' => 7,
          'wre_points' => nil,
          'date' => "2024-1-2".to_date
        }
      )
      expect(@result).to eq(Result.last)

      expect(Competition.order(:created_at).last.attributes.except('created_at', 'updated_at')).to eq(
        {
          'competition_name' => 'New Competition',
          'date' => '2024-01-02'.to_date,
          'location' => 'Chisinau',
          'country' => 'Moldova',
          'distance_type' => 'Long',
          'wre_id' => nil,
          'id' => 3,
          'checksum' => (Digest::SHA2.new << "New Competition-2024-01-02-Long-").to_s
        }
      )

      expect(Group.order(:created_at).last.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id' => 3,
          'competition_id' => 3,
          'group_name' => 'M21',
          'clasa' => nil,
          'rang' => nil
        }
      )
    end


    it 'passes flow with New Competition and New Group upper category' do
      Competition.create!(id: 4, date: "2023-01-01")
      Group.create!(id: 4, competition_id: 4, group_name: "SomeGroup")

      params = {"place"=>"5", "runner_id"=>"1", "time"=>"3601", "category_id"=>"5", "wre_points"=>"", "date(3i)"=>"2", "date(2i)"=>"2", "date(1i)"=>"2024", "group_attributes"=>{"group_name"=>"M21", "competition_id"=>"", "competition_attributes"=>{"competition_name"=>"New Competition", "date(2i)"=>"1", "date(3i)"=>"2", "date(1i)"=>"2024", "location"=>"Chisinau", "country"=>"Moldova", "distance_type"=>"Long", "wre_id"=>""}}}
      result_form_parser = ResultFormParser.new(params)

      expect { @result = result_form_parser.convert}
      .to change { Competition.count }.by(1)
      .and change { Group.count }.by(1)
      .and change { Runner.count }.by(0)
      .and change { Result.count }.by(1)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(1)

      expect(Entry.last.attributes.except('created_at', 'updated_at')).to eq({
        "id"          => 1,
        "date"        => "2024-01-02".to_date,
        "runner_id"   => 1,
        "category_id" => 5,
        "result_id"   => 1,
        "status"      => "confirmed"
      })
      expect(Runner.find(@result.runner_id).slice("category_id", "best_category_id", "category_valid")).to eq({
        'category_id'      => 5,
        'best_category_id' => 5,
        'category_valid'   => "2026-01-02".to_date,
      })

    end
  end
end

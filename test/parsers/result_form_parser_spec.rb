# spec/group_form_parser_spec.rb

require 'rails_helper'

RSpec.describe ResultFormParser, type: :model do
  before(:each) do
    Competition.create!("id": 0, "competition_name": 'Fara Competitie', "date": '2021-08-01')
    Competition.create!("id": 1, "competition_name": 'Diminuare Categorie', "date": '2021-08-01')
    Group.create!("id": 0, "group_name": 'No Group', "competition_id": 0)
    Group.create!("id": 1, "group_name": 'Diminuare Categorie', "competition_id": 1)
    Club.create!("id": 0, "club_name": 'Individual')
    Category.create!("id": 6)
    Runner.create!("id": 1, "club_id": 0, "category_id": 6)
  end


  describe '#convert' do
    it 'passes flow with Fara Competitie' do
      params = {"place"=>"", "runner_id"=>"1", "time"=>"0", "category_id"=>"6", "wre_points"=>"11", "date(3i)"=>"1", "date(2i)"=>"2", "date(1i)"=>"2024", "group_attributes"=>{"competition_id"=>"0"}}
      result_form_parser = ResultFormParser.new(params)
      @result = result_form_parser.convert

      expect(Group.count).to eq(2)
      expect(Runner.count).to eq(1)
      expect(Result.count).to eq(1)
      expect(Club.count).to eq(1)
      expect(Competition.count).to eq(2)

      expect(@result.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id' => 1,
          'runner_id' => 1,
          'time' => 0,
          'place' => nil,
          'group_id' => 0,
          'category_id' => 6,
          'wre_points' => 11,
          'date' => "2024-2-1".to_date
        }
      )
      expect(@result).to eq(Result.last)
    end

    it 'passes flow with Diminuare Categorie' do
      params = {"place"=>"", "runner_id"=>"1", "time"=>"0", "category_id"=>"6", "date(3i)"=>"1", "date(2i)"=>"2", "date(1i)"=>"2024", "group_attributes"=>{"competition_id"=>"1"}}
      result_form_parser = ResultFormParser.new(params)
      @result = result_form_parser.convert

      expect(Group.count).to eq(2)
      expect(Runner.count).to eq(1)
      expect(Result.count).to eq(1)
      expect(Club.count).to eq(1)
      expect(Competition.count).to eq(2)

      expect(@result.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id' => 1,
          'runner_id' => 1,
          'time' => 0,
          'place' => nil,
          'group_id' => 1,
          'category_id' => 6,
          'wre_points' => nil,
          'date' => "2024-2-1".to_date
        }
      )
      expect(@result).to eq(Result.last)
    end

    it 'passes flow with existing Competition and Group' do
      Competition.create!(id: 2, date: "2023-01-01")
      Group.create!(id: 2, competition_id: 2)
      params = {"place"=>"1", "runner_id"=>"1", "time"=>"3661", "category_id"=>"6", "group_id"=>"2", "wre_points"=>"111", "date(3i)"=>"2", "date(2i)"=>"2", "date(1i)"=>"2024", "group_attributes"=>{"competition_id"=>"2"}}
      result_form_parser = ResultFormParser.new(params)
      @result = result_form_parser.convert

      expect(Group.count).to eq(3)
      expect(Runner.count).to eq(1)
      expect(Result.count).to eq(1)
      expect(Club.count).to eq(1)
      expect(Competition.count).to eq(3)

      expect(@result.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id' => 1,
          'runner_id' => 1,
          'time' => 3661,
          'place' => 1,
          'group_id' => 2,
          'category_id' => 6,
          'wre_points' => 111,
          'date' => "2023-1-1".to_date
        }
      )
      expect(@result).to eq(Result.last)
    end

    it 'passes flow with existing Competition and Group' do
      Competition.create!(id: 2, date: "2023-01-01")
      Group.create!(id: 2, competition_id: 2)
      params = {"place"=>"1", "runner_id"=>"1", "time"=>"3661", "category_id"=>"6", "group_id"=>"2", "wre_points"=>"111", "date(3i)"=>"2", "date(2i)"=>"2", "date(1i)"=>"2024", "group_attributes"=>{"competition_id"=>"2"}}
      result_form_parser = ResultFormParser.new(params)
      @result = result_form_parser.convert

      expect(Group.count).to eq(3)
      expect(Runner.count).to eq(1)
      expect(Result.count).to eq(1)
      expect(Club.count).to eq(1)
      expect(Competition.count).to eq(3)

      expect(@result.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id' => 1,
          'runner_id' => 1,
          'time' => 3661,
          'place' => 1,
          'group_id' => 2,
          'category_id' => 6,
          'wre_points' => 111,
          'date' => "2023-1-1".to_date
        }
      )
      expect(@result).to eq(Result.last)
    end

    it 'passes flow with existing Competition and New Group' do
      Competition.create!(id: 2, date: "2023-01-01")
      Group.create!(id: 2, competition_id: 2)
      params = {"place"=>"1", "runner_id"=>"1", "time"=>"900", "category_id"=>"6", "wre_points"=>"", "date(3i)"=>"2", "date(2i)"=>"2", "date(1i)"=>"2024", "group_attributes"=>{"group_name"=>"M21", "competition_id"=>"2"}}
      result_form_parser = ResultFormParser.new(params)
      @result = result_form_parser.convert

      expect(Group.count).to eq(4)
      expect(Runner.count).to eq(1)
      expect(Result.count).to eq(1)
      expect(Club.count).to eq(1)
      expect(Competition.count).to eq(3)

      expect(@result.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id' => 1,
          'runner_id' => 1,
          'time' => 900,
          'place' => 1,
          'group_id' => 3,
          'category_id' => 6,
          'wre_points' => nil,
          'date' => "2023-1-1".to_date
        }
      )
      expect(@result).to eq(Result.last)

      expect(Group.last.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id' => 3,
          'competition_id' => 2,
          'group_name' => 'M21',
          'clasa' => nil,
          'rang' => nil
        }
      )
    end

    it 'passes flow with New Competition and New Group' do
      Competition.create!(id: 2, date: "2023-01-01")
      Group.create!(id: 2, competition_id: 2)
      params = {"place"=>"5", "runner_id"=>"1", "time"=>"3601", "category_id"=>"6", "wre_points"=>"", "date(3i)"=>"2", "date(2i)"=>"2", "date(1i)"=>"2024", "group_attributes"=>{"group_name"=>"M21", "competition_id"=>"", "competition_attributes"=>{"competition_name"=>"New Competition", "date(2i)"=>"1", "date(3i)"=>"2", "date(1i)"=>"2024", "location"=>"Chisinau", "country"=>"Moldova", "distance_type"=>"Long", "wre_id"=>""}}}
      result_form_parser = ResultFormParser.new(params)
      @result = result_form_parser.convert

      expect(Group.count).to eq(4)
      expect(Runner.count).to eq(1)
      expect(Result.count).to eq(1)
      expect(Club.count).to eq(1)
      expect(Competition.count).to eq(4)

      expect(@result.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id' => 1,
          'runner_id' => 1,
          'time' => 3601,
          'place' => 5,
          'group_id' => 3,
          'category_id' => 6,
          'wre_points' => nil,
          'date' => "2024-1-2".to_date
        }
      )
      expect(@result).to eq(Result.last)

      expect(Competition.last.attributes.except('created_at', 'updated_at')).to eq(
        {
          'competition_name' => 'New Competition',
          'date' => '2024-01-02'.to_date,
          'location' => 'Chisinau',
          'country' => 'Moldova',
          'distance_type' => 'Long',
          'wre_id' => nil,
          'id' => 3,
          'checksum' => (Digest::SHA2.new << "New Competition-2024-01-02-Long").to_s
        }
      )

      expect(Group.last.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id' => 3,
          'competition_id' => 3,
          'group_name' => 'M21',
          'clasa' => nil,
          'rang' => nil
        }
      )
    end
  end
end

# spec/group_form_parser_spec.rb

require 'rails_helper'

RSpec.describe RunnerFormParser, type: :model do
  before(:each) do
    Competition.create!("id": 0, "competition_name": 'Fara Competitie', "date": '2021-08-01')
    Competition.create!("id": 1, "competition_name": 'Diminuare Categorie', "date": '2021-08-01')
    Group.create!("id": 0, "group_name": 'No Group', "competition_id": 0)
    Group.create!("id": 1, "group_name": 'Diminuare Categorie', "competition_id": 1)
    Club.create!("id": 0, "club_name": 'Individual')
    Category.create!("id": 6)
    Category.create!("id": 10)
    Runner.create!("id": 1, "club_id": 0, "category_id": 6)
  end

  describe '#convert' do
    it 'passes flow with with category f/c' do
      params = {"runner_name"=>"Ciobanu", "surname"=>"Roman", "dob(3i)"=>"23", "dob(2i)"=>"1", "dob(1i)"=>"1991", "club_id"=>"0", "gender"=>"M", "wre_id"=>"111", "best_category_id"=>"10", "category_id"=>"10"}
      runner_form_parser = RunnerFormParser.new(params)
      @runner = runner_form_parser.convert
      expect(Group.count).to eq(2)
      expect(Runner.count).to eq(2)
      expect(Result.count).to eq(0)
      expect(Club.count).to eq(1)
      expect(Competition.count).to eq(2)

      expect(@runner.attributes.except('created_at', 'updated_at')).to eq(
        {
          "id" => 2,
          "runner_name" => "Ciobanu",
          "surname" => "Roman",
          "dob" => '1991-01-23'.to_date,
          "gender" => "M",
          "club_id" => 0,
          "best_category_id" => 10,
          "category_id" => 10,
          "category_valid" => "2100-01-01".to_date,
          "wre_id" => 111,
          "forest_wre_place" => nil,
          "forest_wre_rang" => nil,
          "sprint_wre_place" => nil,
          "sprint_wre_rang" => nil,
          "checksum" => (Digest::SHA2.new << "Ciobanu-Roman-1991-M").to_s
        }
      )
      expect(@runner).to eq(Runner.last)
    end

  end
end

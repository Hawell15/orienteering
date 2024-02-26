# spec/group_form_parser_spec.rb

require 'rails_helper'

RSpec.describe RunnerFormParser, type: :model do
  before(:each) do
    Runner.create!("id": 2, "club_id": 1, "category_id": 6)
  end

  describe '#convert' do
    it 'passes flow with with category f/c' do
      params = {"runner_name"=>"Ciobanu", "surname"=>"Roman", "dob(3i)"=>"23", "dob(2i)"=>"1", "dob(1i)"=>"1991", "club_id"=>"1", "gender"=>"M", "wre_id"=>"111", "best_category_id"=>"10", "category_id"=>"10"}
      runner_form_parser = RunnerFormParser.new(params)

      expect { @runner = runner_form_parser.convert}
      .to change { Runner.count }.by(1)
      .and change { Competition.count }.by(0)
      .and change { Group.count }.by(0)
      .and change { Result.count }.by(0)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(0)

      expect(@runner).to eq(Runner.order(:created_at).last)

      expect(@runner.attributes.except('created_at', 'updated_at').compact).to eq(
        {
          "id"               => 1,
          "runner_name"      => "Ciobanu",
          "surname"          => "Roman",
          "dob"              => '1991-01-23'.to_date,
          "gender"           => "M",
          "club_id"          => 1,
          "checksum"         => (Digest::SHA2.new << "Ciobanu-Roman-1991-M").to_s,
          "category_id"      => 10,
          "best_category_id" => 10,
          "category_valid"   => "2100-01-01".to_date,
          "wre_id"           => 111
        }
      )
    end

    it 'passes flow with with category another category' do
      params = {"runner_name"=>"Ciobanu", "surname"=>"Roman", "dob(3i)"=>"23", "dob(2i)"=>"1", "dob(1i)"=>"1991", "club_id"=>"1", "gender"=>"M", "wre_id"=>"111", "best_category_id"=>"2", "category_id"=>"5"}
      runner_form_parser = RunnerFormParser.new(params)

      expect { @runner = runner_form_parser.convert}
      .to change { Runner.count }.by(1)
      .and change { Competition.count }.by(0)
      .and change { Group.count }.by(0)
      .and change { Result.count }.by(0)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(0)

      expect(@runner).to eq(Runner.order(:created_at).last)

      expect(@runner.attributes.except('created_at', 'updated_at').compact).to eq(
        {
          "id"               => 1,
          "runner_name"      => "Ciobanu",
          "surname"          => "Roman",
          "dob"              => '1991-01-23'.to_date,
          "gender"           => "M",
          "club_id"          => 1,
          "checksum"         => (Digest::SHA2.new << "Ciobanu-Roman-1991-M").to_s,
          "category_id"      => 10,
          "best_category_id" => 2,
          "category_valid"   => "2100-01-01".to_date,
          "wre_id"           => 111
        }
      )
    end
  end
end

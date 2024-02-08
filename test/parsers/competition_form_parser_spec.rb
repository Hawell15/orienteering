# spec/group_form_parser_spec.rb

require 'rails_helper'

RSpec.describe CompetitionFormParser, type: :model do
  describe '#convert' do
    it 'passes flow with 0 groups' do
      params = { 'competition_name' => 'Test Comp', 'date(3i)' => '1', 'date(2i)' => '2', 'date(1i)' => '2024',
                 'location' => 'Chisinau', 'country' => 'Moldova', 'distance_type' => 'Sprint', 'wre_id' => '111', 'group_list' => '' }
      competition_form_parser = CompetitionFormParser.new(params)
      expect { @competition = competition_form_parser.convert }
      .to change { Competition.count }.by(1)
      .and change { Group.count }.by(0)
      .and change { Runner.count }.by(0)
      .and change { Result.count }.by(0)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(0)

      expect(Competition.last.attributes.except('created_at', 'updated_at').compact).to eq(
        {
          'id'               => 2,
          'competition_name' => 'Test Comp',
          'date'             => '2024-02-01'.to_date,
          'distance_type'    => 'Sprint',
          'checksum'         => (Digest::SHA2.new << "Test Comp-2024-02-01-Sprint-111").to_s,
          'location'         => 'Chisinau',
          'country'          => 'Moldova',
          'wre_id'           => 111
        }
      )
      expect(@competition).to eq(Competition.last)
    end

    it 'passes flow with 1 group' do
      params = { 'competition_name' => 'Test Comp', 'date(3i)' => '1', 'date(2i)' => '2', 'date(1i)' => '2024',
                 'distance_type' => 'Sprint', 'group_list' => 'M21' }
      competition_form_parser = CompetitionFormParser.new(params)

      expect { @competition = competition_form_parser.convert }
      .to change { Competition.count }.by(1)
      .and change { Group.count }.by(1)
      .and change { Runner.count }.by(0)
      .and change { Result.count }.by(0)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(0)

      expect(Competition.last.attributes.except('created_at', 'updated_at').compact).to eq(
        {
          'id'               => 2,
          'competition_name' => 'Test Comp',
          'date'             => '2024-02-01'.to_date,
          'distance_type'    => 'Sprint',
          'checksum'         => (Digest::SHA2.new << "Test Comp-2024-02-01-Sprint-").to_s

        }
      )
      expect(@competition).to eq(Competition.last)

      expect(Group.last.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"             => 2,
        "group_name"     => "M21",
        "competition_id" => 2
      })
    end

    it 'passes flow with 2 groups' do
      params = { 'competition_name' => 'Test Comp', 'date(3i)' => '1', 'date(2i)' => '2', 'date(1i)' => '2024',
                 'location' => 'Chisinau', 'country' => 'Moldova', 'distance_type' => 'Sprint', 'wre_id' => '111', 'group_list' => 'M21,W21' }
      competition_form_parser = CompetitionFormParser.new(params)

      expect { @competition = competition_form_parser.convert }
      .to change { Competition.count }.by(1)
      .and change { Group.count }.by(2)
      .and change { Runner.count }.by(0)
      .and change { Result.count }.by(0)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(0)

      expect(Competition.last.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id'               => 2,
          'competition_name' => 'Test Comp',
          'date'             => '2024-02-01'.to_date,
          'distance_type'    => 'Sprint',
          'checksum'         => (Digest::SHA2.new << "Test Comp-2024-02-01-Sprint-111").to_s,
          'location'         => 'Chisinau',
          'country'          => 'Moldova',
          'wre_id'           => 111
        }
      )
      expect(@competition).to eq(Competition.last)

      expect(Group.all.drop(2).pluck(:id, :group_name, :competition_id)).to eq(
        [[2, 'M21', 2], [3, 'W21', 2]]
      )
    end
  end
end

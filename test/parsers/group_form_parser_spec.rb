# spec/group_form_parser_spec.rb

require 'rails_helper'

RSpec.describe GroupFormParser, type: :model do
  describe '#convert' do
    it 'passes flow with existing competition' do
      Competition.create!(id: 3)
      params = { 'group_name' => 'Test Group', 'competition_id' => '3', 'rang' => '1', 'clasa' => 'Seniori' }
      group_form_parser = GroupFormParser.new(params)

      expect { @group = group_form_parser.convert}
      .to change { Competition.count }.by(0)
      .and change { Group.count }.by(1)
      .and change { Runner.count }.by(0)
      .and change { Result.count }.by(0)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(0)

      expect(@group).to eq(Group.last)

      expect(@group.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id'             => 3,
          'group_name'     => 'TestGroup',
          'competition_id' => 3,
          'rang'           => 1,
          'clasa'          => 'Seniori'
        }
      )
    end

    it 'passes flow with new competition' do
      Competition.create!
      params = {
        'group_name' => 'Test Group',
        'competition_id' => '',
        'rang' => '1',
        'clasa' => 'MSRM',
        'competition_attributes' =>
        {
          'competition_name' => 'Test Comp',
          'date(1i)' => '2024',
          'date(2i)' => '2',
          'date(3i)' => '1',
          'location' => 'Chisinau',
          'country' => 'Moldova',
          'distance_type' => 'Sprint',
          'wre_id' => '111'
        }
      }

      group_form_parser = GroupFormParser.new(params)

      expect { @group = group_form_parser.convert}
      .to change { Competition.count }.by(1)
      .and change { Group.count }.by(1)
      .and change { Runner.count }.by(0)
      .and change { Result.count }.by(0)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(0)

      expect(@group.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id'             => 3,
          'group_name'     => 'TestGroup',
          'competition_id' => 4,
          'rang'           => 1,
          'clasa'          => 'MSRM'
        }
      )
      expect(@group).to eq(Group.last)
      expect(Competition.last.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id'               => 4,
          'competition_name' => 'Test Comp',
          'date'             => '2024-02-01'.to_date,
          'distance_type'    => 'Sprint',
          'checksum'         => (Digest::SHA2.new << "Test Comp-2024-02-01-Sprint-111").to_s,
          'location'         => 'Chisinau',
          'country'          => 'Moldova',
          'wre_id'           => 111
        }
      )
    end
  end
end

# spec/group_form_parser_spec.rb

require 'rails_helper'

RSpec.describe GroupFormParser, type: :model do
  describe '#convert' do
    it 'passes flow with existing competition' do
      Competition.create!(id: 1)
      params = { 'group_name' => 'Test Group', 'competition_id' => '1', 'rang' => '1', 'clasa' => 'Seniori' }
      group_form_parser = GroupFormParser.new(params)
      @group = group_form_parser.convert

      expect(Group.count).to eq(1)
      expect(Runner.count).to be_zero
      expect(Result.count).to be_zero
      expect(Club.count).to be_zero
      expect(Competition.count).to eq(1)

      expect(@group.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id' => 1,
          'group_name' => 'Test Group',
          'competition_id' => 1,
          'rang' => 1,
          'clasa' => 'Seniori'
        }
      )
      expect(@group).to eq(Group.last)
    end

    it 'passes flow with new competition' do
      Competition.create!(id: 1)
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
      @group = group_form_parser.convert

      expect(Group.count).to eq(1)
      expect(Runner.count).to be_zero
      expect(Result.count).to be_zero
      expect(Club.count).to be_zero
      expect(Competition.count).to eq(2)

      expect(@group.attributes.except('created_at', 'updated_at')).to eq(
        {
          'id' => 1,
          'group_name' => 'Test Group',
          'competition_id' => 2,
          'rang' => 1,
          'clasa' => 'MSRM'
        }
      )
      expect(@group).to eq(Group.last)
      expect(Competition.last.attributes.except('created_at', 'updated_at')).to eq(
        {
          'competition_name' => 'Test Comp',
          'date' => '2024-02-01'.to_date,
          'location' => 'Chisinau',
          'country' => 'Moldova',
          'distance_type' => 'Sprint',
          'wre_id' => 111,
          'id' => 2,
          'checksum' => (Digest::SHA2.new << "Test Comp-2024-02-01-Sprint").to_s
        }
      )
    end
  end
end

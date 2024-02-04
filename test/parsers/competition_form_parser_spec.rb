# spec/group_form_parser_spec.rb

require 'rails_helper'

RSpec.describe CompetitionFormParser, type: :model do
  describe '#convert' do
    it 'passes flow with 0 groups' do
      params = { 'competition_name' => 'Test Comp', 'date(3i)' => '1', 'date(2i)' => '2', 'date(1i)' => '2024',
                 'location' => 'Chisinau', 'country' => 'Moldova', 'distance_type' => 'Sprint', 'wre_id' => '111', 'group_list' => '' }
      competition_form_parser = CompetitionFormParser.new(params)
      @competition = competition_form_parser.convert

      expect(Group.count).to eq(0)
      expect(Runner.count).to be_zero
      expect(Result.count).to be_zero
      expect(Club.count).to be_zero
      expect(Competition.count).to eq(1)

      expect(Competition.last.attributes.except('created_at', 'updated_at')).to eq(
        {
          'competition_name' => 'Test Comp',
          'date' => '2024-02-01'.to_date,
          'location' => 'Chisinau',
          'country' => 'Moldova',
          'distance_type' => 'Sprint',
          'wre_id' => 111,
          'id' => 1,
          'checksum' => (Digest::SHA2.new << "Test Comp-2024-02-01-Sprint-111").to_s
        }
      )
      expect(@competition).to eq(Competition.last)
    end

    it 'passes flow with 2 groups' do
      params = { 'competition_name' => 'Test Comp', 'date(3i)' => '1', 'date(2i)' => '2', 'date(1i)' => '2024',
                 'distance_type' => 'Sprint', 'group_list' => 'M21' }
      competition_form_parser = CompetitionFormParser.new(params)
      @competition = competition_form_parser.convert

      expect(Group.count).to eq(1)
      expect(Runner.count).to be_zero
      expect(Result.count).to be_zero
      expect(Club.count).to be_zero
      expect(Competition.count).to eq(1)

      expect(Competition.last.attributes.except('created_at', 'updated_at')).to eq(
        {
          'competition_name' => 'Test Comp',
          'date' => '2024-02-01'.to_date,
          'location' => nil,
          'country' => nil,
          'distance_type' => 'Sprint',
          'wre_id' => nil,
          'id' => 1,
          'checksum' => (Digest::SHA2.new << "Test Comp-2024-02-01-Sprint-").to_s

        }
      )
      expect(@competition).to eq(Competition.last)

      expect(Group.all.pluck(:id, :group_name, :competition_id)).to eq(
        [[1, 'M21', 1]]
      )
    end

    it 'passes flow with 2 groups' do
      params = { 'competition_name' => 'Test Comp', 'date(3i)' => '1', 'date(2i)' => '2', 'date(1i)' => '2024',
                 'location' => 'Chisinau', 'country' => 'Moldova', 'distance_type' => 'Sprint', 'wre_id' => '111', 'group_list' => 'M21,W21' }
      competition_form_parser = CompetitionFormParser.new(params)
      @competition = competition_form_parser.convert

      expect(Group.count).to eq(2)
      expect(Runner.count).to be_zero
      expect(Result.count).to be_zero
      expect(Club.count).to be_zero
      expect(Competition.count).to eq(1)

      expect(Competition.last.attributes.except('created_at', 'updated_at')).to eq(
        {
          'competition_name' => 'Test Comp',
          'date' => '2024-02-01'.to_date,
          'location' => 'Chisinau',
          'country' => 'Moldova',
          'distance_type' => 'Sprint',
          'wre_id' => 111,
          'id' => 1,
          'checksum' => (Digest::SHA2.new << "Test Comp-2024-02-01-Sprint-111").to_s
        }
      )
      expect(@competition).to eq(Competition.last)

      expect(Group.all.pluck(:id, :group_name, :competition_id)).to eq(
        [[1, 'M21', 1], [2, 'W21', 1]]
      )
    end
  end
end

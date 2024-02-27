# spec/group_form_parser_spec.rb

require 'rails_helper'

RSpec.describe IofResultsParser, type: :model do
  before(:each) do
      Runner.create!(runner_name: "Ciobanu", surname: "Roman", wre_id: 8458, gender: "M", category_id: 4)
      Runner.create!(runner_name: "Nosenco", surname: "Victoria", wre_id: 272, gender: "W", category_id: 3)
  end

  describe '#convert' do
    it 'passes flow with json data' do
      parser = IofResultsParser.new
      path   = Rails.root.join('test', 'fixtures', 'files', 'iof_results_files').to_s

      m_fs_file  = JSON.parse(File.read("#{path}/runner1_wre_sprint_results.json"))
      m_f_file = JSON.parse(File.read("#{path}/runner1_wre_forest_results.json"))
      w_fs_file  = JSON.parse(File.read("#{path}/runner2_wre_sprint_results.json"))
      w_f_file = JSON.parse(File.read("#{path}/runner2_wre_forest_results.json"))

      allow_any_instance_of(IofResultsParser).to receive(:request_runner_results).and_return(m_f_file, m_fs_file, w_f_file, w_fs_file)

      expect { parser.convert }
      .to change { Competition.count }.by(5)
      .and change { Group.count }.by(5)
      .and change { Result.count }.by(5)
      .and change { Runner.count }.by(0)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(3)

      expect(Competition.last.attributes.except('created_at', 'updated_at').compact).to eq(
        {
          'competition_name' => 'South-East European Orienteering Championship – Sprint',
          'date'             => '2022-08-25'.to_date,
          'distance_type'    => 'Sprint',
          'wre_id'           => 7421,
          'id'               => 7,
          'checksum'         => (Digest::SHA2.new << "South-East European Orienteering Championship – Sprint-2022-08-25-Sprint-7421").to_s
        }
      )

      expect(Group.last.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"             => 7,
        "group_name"     => "W21E",
        "competition_id" => 7
      })

      expect(Result.first.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"          => 1,
        "date"        => "2023-09-16".to_date,
        "runner_id"   => 1,
        "group_id"    => 3,
        "category_id" => 4,
        "time"        => 3146,
        "place"       => 12,
        "wre_points"  => 716
      })

      expect(Entry.second.attributes.except('created_at', 'updated_at').compact).to eq({
        "date"        => "2023-10-29".to_date,
        "id"          => 2,
        "runner_id"   => 1,
        "category_id" => 2,
        "result_id"   => 4,
        "status"      => "unconfirmed",
      })
    end
  end
end

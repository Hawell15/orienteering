# spec/group_form_parser_spec.rb

require 'rails_helper'

RSpec.describe IofRunnersParser, type: :model do
  before(:each) do
      Runner.create!(runner_name: "Fomiciov", surname: "Anatolii", dob: "1997-05-26", gender: "M", category_id: 2)
      Runner.create!(runner_name: "Ciobanu", surname: "Roman", wre_id: 8458, id: 270, gender: "M")
  end

  describe '#convert' do
    it 'passes flow with json data' do
      parser = IofRunnersParser.new
      path   = Rails.root.join('test', 'fixtures', 'files', 'iof_runners_files')
      m_f_file  = CSV.parse(File.open("#{path}/MF.csv"), headers: true)
      m_fs_file = CSV.parse(File.open("#{path}/MFS.csv"), headers: true)
      w_f_file  = CSV.parse(File.open("#{path}/WF.csv"), headers: true)
      w_fs_file = CSV.parse(File.open("#{path}/WFS.csv"), headers: true)

      allow_any_instance_of(IofRunnersParser).to receive(:request_data).and_return(m_f_file, m_fs_file, w_f_file, w_fs_file)
      allow_any_instance_of(IofRunnersParser).to receive(:request_dob).and_return(Nokogiri::HTML(File.read("#{path}/runners.html")))


      expect { parser.convert }
      .to change { Competition.count }.by(0)
      .and change { Group.count }.by(0)
      .and change { Result.count }.by(0)
      .and change { Runner.count }.by(3)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(0)
      values = ["id", "runner_name", "surname", "dob", "checksum", "gender", "forest_wre_place", "forest_wre_rang", "sprint_wre_place", "sprint_wre_rang", "wre_id"]

      expect(Runner.all.map { |runner| runner.attributes.slice(*values).compact }).to eq([
        {
          "id"               => 270,
          "runner_name"      => "Ciobanu",
          "surname"          => "Roman",
          "dob"              => "2024-01-23".to_date,
          "gender"           => "M",
          "checksum"         =>  (Digest::SHA2.new << "Ciobanu-Roman-2024-M").to_s,
          "wre_id"           => 8458,
          "forest_wre_place" => 1385,
          "forest_wre_rang"  => 2644,
          "sprint_wre_place" => 353,
          "sprint_wre_rang"  => 4982
        },
        {
          "id"               => 1,
          "runner_name"      => "Fomiciov",
          "surname"          => "Anatolii",
          "dob"              => "1997-05-26".to_date,
          "gender"           => "M",
          "checksum"         => (Digest::SHA2.new << "Fomiciov-Anatolii-1997-M").to_s,
          "wre_id"           => 22504,
          "sprint_wre_place" => 241,
          "sprint_wre_rang"  => 5695
        },
        {
          "id"               => 2,
          "runner_name"      => "Ribediuc",
          "surname"          => "Galina",
          "dob"              => "1989-01-01".to_date,
          "gender"           => "W",
          "checksum"         =>  (Digest::SHA2.new << "Ribediuc-Galina-1989-W").to_s,
          "wre_id"           => 4779,
          "forest_wre_place" => 144,
          "forest_wre_rang"  => 6051
        },
        {
          "id"               => 3,
          "runner_name"      => "Nosenco",
          "surname"          => "Victoria",
          "dob"              => "2007-01-01".to_date,
          "gender"           => "W",
          "checksum"         =>  (Digest::SHA2.new << "Nosenco-Victoria-2007-W").to_s,
          "wre_id"           => 37897,
          "forest_wre_place" => 407,
          "forest_wre_rang"  => 5287,
          "sprint_wre_place" => 252,
          "sprint_wre_rang"  => 5309
        },
        {
          "id"               => 4,
          "runner_name"      => "Cecan",
          "surname"          => "Olesea",
          "dob"              => "1989-01-01".to_date,
          "gender"           => "W",
          "checksum"         =>  (Digest::SHA2.new << "Cecan-Olesea-1989-W").to_s,
          "wre_id"           => 3694,
          "sprint_wre_place" => 276,
          "sprint_wre_rang"  => 4993
        }
      ])
    end
  end
end

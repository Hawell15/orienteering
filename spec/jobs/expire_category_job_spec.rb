require 'rails_helper'

RSpec.describe ExpireCategoryJob, type: :job do
  describe '#convert' do
    it 'passes flow with 0 groups' do
      time = Time.now - 2.days

      Runner.create!(runner_name: "" ,surname: "", category_id: 5, category_valid: time.as_json)
      Runner.create!(runner_name: "" ,surname: "", category_id: 9, category_valid: time.as_json)
      Runner.create!(runner_name: "" ,surname: "", category_id: 9, category_valid: (time + 4.day).as_json)

      expect { ExpireCategoryJob.perform_now }
      .to change { Runner.count }.by(0)
      .and change { Competition.count }.by(0)
      .and change { Group.count }.by(0)
      .and change { Result.count }.by(2)
      .and change { Club.count }.by(0)
      .and change { Entry.count }.by(2)

      expect(Result.first.attributes.except('created_at', 'updated_at').compact).to eq({
        "id"          => 1,
        "date"        => time.to_date,
        "runner_id"   => 1,
        "group_id"    => 1,
        "category_id" => 6,
        "time"        => 0
      })

      expect(Entry.first.attributes.except('created_at', 'updated_at').compact).to eq({
        "date"        => time.to_date,
        "id"          => 1,
        "runner_id"   => 1,
        "category_id" => 6,
        "result_id"   => 1,
        "status"      => "confirmed",
      })

      expect(Runner.all.map  { |runner| runner.slice("id", "category_id", "category_valid") } ).to eq([
        {
          "id"             => 1,
          "category_id"    => 6,
          "category_valid" => (time + 2.years).to_date
        },
        {
          "id"             => 2,
          "category_id"    => 10,
          "category_valid" =>"2100-01-01".to_date
        },
         {
          "id"             => 3,
          "category_id"    => 9,
          "category_valid" => (time + 4.days).to_date
        },

      ])

    end
  end
end

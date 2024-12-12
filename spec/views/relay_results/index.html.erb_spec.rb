require 'rails_helper'

RSpec.describe "relay_results/index", type: :view do
  before(:each) do
    assign(:relay_results, [
      RelayResult.create!(
        place: 2,
        team: "Team",
        time: 3,
        category: nil,
        group: nil,
        results: ""
      ),
      RelayResult.create!(
        place: 2,
        team: "Team",
        time: 3,
        category: nil,
        group: nil,
        results: ""
      )
    ])
  end

  it "renders a list of relay_results" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Team".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(3.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("".to_s), count: 2
  end
end

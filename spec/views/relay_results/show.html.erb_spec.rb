require 'rails_helper'

RSpec.describe "relay_results/show", type: :view do
  before(:each) do
    assign(:relay_result, RelayResult.create!(
      place: 2,
      team: "Team",
      time: 3,
      category: nil,
      group: nil,
      results: ""
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Team/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end

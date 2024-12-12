require 'rails_helper'

RSpec.describe "relay_results/edit", type: :view do
  let(:relay_result) {
    RelayResult.create!(
      place: 1,
      team: "MyString",
      time: 1,
      category: nil,
      group: nil,
      results: ""
    )
  }

  before(:each) do
    assign(:relay_result, relay_result)
  end

  it "renders the edit relay_result form" do
    render

    assert_select "form[action=?][method=?]", relay_result_path(relay_result), "post" do

      assert_select "input[name=?]", "relay_result[place]"

      assert_select "input[name=?]", "relay_result[team]"

      assert_select "input[name=?]", "relay_result[time]"

      assert_select "input[name=?]", "relay_result[category_id]"

      assert_select "input[name=?]", "relay_result[group_id]"

      assert_select "input[name=?]", "relay_result[results]"
    end
  end
end

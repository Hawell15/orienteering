require 'rails_helper'

RSpec.describe "relay_results/new", type: :view do
  before(:each) do
    assign(:relay_result, RelayResult.new(
      place: 1,
      team: "MyString",
      time: 1,
      category: nil,
      group: nil,
      results: ""
    ))
  end

  it "renders new relay_result form" do
    render

    assert_select "form[action=?][method=?]", relay_results_path, "post" do

      assert_select "input[name=?]", "relay_result[place]"

      assert_select "input[name=?]", "relay_result[team]"

      assert_select "input[name=?]", "relay_result[time]"

      assert_select "input[name=?]", "relay_result[category_id]"

      assert_select "input[name=?]", "relay_result[group_id]"

      assert_select "input[name=?]", "relay_result[results]"
    end
  end
end

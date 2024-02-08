require 'rails_helper'

RSpec.describe "entries/new", type: :view do
  before(:each) do
    assign(:entry, Entry.new(
      runner: nil,
      category: nil,
      result: nil,
      status: "MyString"
    ))
  end

  it "renders new entry form" do
    render

    assert_select "form[action=?][method=?]", entries_path, "post" do

      assert_select "input[name=?]", "entry[runner_id]"

      assert_select "input[name=?]", "entry[category_id]"

      assert_select "input[name=?]", "entry[result_id]"

      assert_select "input[name=?]", "entry[status]"
    end
  end
end

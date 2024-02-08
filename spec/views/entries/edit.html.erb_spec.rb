require 'rails_helper'

RSpec.describe "entries/edit", type: :view do
  let(:entry) {
    Entry.create!(
      runner: nil,
      category: nil,
      result: nil,
      status: "MyString"
    )
  }

  before(:each) do
    assign(:entry, entry)
  end

  it "renders the edit entry form" do
    render

    assert_select "form[action=?][method=?]", entry_path(entry), "post" do

      assert_select "input[name=?]", "entry[runner_id]"

      assert_select "input[name=?]", "entry[category_id]"

      assert_select "input[name=?]", "entry[result_id]"

      assert_select "input[name=?]", "entry[status]"
    end
  end
end

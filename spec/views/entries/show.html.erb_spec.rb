require 'rails_helper'

RSpec.describe "entries/show", type: :view do
  before(:each) do
    assign(:entry, Entry.create!(
      runner: nil,
      category: nil,
      result: nil,
      status: "Status"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Status/)
  end
end

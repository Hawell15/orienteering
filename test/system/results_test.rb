require "application_system_test_case"

class ResultsTest < ApplicationSystemTestCase
  setup do
    @result = results(:one)
  end

  test "visiting the index" do
    visit results_url
    assert_selector "h1", text: "Results"
  end

  test "creating a Result" do
    visit results_url
    click_on "New Result"

    fill_in "Category", with: @result.category_id
    fill_in "Date", with: @result.date
    fill_in "Group", with: @result.group_id
    fill_in "Place", with: @result.place
    fill_in "Runner", with: @result.runner_id
    fill_in "Time", with: @result.time
    fill_in "Wre points", with: @result.wre_points
    click_on "Create Result"

    assert_text "Result was successfully created"
    click_on "Back"
  end

  test "updating a Result" do
    visit results_url
    click_on "Edit", match: :first

    fill_in "Category", with: @result.category_id
    fill_in "Date", with: @result.date
    fill_in "Group", with: @result.group_id
    fill_in "Place", with: @result.place
    fill_in "Runner", with: @result.runner_id
    fill_in "Time", with: @result.time
    fill_in "Wre points", with: @result.wre_points
    click_on "Update Result"

    assert_text "Result was successfully updated"
    click_on "Back"
  end

  test "destroying a Result" do
    visit results_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Result was successfully destroyed"
  end
end

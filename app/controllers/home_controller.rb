class HomeController < ApplicationController
  def index
    @clubs_count        = Club.count
    @runners_count      = Runner.count
    @competitions_count = Competition.count
    @results_count      = Result.count

    @competitions = Competition.order(date: :desc).limit(10)
  end
end

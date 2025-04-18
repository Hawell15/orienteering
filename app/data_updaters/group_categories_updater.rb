class GroupCategoriesUpdater
  attr_accessor :group

  def initialize(group)
    @group = group
  end

  def get_rang_and_categories
    rang = get_group_rang
    @group.update!(rang:)
    return process_knock_out_categories(rang) if group.competition.distance_type == "Knock Out Sprint"

    time_hash = get_time_hash
   main_results.each do |res|
      category_id = get_category_id(res, time_hash)
      update_result_category(res, category_id)
    end
  end

  def get_percent_and_times
    get_percent_hash.map do |k, v|
      { category: Category.find(k).category_name, percent: v,
        time: Time.at(v * winner_time / 100).utc.strftime('%H:%M:%S') }
    end
  end

  def rang_array
    [
      [1200, { 4 => 145, 5 => 174, 6 => 205, 7 => 300, 8 => nil, 9 => nil }.compact],
      [1000, { 4 => 142, 5 => 170, 6 => 200, 7 => 286, 8 => nil, 9 => nil }.compact],
      [800,  { 4 => 139, 5 => 166, 6 => 195, 7 => 272, 8 => nil, 9 => nil }.compact],
      [630,  { 4 => 136, 5 => 162, 6 => 190, 7 => 260, 8 => nil, 9 => nil }.compact],
      [490,  { 4 => 133, 5 => 158, 6 => 185, 7 => 248, 8 => nil, 9 => nil }.compact],
      [380,  { 4 => 130, 5 => 154, 6 => 180, 7 => 240, 8 => nil, 9 => nil }.compact],
      [300,  { 4 => 127, 5 => 150, 6 => 175, 7 => 232, 8 => nil, 9 => nil }.compact],
      [240,  { 4 => 124, 5 => 146, 6 => 171, 7 => 224, 8 => nil, 9 => nil }.compact],
      [190,  { 4 => 121, 5 => 142, 6 => 167, 7 => 216, 8 => nil, 9 => nil }.compact],
      [155,  { 4 => 117, 5 => 138, 6 => 163, 7 => 208, 8 => 300, 9 => nil }.compact],
      [125,  { 4 => 115, 5 => 135, 6 => 159, 7 => 200, 8 => 290, 9 => nil }.compact],
      [100,  { 4 => 112, 5 => 130, 6 => 155, 7 => 192, 8 => 280, 9 => nil }.compact],
      [82,   { 4 => 109, 5 => 127, 6 => 151, 7 => 184, 8 => 270, 9 => nil }.compact],
      [65,   { 4 => 106, 5 => 124, 6 => 147, 7 => 176, 8 => 260, 9 => nil }.compact],
      [51,   { 4 => 103, 5 => 121, 6 => 143, 7 => 170, 8 => 250, 9 => nil }.compact],
      [40,   { 4 => 100, 5 => 118, 6 => 139, 7 => 164, 8 => 240, 9 => nil }.compact],
      [31,   { 4 => nil, 5 => 115, 6 => 136, 7 => 158, 8 => 230, 9 => nil }.compact],
      [24,   { 4 => nil, 5 => 112, 6 => 133, 7 => 152, 8 => 220, 9 => nil }.compact],
      [19,   { 4 => nil, 5 => 109, 6 => 130, 7 => 147, 8 => 210, 9 => 300 }.compact],
      [15,   { 4 => nil, 5 => 106, 6 => 127, 7 => 142, 8 => 200, 9 => 280 }.compact],
      [12,   { 4 => nil, 5 => 103, 6 => 124, 7 => 138, 8 => 190, 9 => 260 }.compact],
      [10,   { 4 => nil, 5 => 100, 6 => 121, 7 => 134, 8 => 180, 9 => 240 }.compact],
      [9,    { 4 => nil, 5 => nil, 6 => 118, 7 => 130, 8 => 170, 9 => 220 }.compact],
      [8,    { 4 => nil, 5 => nil, 6 => 115, 7 => 126, 8 => 160, 9 => 200 }.compact],
      [7,    { 4 => nil, 5 => nil, 6 => 112, 7 => 122, 8 => 150, 9 => 185 }.compact],
      [6,    { 4 => nil, 5 => nil, 6 => 109, 7 => 118, 8 => 140, 9 => 170 }.compact],
      [5,    { 4 => nil, 5 => nil, 6 => 106, 7 => 114, 8 => 130, 9 => 155 }.compact],
      [4,    { 4 => nil, 5 => nil, 6 => 103, 7 => 110, 8 => 120, 9 => 140 }.compact],
      [3,    { 4 => nil, 5 => nil, 6 => 100, 7 => nil, 8 => 110, 9 => 130 }.compact],
      [2,    { 4 => nil, 5 => nil, 6 => nil, 7 => nil, 8 => nil, 9 => 120 }.compact],
      [1,    { 4 => nil, 5 => nil, 6 => nil, 7 => nil, 8 => nil, 9 => 110 }.compact],
    ]
  end

  def get_rang_percents(rang)
    return {} if rang < 1

    rang_array.detect { |row| row.first <= rang }.last
  end

  def get_group_rang
    rang_results.map do |result|
      entry = result.runner.entry_on_date(@group.competition.date)

      entry ? entry.category.points : 0.0
    end.sum
  end

  def get_time_hash
    percent_hash = get_percent_hash

    percent_hash.transform_values { |v| v * winner_time / 100 }
  end

  def get_percent_hash
    clasa = @group.clasa.to_i
    return {} if main_results.size < min_results_size

    get_rang_percents(@group.rang).map do |k, v|

      [k,v] if k >= clasa
    end.compact.to_h
  end

  def update_result_category(res, category_id)
    status = get_status(res, category_id)
    ResultAndEntryProcessor.new({category_id: category_id}, res, nil, status).update_result

    category_id
  end

  def main_results
    @main_results ||= @group.results.order(:place)
  end

  def winner_time
    @winner_time ||= main_results.first.time
  end

  def rang_results
    main_results.first(12)
  end

  def set_junior_category?(res)
    res.runner.junior_runner?
  end

  def min_results_size
    3
  end

  def get_status(res, category_id)
    return Entry::CONFIRMED if category_id > 3

    category_id < res.runner.best_category_id ? Entry::PENDING : Entry::CONFIRMED
  end

  def get_category_id(res, time_hash)
    time = res.time
    place = res.place
    clasa = @group.clasa

    category_id = if clasa == '2' && place == 1
                    2
                  elsif ['2', '3'].include?(clasa) && (1..3).include?(place)
                    3
                  else
                    time_hash.detect { |_k, v| v >= time }&.first || 10
                  end
    category_id = 10 if category_id > 6 && !set_junior_category?(res)

    category_id
  end

  def process_knock_out_categories(rang)
     if @group.group_name.include?("21")
      if rang <= 120
        @group.results.where(place: (1..6).to_a).each { |res| update_result_category(res, 4) }
        @group.results.where(place: (7..10).to_a).each { |res| update_result_category(res, 5) }
        @group.results.where(place: (11..16).to_a).each { |res| update_result_category(res, 6) }
      else
        first_place_category_id = rang > 300 ? 2 : 3
        @group.results.where(place: 1).each { |res| update_result_category(res, first_place_category_id) }
        @group.results.where(place: (2..3).to_a).each { |res| update_result_category(res, 3) }
        @group.results.where(place: (4..8).to_a).each { |res| update_result_category(res, 4) }
        @group.results.where(place: (9..12).to_a).each { |res| update_result_category(res, 5) }
        @group.results.where(place: (13..16).to_a).each { |res| update_result_category(res, 6) }
      end
    elsif @group.group_name.include?("16")
      if rang >= 20
        @group.results.where(place: 1).each { |res| update_result_category(res, 4) }
        @group.results.where(place: (2..3).to_a).each { |res| update_result_category(res, 5) }
        @group.results.where(place: (4..8).to_a).each { |res| update_result_category(res, 6) }
        @group.results.where(place: (9..12).to_a).each { |res| update_result_category(res, 7) }
      else
        @group.results.where(place: (1..3).to_a).each { |res| update_result_category(res, 5) }
        @group.results.where(place: (4..6).to_a).each { |res| update_result_category(res, 6) }
        @group.results.where(place: (7..9).to_a).each { |res| update_result_category(res, 7) }
        @group.results.where(place: (10..12).to_a).each { |res| update_result_category(res, 8) }
      end
    end
  end
end

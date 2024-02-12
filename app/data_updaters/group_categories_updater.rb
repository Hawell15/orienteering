class GroupCategoriesUpdater
  attr_accessor :group

  def initialize(group)
    @group = group
  end

  def get_rang_and_categories
    rang = get_group_rang
    @group.update!(rang:)

    time_hash = get_time_hash

    @group.results.each do |res|
      update_result_category(res, time_hash)
    end
  end

  def rang_array
    [
      [1200, { 4 => 147, 5 => 174, 6 => 209, 7 => 300, 8 => nil, 9 => nil }.compact],
      [1100, { 4 => 144, 5 => 170, 6 => 204, 7 => 290, 8 => nil, 9 => nil }.compact],
      [1000, { 4 => 141, 5 => 166, 6 => 199, 7 => 280, 8 => nil, 9 => nil }.compact],
      [800,  { 4 => 138, 5 => 162, 6 => 194, 7 => 270, 8 => nil, 9 => nil }.compact],
      [630,  { 4 => 135, 5 => 158, 6 => 189, 7 => 260, 8 => nil, 9 => nil }.compact],
      [500,  { 4 => 132, 5 => 154, 6 => 184, 7 => 250, 8 => nil, 9 => nil }.compact],
      [400,  { 4 => 129, 5 => 150, 6 => 179, 7 => 240, 8 => nil, 9 => nil }.compact],
      [320,  { 4 => 126, 5 => 146, 6 => 174, 7 => 230, 8 => nil, 9 => nil }.compact],
      [250,  { 4 => 123, 5 => 142, 6 => 170, 7 => 220, 8 => nil, 9 => nil }.compact],
      [200,  { 4 => 120, 5 => 138, 6 => 166, 7 => 210, 8 => nil, 9 => nil }.compact],
      [160,  { 4 => 117, 5 => 135, 6 => 162, 7 => 200, 8 => 290, 9 => nil }.compact],
      [125,  { 4 => 114, 5 => 132, 6 => 158, 7 => 192, 8 => 275, 9 => nil }.compact],
      [100,  { 4 => 111, 5 => 129, 6 => 154, 7 => 185, 8 => 260, 9 => nil }.compact],
      [80,   { 4 => 108, 5 => 126, 6 => 150, 7 => 180, 8 => 250, 9 => nil }.compact],
      [63,   { 4 => 105, 5 => 123, 6 => 146, 7 => 175, 8 => 240, 9 => nil }.compact],
      [50,   { 4 => 102, 5 => 120, 6 => 142, 7 => 170, 8 => 230, 9 => nil }.compact],
      [40,   { 4 => 100, 5 => 117, 6 => 138, 7 => 165, 8 => 220, 9 => 300 }.compact],
      [32,   { 4 => nil, 5 => 114, 6 => 135, 7 => 155, 8 => 200, 9 => 280 }.compact],
      [25,   { 4 => nil, 5 => 111, 6 => 132, 7 => 150, 8 => 190, 9 => 270 }.compact],
      [20,   { 4 => nil, 5 => 108, 6 => 129, 7 => 145, 8 => 185, 9 => 260 }.compact],
      [16,   { 4 => nil, 5 => 105, 6 => 126, 7 => 140, 8 => 180, 9 => 250 }.compact],
      [13,   { 4 => nil, 5 => 102, 6 => 123, 7 => 135, 8 => 170, 9 => 230 }.compact],
      [10,   { 4 => nil, 5 => 100, 6 => 120, 7 => 130, 8 => 155, 9 => 200 }.compact],
      [8,    { 4 => nil, 5 => nil, 6 => 116, 7 => 125, 8 => 150, 9 => 190 }.compact],
      [6,    { 4 => nil, 5 => nil, 6 => 114, 7 => 120, 8 => 140, 9 => 180 }.compact],
      [5,    { 4 => nil, 5 => nil, 6 => 111, 7 => 115, 8 => 135, 9 => 170 }.compact],
      [4,    { 4 => nil, 5 => nil, 6 => 108, 7 => 110, 8 => 125, 9 => 155 }.compact],
      [3,    { 4 => nil, 5 => nil, 6 => 105, 7 => 108, 8 => 120, 9 => 147 }.compact],
      [2,    { 4 => nil, 5 => nil, 6 => 103, 7 => 105, 8 => 114, 9 => 142 }.compact],
      [1,    { 4 => nil, 5 => nil, 6 => 100, 7 => nil, 8 => 105, 9 => 120 }.compact],
      [0.5,  { 4 => nil, 5 => nil, 6 => nil, 7 => nil, 8 => nil, 9 => 105 }.compact]
    ]
  end

  def get_rang_percents(rang)
    return [0, {}] if rang < 0.5

    rang_array.detect { |row| row.first < rang }.last
  end

  def get_group_rang
    (Entry.joins(:category)
                          .where('date < ?', @group.competition.date)
                          .where(status: 'confirmed')
                          .order(date: :desc)
                          .where(runner_id: @group.results.order(:place).limit(12).pluck(:runner_id))
                          .pluck('SUM(categories.points)')
                          .first || 0).ceil
  end

  def get_time_hash
    winner_time = @group.results.order(:place).first.time
    clasa       = @group.clasa

    percent_hash = get_rang_percents(@group.rang).map do |k, v|
      case clasa
      when 'MSRM', 'CMSRM', 'Seniori'
        [k, v] if [4, 5, 6].include?(k)
      when 'Juniori'
        [k, v] if [7, 8, 9].include?(k)
      end
    end.compact.to_h

    percent_hash.transform_values { |v| v * winner_time / 100 }
  end

  def update_result_category(res, time_hash)
    time = res.time
    place = res.place
    clasa = @group.clasa

    category_id = if clasa == 'MSRM' && place == 1
                    2
                  elsif clasa[/MSRM/] && (1..3).include?(place)
                    3
                  else
                    time_hash.detect { |_k, v| v >= time }&.first || 10
                  end

    res.update(category_id:)

    return unless res.category_id.to_i <= res.runner.category_id.to_i

    Entry.add_entry(res.slice(:runner_id, :date, :category_id).merge(result_id: res.id), 'unconfirmed')
  end
end

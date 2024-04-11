class SyncFosJob < ApplicationJob
  require 'net/http'

  queue_as :default

  def perform(*args)
    Runner.create!(id: 99999999)
    Runner.all.each do  |runner|
      next if runner.id == 99999999
      new_runner_id = runner.id + 10000
      update_runner_id(runner, new_runner_id)
    end

    response = Net::HTTP.get(URI("http://orienteering.md/categorii-sportive/?sort=id"))
    html =  Nokogiri::HTML(response)
    headers_index = get_header_index(html.at_css("table tr").css("td").map(&:text))
    runners = html.at_css("table").css("tr").drop(1).map do |tr|
      runner_name, surname = tr.css("td")[headers_index[:name]].text.split
      dob =  "#{tr.css("td")[headers_index[:dob]].text}-01-01"
      gender = detect_gender(surname)

      {
        runner_name: runner_name,
        surname:     surname,
        dob:         dob,
        gender:      gender,
        id:          tr.css("td")[headers_index[:id]].text.to_i,
        checksum:    Runner.get_checksum(runner_name, surname, dob, gender)
      }.compact
    end

    runners.each do |runner_params|
      runner = Runner.add_runner(runner_params)
      update_runner_id(runner, runner_params[:id])
    end

    Runner.find(99999999).destroy!
  end


   def get_header_index(row)
    headers = {}
    row.each_with_index do |cell, index|
      key = case cell
      when /FOS ID/i               then :id
      when /Nume, Prenume/i        then :name
      when /Anul nașterii/i        then :dob
      when /Club/i                 then :club
      when /Cat. Sportivă Curent/i then :current_category
      when /Expiră/i               then :category_valid
      when /Cat. maximă/i          then :best_category
      when /Gen/i                  then :gender
      else next
      end

      headers[key] = index
    end
    headers
  end

  def detect_gender(string)
    case string
    when "Nichita", "Ilia", "Mircea", "Nikita" then "M"
    when "Irene", /a$/i then "W"
    else "M"
    end
  end

  def update_runner_id(runner, id)
      Result.where(runner_id: runner.id).update_all(runner_id: 99999999)
      Entry.where(runner_id: runner.id).update_all(runner_id: 99999999)

      runner.update!(id:id)

      Result.where(runner_id: 99999999).update_all(runner_id: id)
      Entry.where(runner_id: 99999999).update_all(runner_id: id)

  end
end

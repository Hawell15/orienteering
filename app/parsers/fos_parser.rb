class FosParser < BaseParser
  require 'net/http'

  attr_accessor :hash

  def initialize
    @hash          = {}
    @return_data   = nil
    @return_result = nil
  end

  def convert
    html = connect
    extract_competition_details(html)
    parser(@hash)
  end

  def extract_competition_details(html)
    @hash = {
      competition_id: 0,
      groups: extract_groups_details(html)
    }
  end

  def extract_groups_details(html)
      [{
        group_id: 0,
        results:  extract_results(html)
      }]
  end

  def extract_results(html)
    headers_index = get_header_index(html.at_css("table tr").css("td").map(&:text))

    html.at_css("table").css("tr").drop(1).map do |tr|

      date = (tr.css("td")[headers_index[:category_valid]].text.to_date - 2.years).as_json rescue nil

      {
        date:        date,
        category_id: convert_category(tr.css("td")[headers_index[:current_category]].text).id,
        runner:      extract_runner_details(tr, headers_index),
        status:      "confirmed"
      }
    end.compact
  end

  def extract_runner_details(tr, headers_index)
    runner_name, surname = tr.css("td")[headers_index[:name]].text.split

    {
      runner_name:      runner_name,
      surname:          surname,
      dob:              "#{tr.css("td")[headers_index[:dob]].text}-01-01",
      gender:           extract_gender(tr.css("td")[headers_index[:gender]].text.presence || detect_gender(surname)),
      club:             tr.css("td")[headers_index[:club]].text.presence || Club.find(0).club_name,
      best_category_id: convert_category(tr.css("td")[headers_index[:best_category]].text).id,
      id:               tr.css("td")[headers_index[:id]].text.to_i,
      skip_matching:    true
    }.compact
  end

  def connect
    # cookie = begin
    #   get_cookies
    # rescue
    #   ""
    # end

    # sleep 2
    # url = URI("http://orienteering.md/categorii-sportive/?sort=id")

    # http = Net::HTTP.new(url.host, url.port)
    # request = Net::HTTP::Get.new(url)
    # request['Cookie'] = cookie
    # response = http.request(request)
    # Nokogiri::HTML(response.body)
    Nokogiri::HTML(File.read("public/fos_rezultate.html"))
  end

  def get_cookies
    html = Nokogiri::HTML(Net::HTTP.get(URI("http://orienteering.md/wp-login.php")))
    jetpack_protect_answer = html.at_css("input[name='jetpack_protect_answer']")["value"]
    jetpack_protect_num = html.at_css("label[for='jetpack_protect_answer']").text.split("+").map {|el| el[/\d+/].to_i}.sum
    sleep 2
     url = URI("http://orienteering.md/wp-login.php")

    username = ""
    password = ""

    http = Net::HTTP.new(url.host, url.port);
    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/x-www-form-urlencoded"
    request.body = "log=#{username}&pwd=#{password}&jetpack_protect_num=#{jetpack_protect_num}&jetpack_protect_answer=#{jetpack_protect_answer}&wp-submit=Autentificare&redirect_to=http%3A%2F%2Forienteering.md%2Fwp-admin%2F&testcookie=1"

    response = http.request(request)

    response.get_fields('Set-Cookie')[1].split("\;").first
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
end

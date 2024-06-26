class ExcelCompetitionParser < BaseParser
  attr_accessor :file, :hash

  def initialize(path)
    @path          = path
    @hash          = {}
    @return_data   = "competition"
    @return_result = nil
  end

  def convert
    file  = Roo::Spreadsheet.open(@path)
    extract_competition_details(file)

    parser(@hash)
    @return_result
  end

  def extract_competition_details(file)
    sheet   = file.sheet("Detalii")
    indexes = get_details_index(sheet)

    cell_value = ->(index_name) { sheet.cell(indexes.dig(:headers_index, index_name), indexes[:details_index]) }
    date = cell_value.call(:date)

    @hash = {
      competition_name: cell_value.call(:competition_name),
      date:             date.as_json,
      distance_type:    cell_value.call(:distance_type),
      location:         cell_value.call(:location),
      country:          cell_value.call(:country),
      groups:           extract_groups_details(file, file.sheets - ["Detalii", "Exemplu"], date)
    }

  end

  def extract_groups_details(file, group_names, date)
    group_names.map do |group_name|
      sheet = file.sheet(group_name)
      clasa = sheet.cell(
        (1..sheet.last_row).detect { |index| sheet.row(index).join[/Clasa/] },
        (1..sheet.last_column).detect { |index| sheet.column(index).join[/Clasa/] } + 1
      )
      {
        group_name: group_name,
        clasa:      clasa,
        results:    extract_results(sheet, extract_gender(group_name.first), date)
      }
    end
  end

  def extract_results(sheet, gender, date)
    indexes = get_result_index(sheet)
    (indexes[:details_index]..sheet.last_row).map do |index|
      cell_value = ->(index_name) { sheet.cell(index, indexes.dig(:headers_index, index_name)) }

      next unless cell_value.call(:runner_name)

      category     = convert_category(cell_value.call(:category_result))&.id

      {
        place:  cell_value.call(:place).to_i,
        time:   cell_value.call(:result),
        runner: extract_runner(sheet, index, indexes, gender, date),
        category_id:  category
      }.compact
    end
  end

  def extract_runner(sheet, index, indexes, gender, date)
    cell_value = ->(index_name) { sheet.cell(index, indexes.dig(:headers_index, index_name)) }
    current_category     = convert_category(cell_value.call(:category)).id

    {
      runner_name:      cell_value.call(:runner_name),
      surname:          cell_value.call(:surname),
      dob:              cell_value.call(:dob).as_json,
      gender:           gender,
      category_id:      current_category,
      club:             cell_value.call(:club),
      id:               cell_value.call(:id),
      date:             date - 1.days
    }.compact
  end

  def get_details_index(sheet)
    details_index = (1..sheet.last_column).detect { |index| sheet.column(index).join[/Denumirea/] }

    headers = {}
    (1..sheet.last_row).each do |index|
      key = case sheet.cell(index, details_index)
      when /Denumirea/i       then :competition_name
      when /Tipul Distantei/i then :distance_type
      when /Data/i            then :date
      when /Orasul/i          then :location
      when /Tara/i            then :country
      else next
      end

      headers[key] = index
    end
    {
      details_index:  details_index + 1,
      headers_index:  headers
    }
  end

  def get_result_index(sheet)
    details_index = (1..sheet.last_row).detect { |index| sheet.row(index).join[/Rezultat/] }

    headers = {}
    (1..sheet.last_column).each do |index|
      key = case sheet.cell(details_index, index)
      when /Prenumele/i then :surname
      when /Numele/i    then :runner_name
      when /Data/i      then :dob
      when /FOS ID/i    then :id
      when /Club/i      then :club
      when /Categoria Sportiva Curenta/i then :category
      when /Categoria Indeplinita/i then :category_result
      when /Locul/i     then :place
      when /Rezultat/i  then :result
      else next
      end

      headers[key] = index
    end
    {
      details_index:  details_index + 1,
      headers_index:  headers
    }
  end
end

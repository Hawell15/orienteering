class ExcelResultsParser < BaseParser
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

    @hash.each { |runner| parser(runner) }
    @return_result
  end

  def extract_competition_details(file)
    sheet   = file.sheet("Rezultate")
    indexes = get_result_index(sheet)

    @hash = (indexes[:details_index]..sheet.last_row).map do |index|
      cell_value = ->(index_name) { sheet.cell(index, indexes.dig(:headers_index, index_name)) }
      next unless cell_value.call(:runner_name)


     {
        competition_name: cell_value.call(:competition_name),
        date:             cell_value.call(:date).as_json,
        distance_type:    cell_value.call(:distance_type),
        location:         cell_value.call(:location),
        country:          cell_value.call(:country),
        groups:           extract_groups_details(sheet, indexes, index)
      }
    end.compact
  end

  def extract_groups_details(sheet, indexes, index)
    cell_value = ->(index_name) { sheet.cell(index, indexes.dig(:headers_index, index_name)) }

    [{
      group_name: cell_value.call(:group_name),
      results:    extract_results(sheet, indexes, index)
    }]
  end

  def extract_results(sheet, indexes, index)
    cell_value = ->(index_name) { sheet.cell(index, indexes.dig(:headers_index, index_name)) }

   [{
      place:  cell_value.call(:place).to_i,
      time:   cell_value.call(:result),
      runner: extract_runner(sheet,indexes, index )
    }]
  end

  def extract_runner(sheet, indexes, index )
    cell_value = ->(index_name) { sheet.cell(index, indexes.dig(:headers_index, index_name)) }

    {
      runner_name:      cell_value.call(:runner_name),
      surname:          cell_value.call(:surname),
      id:               cell_value.call(:id) ? cell_value.call(:id).to_i : nil,
      dob:              cell_value.call(:dob).as_json,
      club:             cell_value.call(:club).as_json,
      gender:           extract_gender(cell_value.call(:gender)),
      category_id:      Category.find_by(category_name: cell_value.call(:category)).id,
      best_category_id: Category.find_by(category_name: cell_value.call(:best_category)).id,
    }.compact
  end

  def get_result_index(sheet)
    details_index = (1..sheet.last_row).detect { |index| sheet.row(index).join[/Numele/] }

    headers = {}
    (1..sheet.last_column).each do |index|
      key = case sheet.cell(details_index, index)
      when /Prenumele/i         then :surname
      when /Numele Competitiei/ then :competition_name
      when /Numele/i            then :runner_name
      when /Genul/i             then :gender
      when /Data Nasterii/i     then :dob
      when /FOS ID/i            then :id
      when /Club/i              then :club
      when /Titlul Sportiv/     then :best_category
      when /Categoria Sporiva/i then :category
      when /Tipul Distantei/i   then :distance_type
      when /Data Indeplinirii/  then :date
      when /Localitatea/        then :location
      when /Tara/               then :country
      when /Grupa/              then :group_name
      when /Locul/i             then :place
      when /Rezultat/i          then :result
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

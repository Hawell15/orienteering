class ParserController < ApplicationController
  def file_results
    return unless params[:path]

    path = params[:path].tempfile.path
    parser = JsonParser.new(path)
    parser.convert
  end
end

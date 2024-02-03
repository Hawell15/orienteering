class ParserController < ApplicationController
  def file_results
    return unless params[:path]

    respond_to do |format|
      path         = params[:path].tempfile.path

      parser = if path[/json$/]
        JsonParser.new(path)
      elsif path[/html$/]
        HtmlParser.new(path)
      end
      @competition = parser.convert

      format.html { redirect_to competition_url(@competition), notice: 'Competitia a fost creata cu succes' }
    end
  end
end

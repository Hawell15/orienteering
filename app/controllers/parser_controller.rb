class ParserController < ApplicationController
  def file_results
    return unless params[:path]

    respond_to do |format|
      path         = params[:path].tempfile.path
      parser       = JsonParser.new(path)
      @competition = parser.convert

      format.html { redirect_to competition_url(@competition), notice: 'Competitia a fost creata cu succes' }
    end
  end
end

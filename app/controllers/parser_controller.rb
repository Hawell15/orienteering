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

  def iof_runners
     respond_to do |format|
      parser = IofRunnersParser.new
      parser.convert

      format.html { redirect_to "#{runners_url}?wre=true", notice: 'Datele wre despre sportivi au fost actualizate' }
    end
  end

  def iof_results
     respond_to do |format|
      parser = IofResultsParser.new
      parser.convert

      format.html { redirect_to "#{competitions_url}?wre=true", notice: 'Datele wre despre sportivi au fost actualizate' }
    end
  end
end

class ParserController < ApplicationController
  def index
  end

  def file_results
    return  redirect_to '/422.html' unless admin_user?

    return unless params[:path]

    respond_to do |format|
      path         = params[:path].tempfile.path

      parser = if path[/json$/]
        JsonParser.new(path)
      elsif path[/html$/]
        HtmlParser.new(path)
      elsif  params[:path].headers[/competitie.+xlsx/]
        ExcelCompetitionParser.new(path)
      elsif params[:path].headers[/rezultate.+xlsx/]
        ExcelResultsParser.new(path)
      end
      @competition = parser.convert

      format.html { redirect_to competition_url(@competition), notice: 'Competitia a fost creata cu succes' }
    end
  end

  def iof_runners
    return  redirect_to '/422.html' unless admin_user?

    respond_to do |format|
      IofRunnersJob.perform_later

      format.html { redirect_to "#{runners_url}?wre=true", notice: 'Datele wre despre sportivi au fost actualizate' }
    end
  end

  def iof_results
    return  redirect_to '/422.html' unless admin_user?

    respond_to do |format|
      IofResultsJob.perform_later

      format.html { redirect_to "#{competitions_url}?wre=true", notice: 'Datele wre despre sportivi au fost actualizate' }
    end
  end

  def fos_data
    return  redirect_to '/422.html' unless admin_user?

    respond_to do |format|
      parser = FosParser.new
      parser.convert

      format.html { redirect_to runners_url, notice: 'Datele  despre sportivi au fost extrase' }
    end
  end

  def sync_fos
    respond_to do |format|
      SyncFosJob.perform_later

      format.html { redirect_to runners_url, notice: 'Sincronizarea a inceput' }
    end
  end



end

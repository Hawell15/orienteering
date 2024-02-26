class ClubsController < ApplicationController
  before_action :set_club, only: %i[show edit update destroy]
  has_scope :search


  # GET /clubs or /clubs.json
  def index
    @clubs = apply_scopes(Club).all
    @clubs = @clubs.sorting(params[:sort_by], params[:direction]) if params[:sort_by]
  end

  # GET /clubs/1 or /clubs/1.json
  def show
    @runners = @club.runners
    filtering_params = params.slice(:category_id, :best_category_id, :gender, :wre, :search, :sort_by, :dob)
    filtering_params.each do |key, value|
      next if value.blank?

      @runners = case key
      when "wre"     then @runners.wre
      when "sort_by" then @runners.sorting(value, params[:direction])
      when "dob"     then @runners.dob(value[:from].presence, value[:to].presence)
      else @runners.public_send(key, value)
      end
    end
  end

  # GET /clubs/new
  def new
    @club = Club.new
  end

  # GET /clubs/1/edit
  def edit; end

  # POST /clubs or /clubs.json
  def create
    @club = Club.new(club_params)

    respond_to do |format|
      if @club.save
        format.html { redirect_to club_url(@club), notice: 'Club was successfully created.' }
        format.json { render :show, status: :created, location: @club }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @club.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clubs/1 or /clubs/1.json
  def update
    respond_to do |format|
      if @club.update(club_params)
        format.html { redirect_to club_url(@club), notice: 'Club was successfully updated.' }
        format.json { render :show, status: :ok, location: @club }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @club.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clubs/1 or /clubs/1.json
  def destroy
    @club.runners.update_all(club_id: 1)

    @club.destroy

    respond_to do |format|
      format.html { redirect_to clubs_url, notice: 'Club was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_club
    @club = Club.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def club_params
    params.require(:club).permit(:club_name, :territory, :representative, :email, :phone, :alternative_club_name)
  end
end

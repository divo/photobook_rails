class PhotoAlbumsController < ApplicationController
  before_action :set_photo_album, only: %i[ show edit update destroy print ]

  # GET /photo_albums or /photo_albums.json
  def index
    @photo_albums = PhotoAlbum.all
  end

  # GET /photo_albums/1 or /photo_albums/1.json
  def show
  end

  # GET /photo_albums/new
  def new
    @photo_album = PhotoAlbum.new
  end

  # GET /photo_albums/1/edit
  def edit
  end

  # POST /photo_albums or /photo_albums.json
  def create
    @photo_album = PhotoAlbum.new(photo_album_params)

    respond_to do |format|
      if @photo_album.save
        format.html { redirect_to photo_album_url(@photo_album), notice: "Photo album was successfully created." }
        format.json { render :show, status: :created, location: @photo_album }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @photo_album.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /photo_albums/1 or /photo_albums/1.json
  def update
    respond_to do |format|
      if @photo_album.update(photo_album_params)
        format.html { redirect_to photo_album_url(@photo_album), notice: "Photo album was successfully updated." }
        format.json { render :show, status: :ok, location: @photo_album }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @photo_album.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photo_albums/1 or /photo_albums/1.json
  def destroy
    @photo_album.destroy

    respond_to do |format|
      format.html { redirect_to photo_albums_url, notice: "Photo album was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def print
    # This should use Stimulus fancyness. What should the flow even look like?
    render_client = RenderClient.new(@photo_album)
    puts render_client.render_album
    puts "P R I N T"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo_album
      @photo_album = PhotoAlbum.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def photo_album_params
      params.require(:photo_album).permit(:name, images: [])
    end
end

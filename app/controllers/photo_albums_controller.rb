class PhotoAlbumsController < ApplicationController
  include ActiveStorage::SetCurrent
  before_action :set_photo_album, only: %i[ show edit update destroy print set_cover delete_page]
  before_action :authenticate_user!
  before_action :validate_destroy, only: %i[destroy]

  # GET /photo_albums or /photo_albums.json
  def index
    @photo_albums = current_user.photo_albums.all
  end

  # GET /photo_albums/1 or /photo_albums/1.json
  def show
    # TODO: Update the order estimate if it's over a day old
    if cancel_params[:cancel] == 'true'
      order = @photo_album.orders.find(cancel_params[:order_id])
      Rails.logger.info("ℹ️  Canceling order #{order.id}")
      order.cancel_draft!

      redirect_to photo_album_url(@photo_album), alert: 'Order cancelled'
    elsif success_params[:success] == 'true'
      order = @photo_album.orders.find(success_params[:order_id])
      Rails.logger.info("✅ Order #{order.id} checkout success")
      order.checkout! unless order.paid?

      redirect_to photo_album_url(@photo_album), notice: 'Order placed successfully. You can track your order from your account overview'
    end
  end

  # GET /photo_albums/new
  def new
    @photo_album = PhotoAlbum.new
    is_ios = request.user_agent =~ /iPhone|iPad/i
    if is_ios
      flash.now[:alert_ios_upload] = 'iOS web upload removes GPS data from photos.'
    end
  end

  # GET /photo_albums/1/edit
  def edit
  end

  # POST /photo_albums or /photo_albums.json
  def create
    @photo_album = PhotoAlbum.new(photo_album_params.merge(user_id: current_user.id))

    respond_to do |format|
      if @photo_album.save(context: :app)
        # Start the image format job, PhotoAlbum model will
        # kick of subsequent workflows itself
        flow = FormatImagesWorkflow.create(@photo_album.id)
        flow.start!
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
      @photo_album.assign_attributes(photo_album_params)
      if @photo_album.save(context: :app)
        # TODO: Start the metadata workflow??
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
    RenderAlbumJob.perform_later(@photo_album.present { |image| image.url }, nil)
    respond_to do |format|
      format.html { redirect_to photo_album_url(@photo_album), notice: "Photo album was successfully queued for printing." }
      format.json { head :no_content }
    end
  end

  def set_cover
    @photo_album.set_cover(params[:cover_id])
    respond_to do |format|
      format.html { redirect_to photo_album_url(@photo_album) }
      format.json { head :no_content }
    end
  end

  def delete_page
    @photo_album.delete_image(params[:image_id])
    respond_to do |format|
      format.html { redirect_to photo_album_url(@photo_album), alert: "Photo was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def set_page_caption
    photo_album = current_user.photo_albums.find(params[:photo_album_id])
    image = photo_album.images.find(params[:image_id])
    image.metadata[:caption] = params[:caption]
    image.save
    respond_to do |format|
      # 303 because https://api.rubyonrails.org/v7.0.4/classes/ActionController/Redirecting.html#method-i-redirect_to
      format.html { redirect_to action: :show, status: 303, id: photo_album.id }
      format.json { head :no_content }
    end
  end

  private

  def validate_destroy
    return if @photo_album.orders.reject { |o| o.state == 'draft' }.reject { |o| o.state == 'draft_canceled' }.empty?

    redirect_to photo_album_url(@photo_album), alert: 'Cannot delete a photo album with an open order. Contact support if you need to delete this album.'
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_photo_album
    @photo_album = current_user.photo_albums.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def photo_album_params
    params.require(:photo_album).permit(:name, :cancel, images: [])
  end

  def cancel_params
    params.permit(:id, :cancel, :order_id)
  end

  def success_params
    params.permit(:id, :success, :order_id)
  end
end

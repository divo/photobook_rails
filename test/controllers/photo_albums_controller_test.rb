require "test_helper"

class PhotoAlbumsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @photo_album = photo_albums(:one)
  end

  test "should get index" do
    get photo_albums_url
    assert_response :success
  end

  test "should get new" do
    get new_photo_album_url
    assert_response :success
  end

  test "should create photo_album" do
    assert_difference("PhotoAlbum.count") do
      post photo_albums_url, params: { photo_album: { name: @photo_album.name } }
    end

    assert_redirected_to photo_album_url(PhotoAlbum.last)
  end

  test "should show photo_album" do
    get photo_album_url(@photo_album)
    assert_response :success
  end

  test "should get edit" do
    get edit_photo_album_url(@photo_album)
    assert_response :success
  end

  test "should update photo_album" do
    patch photo_album_url(@photo_album), params: { photo_album: { name: @photo_album.name } }
    assert_redirected_to photo_album_url(@photo_album)
  end

  test "should destroy photo_album" do
    assert_difference("PhotoAlbum.count", -1) do
      delete photo_album_url(@photo_album)
    end

    assert_redirected_to photo_albums_url
  end
end

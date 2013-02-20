describe '/pictures/asset' do
  it "redirects to /pictures/asset" do
    get "/system/pictures/photos/11/original/Guitar_1.jpg"
    response.should redirect_to("/pictures/asset");
  end
end

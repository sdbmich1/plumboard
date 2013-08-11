class PictureJob < Struct.new(:photo_id)
  def perform
    Picture.find(self.photo_id).regenerate_styles
  end
end

module PaperclipStub
  def stub_paperclip_attachment(model, attachment)
    # model.any_instance.stub(attachment.to_sym).and_return File.join(Rails.root, 'spec', 'fixtures', 'photo.jpg')
    # model.any_instance.stub("#{attachment}_file_name".to_sym).and_return File.join(Rails.root, 'spec', 'fixtures', 'photo.jpg')
    Picture.any_instance.stub(:save_attached_files).and_return(true)
    Picture.any_instance.stub(:delete_attached_files).and_return(true)
    Picture.any_instance.stub(:post_process).and_return(true)
  end
end

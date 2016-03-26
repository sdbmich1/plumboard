module PaperclipStub
  def stub_paperclip_attachment(model, attachment)
    allow_any_instance_of(model).to receive(attachment.to_sym).and_return File.join(Rails.root, 'spec', 'fixtures', 'photo.jpg')
    allow_any_instance_of(model).to receive("#{attachment}_file_name".to_sym).and_return File.join(Rails.root, 'spec', 'fixtures', 'photo.jpg')
    allow_any_instance_of(Picture).to receive(:save_attached_files).and_return(true)
    allow_any_instance_of(Picture).to receive(:delete_attached_files).and_return(true)
    allow_any_instance_of(Picture).to receive(:post_process).and_return(true)
    allow_any_instance_of(Picture).to receive(:save).and_return(true)
  end
end

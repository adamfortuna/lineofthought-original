Paperclip::Attachment.interpolations[:uid] = proc do |attachment, style|
  attachment.instance.uid.downcase
end
require 'paperclip/media_type_spoof_detector'
# Paperclip.options[:content_type_mappings] = { jpeg: 'image/jpeg', jpg: 'image/jpeg' }

module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
end

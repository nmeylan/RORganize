# Author: Nicolas Meylan
# Date: 26.09.14
# Encoding: UTF-8
# File: paperclip_patch.rb


module Rorganize
  module Patches
    module PaperclipPatch
      module MediaTypeSpoofDetector
        def supplied_file_content_types
          @supplied_file_content_types ||= MimeMagic.by_path(@name).type
        end

        def supplied_file_media_types
          @supplied_file_media_types ||= MimeMagic.by_path(@name).mediatype
        end

      end
    end
  end
end
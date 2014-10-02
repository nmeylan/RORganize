# Author: Nicolas Meylan
# Date: 26.09.14
# Encoding: UTF-8
# File: paperclip_patch.rb

# Reason of this patch :
# The default behviour in paperclip is to call MIME class from ruby to detect the file's myme type.
# But it lead to some detection errors. For example, if a .sql is upload the default ruby MIME class
# detects the media_type as a application but when paperclip run the "file" unix command, it detects the
# media type as a "text". So the @see "spoofed?" return false.
# MimeMagic detect the same media type as the "file" unix command.
# Now the @see "spoofed?" return true.
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
# Ruby2D::Font

module Ruby2D
  class Font

    class << self

      # Get all fonts with full file paths
      def all_paths
        macos_font_paths  = ["/Library/Fonts", "#{Dir.home}/Library/Fonts"]
        linux_font_path   = %w{ /usr/share/fonts }
        windows_font_path = %w{ C:/Windows/Fonts }

        # If MRI and/or non-Bash shell (like cmd.exe)
        [Dir.pwd, *if Object.const_defined? :RUBY_PLATFORM
          case RUBY_PLATFORM
          when /darwin/ ; macos_font_paths
          when /linux/  ; linux_font_path
          when /mingw/  ; windows_font_path
          else ; raise Ruby2D::Error, "unknown Ruby platform #{RUBY_PLATFORM}"
          end
        # If MRuby
        else
          case `uname`
          when /Darwin/ ; macos_font_paths
          when /Linux/  ; linux_font_path
          when /MINGW/  ; windows_font_path
          else ; raise Ruby2D::Error, "unknown Ruby platform #{`uname`}"
          end
        end].flat_map do |dir|
          # MRuby does not have `Dir` defined
          if RUBY_ENGINE == "mruby"
            `find #{dir} -name *.ttf`.split "\n"
          # If MRI and/or non-Bash shell (like cmd.exe)
          else
            Dir["#{dir}/**/*.ttf"]
          end
        end.reject do |path|
          path.downcase.include?("bold")    ||
          path.downcase.include?("italic")  ||
          path.downcase.include?("oblique") ||
          path.downcase.include?("narrow")  ||
          path.downcase.include?("black")
        end.sort_by do |path|
          File.basename path.downcase, ".ttf"
        end
      end

      # Find a font file path from its name
      def path font_name
        all_paths.find{ |path| path.downcase.include? font_name.downcase }
      end

      # Get the default font
      def default
        paths = all_paths
        paths.find do |path|
          "arial" == File.basename(path.downcase, ".ttf")
        end or paths.first
      end

    end

  end
end

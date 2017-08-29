module Fastlane
  module Actions
    class ZipAction < Action
      def self.run(params)
        UI.message "Compressing #{params[:path]}..."

        params[:output_path] ||= params[:path]

        absolute_output_path = File.expand_path(params[:output_path])

        # Appends ".zip" if path does not end in ".zip"
        unless absolute_output_path.end_with?(".zip")
          absolute_output_path += ".zip"
        end

        absolute_output_dir = File.expand_path("..", absolute_output_path)
        FileUtils.mkdir_p(absolute_output_dir)

        Dir.chdir(File.expand_path("..", params[:path])) do # required to properly zip
          zip_options = params[:verbose] ? "r" : "rq"

          Actions.sh "zip -#{zip_options} #{absolute_output_path.shellescape} #{File.basename(params[:path]).shellescape}"
        end

        UI.success "Successfully generated zip file at path '#{File.expand_path(absolute_output_path)}'"
        return File.expand_path(absolute_output_path)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Compress a file or folder to a zip"
      end

      def self.details
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_ZIP_PATH",
                                       description: "Path to the directory or file to be zipped",
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find file/folder at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :output_path,
                                       env_name: "FL_ZIP_OUTPUT_NAME",
                                       description: "The name of the resulting zip file",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_ZIP_VERBOSE",
                                       description: "Enable verbose output of zipped file",
                                       default_value: true,
                                       optional: true)
        ]
      end

      def self.example_code
        [
          'zip',
          'zip(
            path: "MyApp.app",
            output_path: "Latest.app.zip"
          )',
          'zip(
            path: "MyApp.app",
            output_path: "Latest.app.zip",
            verbose: false
          )'
        ]
      end

      def self.category
        :misc
      end

      def self.output
        []
      end

      def self.return_value
        "The path to the output zip file"
      end

      def self.return_type
        :string
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end

module Fastlane
  module Actions
    module SharedValues
      BLACKBERRY_MAM_VERSION_ACTION_VERSION_NUMBER = :BLACKBERRY_MAM_VERSION_ACTION_VERSION_NUMBER
    end
    class BlackberryMamVersionAction < Action
      def self.run(params)
        selected_xcode_dev_dirpath = sh(
          'xcode-select --print-path',
          print_command: false,
          print_command_output: false
        ).strip

        selected_xcode_frameworks_path = File.join(
          selected_xcode_dev_dirpath,
          'Platforms',
          'iPhoneOS.platform',
          'Developer',
          'SDKs',
          'iPhoneOS.sdk',
          'System',
          'Library',
          'Frameworks'
        )

        good_framework_path = File.join(selected_xcode_frameworks_path, 'GD.framework')
        unless Dir.exist?(good_framework_path)
          Actions.lane_context[SharedValues::BLACKBERRY_MAM_VERSION_ACTION_VERSION_NUMBER] = "0"
          UI.user_error!("The Good framework is not installed")
          return
        end
        good_version_filepath = File.join(good_framework_path, 'version')
        good_version_filecontents = File.read(good_version_filepath)
        good_version = /version:\s+([\.0-9]+)/.match(good_version_filecontents)[1]

        Actions.lane_context[SharedValues::BLACKBERRY_MAM_VERSION_ACTION_VERSION_NUMBER] = good_version
      end

      def self.description
        "Checks the version of the installed Good framework"
      end

      def self.authors
        ["lyndsey-ferguson/ldferguson"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end

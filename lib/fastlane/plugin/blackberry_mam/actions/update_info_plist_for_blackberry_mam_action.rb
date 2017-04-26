require 'plist'

module Fastlane
  module Actions
    class UpdateInfoPlistForBlackberryMamAction < Action
      def self.run(params)
        # default entitlement version. we rarely, if ever, need to change this
        plist = Plist.parse_xml(params[:plist])

        gd_entitlement_version = "1.0.0.0"

        if params.values.key?(:good_entitlement_version)
          gd_entitlement_version = params[:good_entitlement_version]
        end

        plist["GDApplicationID"] = params[:good_entitlement_id]
        plist["GDApplicationVersion"] = gd_entitlement_version
        plist["GDLibraryMode"] = params[:build_simulation_mode] ? "GDEnterpriseSimulation" : "GDEnterprise"

        # create a set of url schemes for GD based on app id
        app_id = plist["CFBundleIdentifier"]
        url_schemes = [
          "#{app_id}.sc2",
          "#{app_id}.sc2.1.0.0.0",
          "com.good.gd.discovery"
        ]
        # Currently there is a problem if this plugin action is called in
        # another action. We are already in the fastlane folder, but other_action
        # is configured to try and go _back_ into the fastlane folder so
        # we will get an exception thrown from within other_action -> runner's execute_action
        fastlane_relpath = '.'
        fastlane_relpath = '..' if !Dir.exist?('./fastlane') && File.basename(Dir.pwd) == 'fastlane'

        Dir.chdir(fastlane_relpath) do
          good_sdk_version = Gem::Version.new(other_action.blackberry_mam_version)
          if good_sdk_version < Gem::Version.new('3.0.0.0')
            url_schemes.push("#{app_id}.sc")
          end
        end
        if params.values.fetch(:export_method, "app-store").casecmp("enterprise").zero?
          url_schemes.push("com.good.gd.discovery.enterprise")
        end

        # attempt to replace an existing set of GD url schemes
        replaced = false
        if plist.key?("CFBundleURLTypes")
          plist["CFBundleURLTypes"].each do |entry|
            next unless entry["CFBundleURLSchemes"].include?("com.good.gd.discovery")
            entry["CFBundleURLName"] = app_id
            entry["CFBundleURLSchemes"] = url_schemes
            replaced = true
            break
          end
        else
          plist["CFBundleURLTypes"] = []
        end

        unless replaced
          plist["CFBundleURLTypes"] << {
            "CFBundleURLName" => app_id,
            "CFBundleURLSchemes" => url_schemes
          }
        end
        Plist::Emit.save_plist(plist, params[:plist])
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "This plugin will update the plist so that the built application can be deployed and managed within BlackBerry's Good Dynamics Control Center for Enterprise Mobility Management."
      end

      def self.available_options
        # options the action supports.
        [
          FastlaneCore::ConfigItem.new(key: :plist,
                                     env_name: "FL_UPDATE_INFO_PLIST_FOR_BLACKBERRY_MAM_FILEPATH",
                                     description: "The file path to the plist that will be compiled to the app's Info.plist for the UpdateInfoPlistForBlackberryMamAction",
                                     verify_block: proc do |value|
                                       UI.user_error!("Invalid plist file path for UpdateInfoPlistForBlackberryMamAction given, pass using `plist: 'path/to/plist'`") if value.nil? || value.empty?
                                       UI.user_error!("Non-existant plist file for UpdateInfoPlistForBlackberryMamAction given") unless File.exist?(value)
                                     end),

          FastlaneCore::ConfigItem.new(key: :good_entitlement_version,
                                   env_name: "FL_UPDATE_INFO_PLIST_FOR_BLACKBERRY_MAM_ENTITLEMENT_VERSION",
                                   description: "The Good app version number for the UpdateInfoPlistForBlackberryMamAction",
                                   verify_block: proc do |value|
                                     pattern = Regexp.new('^(:?[1-9]\d{0,2})(:?\.(:?0|[1-9]\d{0,2})){0,3}$')
                                     failed_to_match = pattern.match(value).nil?
                                     UI.user_error!("Invalid Good app version for UpdateInfoPlistForBlackberryMamAction given, pass using `good_entitlement_version: '1.2.3.4'`") if failed_to_match
                                   end,
                                   optional: true,
                                   default_value: "1.0.0.0"),

          FastlaneCore::ConfigItem.new(key: :good_entitlement_id,
                                   env_name: "FL_UPDATE_INFO_PLIST_FOR_BLACKBERRY_MAM_ENTITLEMENT_ID",
                                   description: "The Good ID for the UpdateInfoPlistForBlackberryMamAction",
                                   verify_block: proc do |value|
                                     UI.user_error!("No Good ID for UpdateInfoPlistForBlackberryMamAction given, pass using `good_entitlement_id: 'com.example.good'`") if value and value.empty?
                                     UI.user_error!("Good ID must be 35 characters or fewer in order to work with Windows Phones") if value.length > 35
                                     UI.user_error!("Good ID must have not have any uppercase characters") if value =~ /[A-Z]/
                                   end), # the default value if the user didn't provide one

          FastlaneCore::ConfigItem.new(key: :export_method,
                                    env_name: "FL_UPDATE_INFO_PLIST_FOR_BLACKBERRY_MAM_EXPORT_METHOD",
                                    description: "The export method, \"app-store\" or \"enterprise\", for the UpdateInfoPlistForBlackberryMamAction",
                                    verify_block: proc do |value|
                                      UI.user_error!("Invalid export method given for UpdateInfoPlistForBlackberryMamAction given, pass using `export_method: 'app-store' or 'enterprise'`") if value and value.empty? || !["app-store", "enterprise"].include?(value)
                                    end,
                                    default_value: "enterprise"), # the default value if the user didn't provide one

          FastlaneCore::ConfigItem.new(key: :build_simulation_mode,
                                    env_name: "FL_UPDATE_INFO_PLIST_FOR_BLACKBERRY_MAM_BUILD_FOR_SIMULATOR",
                                    description: "True if the app should be built so that it simulates a connection to a Good Control Center server. Defaults to false",
                                    optional: true,
                                    type: TrueClass,
                                    verify_block: proc do |value|
                                      UI.user_error!("Invalid value #{value}. It must either be true or false") unless [true, false].include?(value)
                                    end,
                                    default_value: false) # the default value if the user didn't provide one
        ]
      end

      def self.authors
        ["Lyndsey Ferguson lyndsey-ferguson/ldferguson, Kevin Winters kjwinters969"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end

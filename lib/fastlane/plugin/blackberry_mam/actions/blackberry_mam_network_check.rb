module Fastlane
  module Actions
    class BlackberryMamNetworkCheckAction < Action
      require 'socket'
      require 'timeout'

      def self.run(params)
        are_all_connections_open = true
        connections = [
          {
            address: 'bxcheckin.good.com',
            port: '443'
          },
          {
            address: 'bxenroll.good.com',
            port: '443'
          },
          {
            address: 'gdentgw.good.com',
            port: '443'
          },
          {
            address: 'gdmdc.good.com',
            port: '443'
          },
          {
            address: 'gdmdc.good.com',
            port: '49152'
          },
          {
            address: 'gdrelay.good.com',
            port: '443'
          },
          {
            address: 'gdrelay.good.com',
            port: '15000'
          },
          {
            address: 'gdweb.good.com',
            port: '443'
          }
        ]
        connections << { address: 'gdcloudgc.good.com', port: '49160' } if params[:check_cloud_control]

        connections.each do |connection|
          is_open = is_port_open?(connection[:address], connection[:port])
          are_all_connections_open &&= is_open
          UI.message("Checking #{connection[:address]}:#{connection[:port]}: #{is_open ? '✅' : '❌'}")
        end
        are_all_connections_open
      end

      def self.is_port_open?(ip, port)
        begin
          Timeout.timeout(1) do
            begin
              s = TCPSocket.new(ip, port)
              s.close
              return true
            rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
              return false
            end
          end
        rescue Timeout::Error
        end

        return false
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Checks to see if the required network ports for BlackBerry Dynamics are open on the network"
      end

      def self.details
        "Make sure that devices and iOS Simulators can connect via your network to BlackBerry Dynamics Servers."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :check_cloud_control,
            env_name: "FL_BLACKBERRY_MAM_NETWORK_CHECK_CLOUD_CONTROL",
            description: "API Token for BlackberryMamNetworkCheckAction",
            type: TrueClass,
            default_value: true
          )
        ]
      end

      def self.return_value
        'True if network ports for BlackBerry Dynamics servers are open. False otherwise.'
      end

      def self.authors
        ["lyndsey-ferguson/@ldferguson"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end

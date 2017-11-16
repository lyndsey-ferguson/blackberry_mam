describe Fastlane do
  describe Fastlane::FastFile do
    describe "BlackberryMamNetworkCheckAction" do
      before(:each) do
        allow(TCPSocket).to receive(:new)
        allow(Timeout).to receive(:timeout).and_yield

        mock_socket = OpenStruct.new
        allow(mock_socket).to receive(:close)
        allow(TCPSocket).to receive(:new).and_return(mock_socket)
      end

      [
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
        },
        {
          address: 'gdcloudgc.good.com',
          port: '49160'
        }
      ].each do |connection|
        describe "#{connection[:address]}:#{connection[:port]}" do
          it 'passes if able to connect' do
            mock_socket = OpenStruct.new
            expect(mock_socket).to receive(:close)
            expect(TCPSocket).to receive(:new).with(connection[:address], connection[:port]).and_return(mock_socket)

            result = Fastlane::FastFile.new.parse("lane :test do
              blackberry_mam_network_check
            end").runner.execute(:test)

            expect(result).to be(true)
          end

          it 'fails if unable to connect' do
            expect(TCPSocket).to receive(:new).with(connection[:address], connection[:port]).and_raise(Errno::EHOSTUNREACH)

            result = Fastlane::FastFile.new.parse("lane :test do
              blackberry_mam_network_check
            end").runner.execute(:test)

            expect(result).to be(false)
          end
        end
      end

      describe "gdcloudgc.good.com:49160" do
        it 'is not checked when :check_cloud_control is false' do
          expect(TCPSocket).not_to receive(:new).with('gdcloudgc.good.com', '49160')

          result = Fastlane::FastFile.new.parse("lane :test do
            blackberry_mam_network_check(check_cloud_control: false)
          end").runner.execute(:test)

          expect(result).to be(true)
        end
      end
    end
  end
end

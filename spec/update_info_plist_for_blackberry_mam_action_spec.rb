require 'fastlane'
require 'plist'

describe Fastlane do
  describe Fastlane::FastFile do
    describe "UpdateInfoPlistForBlackberryMamAction" do
      before(:all) do
        @working_dir = Dir.pwd
        Dir.chdir('./fastlane')
      end

      after(:all) do
        Dir.chdir(@working_dir)
      end

      context "WHEN setting the basic required values on a simple Info.plist" do
        before(:each) do
          @temp_plistfile = Tempfile.new(['Info', '.plist'])
          FileUtils.copy_file("../spec/fixtures/plist/SimpleInfo.plist", @temp_plistfile.path)
          allow(Fastlane::Actions::BlackberryMamVersionAction).to receive(:run).and_return('2.4.0.5018')

          Fastlane::FastFile.new.parse("lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '#{@temp_plistfile.path}',
              good_entitlement_id: 'com.example.app.good',
            })
          end").runner.execute(:test)
          @plist = Plist.parse_xml(@temp_plistfile.path)
        end

        after(:each) do
          @temp_plistfile.unlink
        end

        it "THEN the GDApplicationID is set correctly" do
          expect(@plist["GDApplicationID"]).to eq("com.example.app.good")
        end
        it "THEN the GDApplicationVersion is set correctly" do
          expect(@plist["GDApplicationVersion"]).to eq("1.0.0.0")
        end
        it "THEN the GDLibraryMode is set to Enterprise" do
          expect(@plist["GDLibraryMode"]).to eq("GDEnterprise")
        end
        it "THEN the CFBundleURLTypes contains only the Good URL Schemes" do
          expect(@plist["CFBundleURLTypes"].size).to eq(1)

          url_types = @plist["CFBundleURLTypes"][0]
          expect(url_types.size).to eq(2)

          expect(url_types["CFBundleURLName"]).to eq("com.example.app")

          expect(url_types["CFBundleURLSchemes"].size).to eq(5)
          expect(url_types["CFBundleURLSchemes"]).to include(
            "com.example.app.sc",
            "com.example.app.sc2",
            "com.example.app.sc2.1.0.0.0",
            "com.good.gd.discovery",
            "com.good.gd.discovery.enterprise"
          )
        end
      end

      context "WHEN setting the export method to app-store on a simple Info.plist" do
        before(:each) do
          @temp_plistfile = Tempfile.new(['Info', '.plist'])
          FileUtils.copy_file("../spec/fixtures/plist/SimpleInfo.plist", @temp_plistfile.path)

          allow(Fastlane::Actions::BlackberryMamVersionAction).to receive(:run).and_return('2.4.0.5018')
          Fastlane::FastFile.new.parse("lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '#{@temp_plistfile.path}',
              good_entitlement_id: 'com.example.app.good',
              export_method: 'app-store'
            })
          end").runner.execute(:test)
          @plist = Plist.parse_xml(@temp_plistfile.path)
        end

        after(:each) do
          @temp_plistfile.unlink
        end

        it "THEN the CFBundleURLTypes does not contain the com.good.gd.discovery.enterprise scheme" do
          expect(@plist["CFBundleURLTypes"].size).to eq(1)

          url_types = @plist["CFBundleURLTypes"][0]
          expect(url_types.size).to eq(2)

          expect(url_types["CFBundleURLName"]).to eq("com.example.app")

          expect(url_types["CFBundleURLSchemes"].size).to eq(4)
          expect(url_types["CFBundleURLSchemes"]).to include(
            "com.example.app.sc",
            "com.example.app.sc2",
            "com.example.app.sc2.1.0.0.0",
            "com.good.gd.discovery"
          )
        end
      end

      context "WHEN setting the export method to app-store on a Existing Info.plist" do
        before(:each) do
          @temp_plistfile = Tempfile.new(['ExistingInfo', '.plist'])
          FileUtils.copy_file("../spec/fixtures/plist/ExistingInfo.plist", @temp_plistfile.path)

          allow(Fastlane::Actions::BlackberryMamVersionAction).to receive(:run).and_return('2.4.0.5018')
          Fastlane::FastFile.new.parse("lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '#{@temp_plistfile.path}',
              \# It is important to understand that the Good App Id does not change the URL schemes; that comes from the App Id
              good_entitlement_id: 'com.example.app.good',
              export_method: 'app-store'
            })
          end").runner.execute(:test)
          @plist = Plist.parse_xml(@temp_plistfile.path)
        end

        after(:each) do
          @temp_plistfile.unlink
        end

        it "THEN the CFBundleURLTypes is updated and does not contain the com.good.gd.discovery.enterprise scheme" do
          expect(@plist["CFBundleURLTypes"].size).to eq(2)

          url_types = @plist["CFBundleURLTypes"][1]
          expect(url_types.size).to eq(2)

          expect(url_types["CFBundleURLName"]).to eq("com.example.newname")

          expect(url_types["CFBundleURLSchemes"].size).to eq(4)
          expect(url_types["CFBundleURLSchemes"]).to include(
            "com.example.newname.sc",
            "com.example.newname.sc2",
            "com.example.newname.sc2.1.0.0.0",
            "com.good.gd.discovery"
          )
        end
      end

      context "WHEN setting the optional Good Version Number on a Simple Info.plist" do
        before(:each) do
          @temp_plistfile = Tempfile.new(['Info', '.plist'])
          FileUtils.copy_file("../spec/fixtures/plist/SimpleInfo.plist", @temp_plistfile.path)

          allow(Fastlane::Actions::BlackberryMamVersionAction).to receive(:run).and_return('2.4.0.5018')
          Fastlane::FastFile.new.parse("lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '#{@temp_plistfile.path}',
              \# It is important to understand that the Good App Id does not change the URL schemes; that comes from the App Id
              good_entitlement_id: 'com.example.app.good',
              good_entitlement_version: '97.201.30.12'
            })
          end").runner.execute(:test)
          @plist = Plist.parse_xml(@temp_plistfile.path)
        end

        after(:each) do
          @temp_plistfile.unlink
        end

        it "THEN the GDApplicationVersion is set correctly" do
          expect(@plist["GDApplicationVersion"]).to eq("97.201.30.12")
        end
      end

      context "WHEN setting the build_simulation_mode on the Simple Info.plist" do
        before(:each) do
          @temp_plistfile = Tempfile.new(['Info', '.plist'])
          FileUtils.copy_file("../spec/fixtures/plist/SimpleInfo.plist", @temp_plistfile.path)

          allow(Fastlane::Actions::BlackberryMamVersionAction).to receive(:run).and_return('2.4.0.5018')
          Fastlane::FastFile.new.parse("lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '#{@temp_plistfile.path}',
              \# It is important to understand that the Good App Id does not change the URL schemes; that comes from the App Id
              good_entitlement_id: 'com.example.app.good',
              build_simulation_mode: true
            })
          end").runner.execute(:test)
          @plist = Plist.parse_xml(@temp_plistfile.path)
        end

        after(:each) do
          @temp_plistfile.unlink
        end

        it "THEN the GDLibraryMode is set to GDEnterpriseSimulation" do
          expect(@plist["GDLibraryMode"]).to eq("GDEnterpriseSimulation")
        end
      end

      context "WHEN providing a missing or invalid plist" do
        it "THEN it fails appropriately when no plist file provided" do
          update_info_plist_for_blackberry_mam_no_plist = "lane :test do
            update_info_plist_for_blackberry_mam ({
              good_entitlement_id: 'com.example.app.good'
            })
          end"

          allow(Fastlane::Actions::BlackberryMamVersionAction).to receive(:run).and_return('2.4.0.5018')

          expect { Fastlane::FastFile.new.parse(update_info_plist_for_blackberry_mam_no_plist).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/Invalid plist file path for UpdateInfoPlistForBlackberryMamAction given/)
            end
          )
        end

        it "THEN it fails appropriately when an invalid plist file provided" do
          update_info_plist_for_blackberry_mam_invalid_plist = "lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '../spec/fixtures/plist/NoInfo.plist',
              good_entitlement_id: 'com.example.app.good'
            })
          end"

          allow(Fastlane::Actions::BlackberryMamVersionAction).to receive(:run).and_return('2.4.0.5018')

          expect { Fastlane::FastFile.new.parse(update_info_plist_for_blackberry_mam_invalid_plist).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/Non-existant plist file for UpdateInfoPlistForBlackberryMamAction given/)
            end
          )
        end
      end

      context "WHEN providing a missing or invalid Good App Id" do
        before(:each) do
          @temp_plistfile = Tempfile.new(['Info', '.plist'])
          FileUtils.copy_file("../spec/fixtures/plist/SimpleInfo.plist", @temp_plistfile.path)

          allow(Fastlane::Actions::BlackberryMamVersionAction).to receive(:run).and_return('2.4.0.5018')
        end

        after(:each) do
          @temp_plistfile.unlink
        end

        it "THEN it fails appropriately when no Good App Id provided" do
          update_info_plist_for_blackberry_mam_no_good_id = "lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '#{@temp_plistfile.path}'
            })
          end"

          expect { Fastlane::FastFile.new.parse(update_info_plist_for_blackberry_mam_no_good_id).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/No Good ID for UpdateInfoPlistForBlackberryMamAction given/)
            end
          )
        end

        it "THEN it fails appropriately when an empty Good App Id provided" do
          allow(Fastlane::Actions::BlackberryMamVersionAction).to receive(:run).and_return('2.4.0.5018')

          update_info_plist_for_blackberry_mam_no_good_id = "lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '#{@temp_plistfile.path}',
              good_entitlement_id: ''
            })
          end"

          expect { Fastlane::FastFile.new.parse(update_info_plist_for_blackberry_mam_no_good_id).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/No Good ID for UpdateInfoPlistForBlackberryMamAction given/)
            end
          )
        end

        it "THEN it fails appropriately when a Good App Id > 35 letters is provided" do
          allow(Fastlane::Actions::BlackberryMamVersionAction).to receive(:run).and_return('2.4.0.5018')

          update_info_plist_for_blackberry_mam_invalid_good_id = "lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '#{@temp_plistfile.path}',
              good_entitlement_id: 'com.example.app.good.hello.cruelworld'
            })
          end"

          expect { Fastlane::FastFile.new.parse(update_info_plist_for_blackberry_mam_invalid_good_id).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/Good ID must be 35 characters or fewer/)
            end
          )
        end

        it "THEN it fails appropriately when a Good App Id with uppercase letters is provided" do
          allow(Fastlane::Actions::BlackberryMamVersionAction).to receive(:run).and_return('2.4.0.5018')

          update_info_plist_for_blackberry_mam_invalid_good_id = "lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '#{@temp_plistfile.path}',
              good_entitlement_id: 'com.example.app.Good'
            })
          end"

          expect { Fastlane::FastFile.new.parse(update_info_plist_for_blackberry_mam_invalid_good_id).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/Good ID must have not have any uppercase characters/)
            end
          )
        end
      end

      context "WHEN invalid Good Version Numbers" do
        before(:each) do
          @temp_plistfile = Tempfile.new(['Info', '.plist'])
          FileUtils.copy_file("../spec/fixtures/plist/SimpleInfo.plist", @temp_plistfile.path)
          allow(Fastlane::Actions::BlackberryMamVersionAction).to receive(:run).and_return('2.4.0.5018')
        end

        after(:each) do
          @temp_plistfile.unlink
        end

        it "THEN it fails appropriately when the Good Version Number begins with 0" do
          update_info_plist_for_blackberry_mam_version_number_starts_with_zero = "lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '#{@temp_plistfile.path}',
              good_entitlement_id: 'com.example.app.good',
              good_entitlement_version: '023'
            })
          end"

          expect { Fastlane::FastFile.new.parse(update_info_plist_for_blackberry_mam_version_number_starts_with_zero).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/Invalid Good app version for UpdateInfoPlistForBlackberryMamAction given/)
            end
          )
        end

        it "THEN it fails appropriately when the Good Version Number's first section has a non-digit" do
          update_info_plist_for_blackberry_mam_version_number_starts_with_nondigit = "lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '#{@temp_plistfile.path}',
              good_entitlement_id: 'com.example.app.good',
              good_entitlement_version: '9a'
            })
          end"

          expect { Fastlane::FastFile.new.parse(update_info_plist_for_blackberry_mam_version_number_starts_with_nondigit).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/Invalid Good app version for UpdateInfoPlistForBlackberryMamAction given/)
            end
          )
        end

        it "THEN it fails appropriately when the Good Version Number's next section starts with 0" do
          update_info_plist_for_blackberry_mam_version_number_section_starts_with_zero = "lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '#{@temp_plistfile.path}',
              good_entitlement_id: 'com.example.app.good',
              good_entitlement_version: '92.012.11'
            })
          end"

          expect { Fastlane::FastFile.new.parse(update_info_plist_for_blackberry_mam_version_number_section_starts_with_zero).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/Invalid Good app version for UpdateInfoPlistForBlackberryMamAction given/)
            end
          )
        end

        it "THEN it fails appropriately when the Good Version Number's next section contains a non-digit" do
          update_info_plist_for_blackberry_mam_version_number_section_contains_non_digit = "lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '#{@temp_plistfile.path}',
              good_entitlement_id: 'com.example.app.good',
              good_entitlement_version: '92.12.1a'
            })
          end"

          expect { Fastlane::FastFile.new.parse(update_info_plist_for_blackberry_mam_version_number_section_contains_non_digit).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/Invalid Good app version for UpdateInfoPlistForBlackberryMamAction given/)
            end
          )
        end

        it "THEN it fails appropriately when the Good Version Number has a section with too many numbers" do
          update_info_plist_for_blackberry_mam_version_number_section_too_many_numbers = "lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '#{@temp_plistfile.path}',
              good_entitlement_id: 'com.example.app.good',
              good_entitlement_version: '92.12.1209.42'
            })
          end"

          expect { Fastlane::FastFile.new.parse(update_info_plist_for_blackberry_mam_version_number_section_too_many_numbers).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/Invalid Good app version for UpdateInfoPlistForBlackberryMamAction given/)
            end
          )
        end

        it "THEN it fails appropriately when the Good Version Number has too many sections" do
          update_info_plist_for_blackberry_mam_version_number_section_too_many_sections = "lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '#{@temp_plistfile.path}',
              good_entitlement_id: 'com.example.app.good',
              good_entitlement_version: '92.12.12.42.19'
            })
          end"

          expect { Fastlane::FastFile.new.parse(update_info_plist_for_blackberry_mam_version_number_section_too_many_sections).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/Invalid Good app version for UpdateInfoPlistForBlackberryMamAction given/)
            end
          )
        end
      end

      context "WHEN invalid export method is given" do
        before(:each) do
          @temp_plistfile = Tempfile.new(['Info', '.plist'])
          FileUtils.copy_file("../spec/fixtures/plist/SimpleInfo.plist", @temp_plistfile.path)
        end

        after(:each) do
          @temp_plistfile.unlink
        end

        it "THEN it fails appropriately" do
          update_info_plist_for_blackberry_mam_invalid_export_method = "lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '#{@temp_plistfile.path}',
              good_entitlement_id: 'com.example.app.good',
              good_entitlement_version: '92.12.12.42',
              export_method: 'ad-hoc'
            })
          end"

          expect { Fastlane::FastFile.new.parse(update_info_plist_for_blackberry_mam_invalid_export_method).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/Invalid export method given/)
            end
          )
        end
      end

      context "WHEN invalid build_simulation_mode is given" do
        before(:each) do
          @temp_plistfile = Tempfile.new(['Info', '.plist'])
          FileUtils.copy_file("../spec/fixtures/plist/SimpleInfo.plist", @temp_plistfile.path)
        end

        after(:each) do
          @temp_plistfile.unlink
        end

        it "THEN it fails appropriately" do
          update_info_plist_for_blackberry_mam_invalid_build_simulation_mode = "lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '#{@temp_plistfile.path}',
              good_entitlement_id: 'com.example.app.good',
              good_entitlement_version: '92.12.12.42',
              build_simulation_mode: 'please'
            })
          end"

          expect { Fastlane::FastFile.new.parse(update_info_plist_for_blackberry_mam_invalid_build_simulation_mode).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/'build_simulation_mode' value must be either `true` or `false`! Found String instead./)
            end
          )
        end
      end

      context 'WHEN the version of the Good SDK is v3.0.0.6008 or greater' do
        before(:each) do
          allow(Fastlane::Actions::BlackberryMamVersionAction).to receive(:run).and_return('3.0.0.6009')
          @temp_plistfile = Tempfile.new(['Info', '.plist'])
          FileUtils.copy_file("../spec/fixtures/plist/SimpleInfo.plist", @temp_plistfile.path)

          Fastlane::FastFile.new.parse("lane :test do
            update_info_plist_for_blackberry_mam ({
              plist: '#{@temp_plistfile.path}',
              good_entitlement_id: 'com.example.app.good',
            })
          end").runner.execute(:test)
          @plist = Plist.parse_xml(@temp_plistfile.path)
        end

        after(:each) do
          @temp_plistfile.unlink
        end

        it 'THEN there are no sc discover scheme\'s' do
          url_types = @plist["CFBundleURLTypes"][0]
          expect(url_types["CFBundleURLSchemes"]).not_to include(
            "com.example.app.sc"
          )
        end
      end
    end
  end
end

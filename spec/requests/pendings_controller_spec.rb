require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "PendingsController" do
  before { Device.destroy_all }
  before { host! "http://" + host }

  # General stub
  before { stub_get(Settings.type.uri).to_return(body: fixture('type.json') ) }
  before { stub_get(Settings.type.another.uri).to_return(body: fixture('type.json') ) }
  before { stub_request(:put, Settings.physical.uri) }


  # --------------------------
  # GET /devices/:id/pending
  # --------------------------
  context ".show" do
    before { @resource = DeviceDecorator.decorate(Factory(:device)) }
    before { @uri = "/devices/#{@resource.id.as_json}/pending" }
    before { @resource_not_owned = Factory(:device_not_owned) }

    before { @update_uri = "/devices/#{@resource.id.as_json}/properties" }
    before { @properties = json_fixture('properties.json')[:properties] }
    before { @params = { properties: @properties } }

    it_should_behave_like "not authorized resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth }

      context "when properties change" do
        context "with no params" do
          before { page.driver.put @update_uri, @params.to_json }

          it "should start pending" do
            visit @uri
            page.status_code.should == 200
            should_have_pending @resource.reload
            page.should have_content 'true'
          end
        end

        context "with :source physical" do
          before { page.driver.put "#{@update_uri}?source=physical", @params.to_json }

          it "should end pending" do
            visit @uri
            page.status_code.should == 200
            page.should have_content 'false'
          end
        end

        context "with :pending true" do
          before { page.driver.put "#{@update_uri}?pending=true", @params.to_json }

          it "should start/update pending" do
            visit @uri
            page.status_code.should == 200
            page.should have_content 'true'
          end
        end

        context "with :source physical and :pending true" do
          before { page.driver.put "#{@update_uri}?source=physical&pending=true", @params.to_json }

          it "should start pending" do
            visit @uri
            page.status_code.should == 200
            page.should have_content 'true'
          end
        end        
      end

      it "should expose the device URI" do
        visit @uri
        uri = "http://www.example.com/devices/#{@resource.id.as_json}"
        @resource.uri.should == uri
      end

      context "with host" do
        it "should change the URI" do
          visit "#{@uri}?host=www.lelylan.com"
          @resource.uri.should match("http://www.lelylan.com/")
        end
      end

      it_should_behave_like "a rescued 404 resource", "visit @uri", "devices"
    end
  end
end
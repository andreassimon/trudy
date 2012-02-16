require "./trudy"
require "rspec/core"
require "rack/test"

describe Trudy do
  include Rack::Test::Methods

  def app
    Trudy
  end

  it "locates the server" do
    ENV['TRUDY_HOST'] = 'localhost:3456'

    get "/locate.jsp"

    last_response.should be_ok
    last_response.body.should == "ping localhost:3456\nbroad localhost:3456"
  end

  CHOREOGRAPHY = {
      "success"   => "\x00\x00\x00\n\x00\b\x00\x00\x00\x00\b\x01\x00\x00\x00\x00\x00\x00",
      "cancelled" => "\x00\x00\x00\n\x00\b\x00\a\x00\x00\b\x01\a\x00\x00\x00\x00\x00",
      "failure"   => "\x00\x00\x00\n\x00\b\x00\n\x00\x00\b\x01\n\x00\x00\x00\x00\x00",
      "hanging"   => "\x00\x00\x00\n\x00\b\x00\r\x00\x00\b\x01\r\x00\x00\x00\x00\x00"
  }

  CHOREOGRAPHY.each do |status, choreo|

    describe "for status '#{status}'" do

      it "responds to '#{ status }'" do
        #exchange.publish(status, :key => 'trudy')
        post "/", :buildResult => status
        last_response.status.should == 201

        get '/vl/p4.jsp'
        last_response.should be_ok
      end

      it "sends files" do
        get "/#{status}.mp3"

        last_response.status.should == 200
      end

      it "sends choreography" do
        get "/#{status}.nab"

        last_response.status.should == 200
        last_response.body.should == choreo
      end
    end
  end

  it "sends bootcode" do
    get "/bc.jsp"

    last_response.status.should == 200
  end

end

describe "Strings and Integers" do
  it "should not be equal" do
    "0".should_not == 0
  end
end

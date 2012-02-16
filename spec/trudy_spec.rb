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

  ["cancelled", "failure", "hanging", "success"].each do |status|
    it "responds to '#{ status }'" do
      #exchange.publish(status, :key => 'trudy')
      post "/", :buildResult => status
      last_response.status.should == 201

      get '/vl/p4.jsp'
      last_response.should be_ok
    end
  end

  it "sends bootcode" do
    get "/bc.jsp"

    last_response.status.should == 200
  end

  it "sends files" do
    get "/failure.mp3"

    last_response.status.should == 200
  end

end

describe "Strings and Integers" do
  it "should not be equal" do
    "0".should_not == 0
  end
end

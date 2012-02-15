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
end

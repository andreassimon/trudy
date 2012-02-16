require "./trudy"
require "rspec/core"
require "rack/test"


describe Trudy do
  include Rack::Test::Methods

  def client
    unless @client
      @client = Bunny.new(ENV['RABBITMQ_URL'])
      @client.start
    end
    @client
  end

  def exchange
    @exchange ||= client.exchange('')
  end

  def queue
    @queue ||= client.queue(trudy_queue)
  end

  def app
    Trudy
  end

  it "locates the server" do
    ENV['TRUDY_HOST'] = 'localhost:3456'

    get "/locate.jsp"

    last_response.should be_ok
    last_response.body.should == "ping localhost:3456\nbroad localhost:3456"
  end

  it "does something???" do
    # publish a message to the exchange which then gets routed to the queue
    5.times do
      exchange.publish("cancelled", :key => 'trudy')
      exchange.publish("failure",   :key => 'trudy')
      exchange.publish("hanging",   :key => 'trudy')
      exchange.publish("success",   :key => 'trudy')
    end

    20.times do
      get '/vl/p4.jsp', :st => 0

      #last_response.body.should == ""
      last_response.should be_ok
    end
  end

  it "sends bootcode" do
    get "/bc.jsp"

    last_response.should be_ok
  end

  it "sends files" do
    get "/failure.mp3"

    last_response.should be_ok
  end

end

describe "Equality" do
  it "should compare strings and integers" do
    "0".should == 0
  end
end

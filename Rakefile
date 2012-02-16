require "./trudy"

task :run do
  Trudy.run!
end

def rabbitmq_url
  puts "Using RabbitMQ URL: #{ ENV['RABBITMQ_URL'] }"
  ENV['RABBITMQ_URL'] ||= "amqp://localhost"
end

def client
  unless @client
    @client = Bunny.new(rabbitmq_url)
    @client.start
  end
  @client
end

def exchange
  @exchange ||= client.exchange('')
end


task :trigger do
  exchange.publish("cancelled", :key => 'trudy')
  exchange.publish("failure", :key => 'trudy')
  exchange.publish("hanging", :key => 'trudy')
  exchange.publish("success", :key => 'trudy')
end

task :cancelled do
  exchange.publish("cancelled", :key => 'trudy')
end


task :failure do
  exchange.publish("failure", :key => 'trudy')
end

task :hanging do
  exchange.publish("hanging", :key => 'trudy')
end

task :success do
  exchange.publish("success", :key => 'trudy')
end

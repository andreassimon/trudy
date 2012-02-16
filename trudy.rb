require 'bunny'
require 'haml'
require 'sass'
require 'sinatra/base'
require 'term/ansicolor'

include Term::ANSIColor

ENV['TRUDY_HOST'] ||= "192.168.43.187:4567"
ENV['TRUDY_QUEUE'] ||= "trudy"
ENV['RABBITMQ_URL'] ||= "amqp://localhost"

print "\n"
print yellow, "TRUDY_HOST   = ", red, "#{ ENV['TRUDY_HOST'] }", reset, "\n"
print yellow, "TRUDY_QUEUE  = ", red, "#{ ENV['TRUDY_QUEUE'] }", reset, "\n"
print yellow, "RABBITMQ_URL = ", red, "#{ ENV['RABBITMQ_URL'] }", reset, "\n\n"

# heroku addons:add rabbitmq
# heroku config:add TRUDY_HOST=<app_name>.heroku.com
# heroku config:add TRUDY_QUEUE=<queue-name>

class Trudy < Sinatra::Base
  EARS = {
      'success'   => 0x00,
      'cancelled' => 0x07,
      'failure'   => 0x0A,
      'hanging'   => 0x0D
  }

  AMBIENT_FREQUENCY = 1
  PING_SECONDS      = 1

  def trudy_host
    @trudy_host ||= ENV['TRUDY_HOST']
  end

  def trudy_queue
    @trudy_queue ||= ENV['TRUDY_QUEUE']
  end

  def rabbitmq_url
    @rabbitmq_url ||= ENV['RABBITMQ_URL']
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

  def queue
    @queue ||= client.queue(trudy_queue)
  end

  def send_byte_array byte_array
    puts "Packing byte array: #{ byte_array }"
    byte_array.pack('c*')
  end

  def trudy_file filename
    File.join 'files', filename
  end

  def trudy_ambient frequency
    trudy_head + trudy_ambient_block(frequency) + trudy_foot
  end

  def trudy_ambient_block frequency
    [0x04, 0x00, 0x00, 0x17 + frequency, 0x7F, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] + [0x01] * frequency + [0x00]
  end

  def trudy_choreography status
    [0x00, 0x00, 0x00, 0x0A] +
        [0x00, 0x08, 0x00, EARS[status], 0x00] +
        [0x00, 0x08, 0x01, EARS[status], 0x00] +
    [0x00, 0x00, 0x00, 0x00]
  end

  def trudy_foot
    [0xFF]
  end

  def trudy_head
    [0x7F]
  end

  def trudy_obfuscate_message message
    print "Obfuscate message '", red, message, reset, "'", "\n"
    inversion_table = [0x01, 0xAB, 0xCD, 0xB7, 0x39, 0xA3, 0xC5, 0xEF, 0xF1, 0x1B, 0x3D, 0xA7, 0x29, 0x13, 0x35, 0xDF, 0xE1, 0x8B, 0xAD, 0x97, 0x19, 0x83, 0xA5, 0xCF, 0xD1, 0xFB, 0x1D, 0x87, 0x09, 0xF3, 0x15, 0xBF, 0xC1, 0x6B, 0x8D, 0x77, 0xF9, 0x63, 0x85, 0xAF, 0xB1, 0xDB, 0xFD, 0x67, 0xE9, 0xD3, 0xF5, 0x9F, 0xA1, 0x4B, 0x6D, 0x57, 0xD9, 0x43, 0x65, 0x8F, 0x91, 0xBB, 0xDD, 0x47, 0xC9, 0xB3, 0xD5, 0x7F, 0x81, 0x2B, 0x4D, 0x37, 0xB9, 0x23, 0x45, 0x6F, 0x71, 0x9B, 0xBD, 0x27, 0xA9, 0x93, 0xB5, 0x5F, 0x61, 0x0B, 0x2D, 0x17, 0x99, 0x03, 0x25, 0x4F, 0x51, 0x7B, 0x9D, 0x07, 0x89, 0x73, 0x95, 0x3F, 0x41, 0xEB, 0x0D, 0xF7, 0x79, 0xE3, 0x05, 0x2F, 0x31, 0x5B, 0x7D, 0xE7, 0x69, 0x53, 0x75, 0x1F, 0x21, 0xCB, 0xED, 0xD7, 0x59, 0xC3, 0xE5, 0x0F, 0x11, 0x3B, 0x5D, 0xC7, 0x49, 0x33, 0x55, 0xFF]
    print message.bytes.to_a, "\n"
    obfuscated_message_bytes = []
    last_byte = 0x23
    message.each_byte do |byte|
      obfuscated_message_bytes << (inversion_table[last_byte.modulo(0x80)] * byte + 0x2F).modulo(0x100)
      last_byte = byte
    end
    obfuscated_message_bytes
  end

  def trudy_ping seconds
    trudy_head + trudy_ping_block(seconds) + trudy_foot
  end

  def trudy_ping_block seconds
    [0x03, 0x00, 0x00, 0x01, seconds]
  end

  def trudy_reboot
    trudy_head + trudy_reboot_block + trudy_foot
  end

  def trudy_reboot_block
    [0x09, 0x00, 0x00, 0x00]
  end

  post '/' do
    exchange.publish params[:buildResult], :key => trudy_queue
    status 201
  end

  get '/bc.jsp' do
    send_file trudy_file 'bootcode.bin'
  end

  get '/locate.jsp' do
    response = "ping #{ trudy_host }\nbroad #{trudy_host}"
    puts "Response: #{ response }"
    response
  end

  get '/vl/p4.jsp' do
    if queue.message_count > 0
      payload = queue.pop[:payload]
      print "Payload: ", red, "#{payload}", reset, "\n"
      send_byte_array trudy_message payload
    else
      send_byte_array trudy_ping PING_SECONDS
    end
  end

  def trudy_message status
    trudy_head + trudy_message_block(status) + trudy_foot
  end

  def trudy_message_block status
    trudy_obfuscated_message = trudy_obfuscate_message "ID 0\nMU #{trudy_host}/#{status}.mp3\nCH #{trudy_host}/#{status}.nab"
    [0x0A, 0x00, 0x00, trudy_obfuscated_message.length] + trudy_obfuscated_message
  end

  get '/index.css' do
    sass :index
  end

  get '/:filename.nab' do
    send_byte_array trudy_choreography params[:filename]
  end

  get '/:filename' do
    send_file trudy_file params[:filename]
  end

  get '/' do
    haml :index
  end

end

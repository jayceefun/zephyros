require 'socket'
require 'json'
require 'thread'

@s = TCPSocket.new 'localhost', 1235

@id = 0
@queues = {}

@queues[12] = Queue.new

def send(*data)
  @id += 1
  @queues[@id] = Queue.new
  json = ['request', @id].concat(data).to_json
  @s.write "#{json.size}\n#{json}"
  val = @queues[@id].pop
  @queues.delete @id
  val
end

def get
  size = @s.gets
  msg = @s.readpartial(size.to_i)
  JSON.load(msg)
end

@thread = Thread.new do
  loop do
    val = get
    id = val[1]
    @queues[id] << val
  end
end

10.times do
  val = send 'set_title', 'woot'
  p val
end

p @queues[12].pop

@thread.join

@s.close



# class Zeph

#   def initialize
#     @s = TCPSocket.new 'localhost', 1235
#     at_exit { wait_for_responses }

#     @request_id = 0

#     @thread = Thread.new { wait_for_msg }
#     @responses = []
#   end

#   def send_msg(data)
#     @request_id += 1
#     data = ['request', @request_id, data]
#     json = data.to_json
#     @s.write "#{json.size}\n#{json}"
#     # @s.write 'hi'
#     @s.flush

#     puts 'sent'

#     loop do
#       # if @responses.size > 0
#       #   return @responses.pop
#       # end
#       founds = @responses.select{|response| response[1] == @request_id}
#       if founds.size > 0
#         puts 'FOUND!'
#         @responses.delete_if{|response| response[1] == @request_id}
#         p @responses
#         return founds.first
#       end
#     end
#   end

#   def handle_msg(msg)
#     puts 'response:'
#     p msg
#     @responses << msg
#   end

#   private

#   def wait_for_msg
#     loop do
#       size = @s.gets
#       puts 'waiting...'
#       data = @s.readpartial(size.to_i)
#       puts 'GOT...'
#       str, pi = data
#       handle_msg str
#     end
#   end

#   def wait_for_responses
#     @thread.join
#     @s.close
#   end

# end

# $z = Zeph.new




# class Window
#   def size
#     $z.send_msg(['sup'])
#   end
# end

# w = Window.new

# 10.times do
#   puts "the thing is #{w.size}"
# end

# puts 'ok then'




# __END__

# [:request,
#  3,
#  {
#    :receiver => 3,
#    :method => "size",
#    :args => ["size"],
#  }
# ]

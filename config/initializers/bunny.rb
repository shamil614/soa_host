require 'bunny'

$bunny = Bunny.new
$bunny.start


# Payment Notification Service
 channel = $bunny.create_channel
 exchange = channel.fanout('payments')
 queue = channel.queue('', exclusive: true)
 queue.bind(exchange)
 
 puts "Waiting for Payment events"
 
 queue.subscribe do |delivery_info, properties, body|
   puts "Received Message: #{body}"
 end

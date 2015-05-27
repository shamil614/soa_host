require 'bunny'

class PaymentClient
  attr_reader :channel, :exchange, :server_queue, :reply_queue

  def initialize
    @channel = $bunny.create_channel
    @exchange = @channel.default_exchange
    @server_queue = @channel.queue('rpc_payment', auto_delete: false)
    @reply_queue = @channel.queue('', exclusive: true)
  end

  def payments(user_id, state)
    response = nil
    message = { id: SecureRandom.hex, jsonrpc: '2.0', method: 'find_payments', params: [user_id, state]  }

    exchange.publish(JSON.generate(message), { correlation_id: message['id'], reply_to: reply_queue.name,
    routing_key: server_queue.name } )

    # subscribe to return queue. blocks interpreter to wait for response
    reply_queue.subscribe(block: true) do |delivery_info, properties, payload|
      Rails.logger.info "Properites: #{properties}"
      Rails.logger.info "Payload: #{payload}"

      if properties[:correlation_id] == message['id']
        response = payload # closure hoisting
        delivery_info.consumer.cancel # unblock the consumer
      end
    end
    JSON.parse(response)['result']
  end
end

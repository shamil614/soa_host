class HomeController < ApplicationController

  def index
    # let's pretend we have a logged in user
    current_user = OpenStruct.new(id: 1)

    payment_client = PaymentClient.new
    @paid_payments = payment_client.payments(current_user.id, 'paid')
    @unpaid_payments = payment_client.payments(current_user.id, 'unpaid')
    payment_client.channel.close
  end

end

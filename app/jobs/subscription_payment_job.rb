# frozen_string_literal: true

class SubscriptionNotOverdueError < StandardError
  def initialize(subscription, msg = "The subscription you are trying to charge is not overdue")
    @subscription = subscription
    super(msg)
  end

  def raven_context
    {subscription_id: subscription.id}
  end
end

class SubscriptionPaymentJob < ApplicationJob
  queue_as :default

  def perform(subscription)
    raise SubscriptionNotOverdueError.new(subscription) unless subscription.overdue?

    stripe_charge = create_charge(subscription)

    create_donation(subscription, stripe_charge) if stripe_charge
  end

  private

  def create_charge(subscription)
    user = subscription.user
    customer = find_stripe_customer(user)

    amount = subscription.amount.to_i
    amount_in_cents = amount * 100

    client = Stripe::StripeClient.new
    charge, _ = client.request {
      Stripe::Charge.create(
        customer: customer,
        amount: amount_in_cents,
        description: "Debt Collective membership monthly payment",
        currency: "usd",
        metadata: {subscription_id: subscription.id, amount: amount, user_id: user.id}
      )
    }

    charge
  rescue Stripe::CardError => e
    Raven.capture_exception(e)
    disable_subscription(subscription)

    false
  end

  def find_stripe_customer(user)
    customer = Stripe::Customer.retrieve(user.stripe_id) if user.stripe_id

    unless customer
      customer = Stripe::Customer.create(email: user.email)
      user.update(stripe_id: customer.id)
    end

    customer
  end

  def disable_subscription(subscription)
    subscription.disable!
  end

  def create_donation(subscription, stripe_charge)
    user = subscription.user

    donation = subscription.donations.new(
      amount: stripe_charge.amount / 100,
      charge_data: JSON.parse(stripe_charge.to_json),
      customer_stripe_id: user.stripe_id,
      donation_type: Donation::DONATION_TYPES[:subscription],
      status: stripe_charge.status,
      user: user,
      user_data: {email: user.email, name: user.name}
    )

    subscription.update!(last_charge_at: DateTime.now, active: true) if donation.save!
  end
end

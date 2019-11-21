# frozen_string_literal: true

require 'rails_helper'

describe 'User - manages their profile', type: :feature, js: true do
  let!(:user) { FactoryBot.create(:user) }
  let!(:subscription) { FactoryBot.create(:subscription, user_id: user.id, active: true) }
  let!(:one_time_donations) { FactoryBot.create_list(:donation, 5, user_id: user.id, donation_type: Donation::DONATION_TYPES[:one_off]) }

  before(:each) do
    allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(user)
  end

  it 'can view their subscription and donation history' do
    5.times do
      donation = FactoryBot.create(:donation, user_id: user.id)
      FactoryBot.create(:subscription_donation, subscription_id: subscription.id, donation_id: donation.id)
    end
    visit user_latest_donations_path(user)
    expect(page).to have_content('Your Donations History')

    user.donations.each do |donation|
      expect(page).to have_content(donation.amount)
    end
  end

  it 'can cancel an active subscription' do
    expect(subscription.active).to eq(true)
    visit user_current_subscription_path(user)
    expect(page).to have_content("You're subscribed")

    expect(page).to have_content(subscription.plan.name)

    click_button 'Cancel Subscription'

    expect(page).to have_content('Do you want to terminate your current subscription?')
    within '#cancel-subscription-dialog' do
      click_button 'Cancel Subscription'
    end

    expect(page).to have_content('No active subscription')
    subscription.reload
    expect(subscription.active).to eq(false)
  end
end

# frozen_string_literal: true

class CurrentUser < Delegator
  attr_accessor :user, :new_record
  alias __getobj__ user

  def initialize(user, payload, new_record)
    @user = user
    @payload = payload
    @new_record = new_record
  end

  def new_record?
    new_record
  end

  def groups
    @payload['groups']
  end

  def card_background_url
    @payload['card_background_url']
  end

  def profile_background_url
    @payload['profile_background_url']
  end

  def moderator?
    !!@payload['moderator']
  end

  def active?
    !!@payload['active']
  end
end

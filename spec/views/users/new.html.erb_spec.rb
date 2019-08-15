# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/new', type: :view do
  let(:user_email) { Faker::Internet.email }

  before(:each) do
    assign(:user, User.new(
                    first_name: 'MyString',
                    last_name: 'MyString',
                    email: user_email,
                    user_role: User::USER_ROLES[:user],
                    discourse_id: 'MyString'
                  ))
  end

  it 'renders new user form' do
    render

    assert_select 'form[action=?][method=?]', users_path, 'post' do
      assert_select 'input[name=?]', 'user[first_name]'
      assert_select 'input[name=?]', 'user[last_name]'
      assert_select 'input[name=?]', 'user[email]'
      assert_select 'input[name=?]', 'user[user_role]'
      assert_select 'input[name=?]', 'user[discourse_id]'
    end
  end
end

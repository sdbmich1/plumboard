require 'spec_helper'

describe "Sessions API" do
  let(:user) { create(:contact_user, password: 'abcde123', password_confirmation: 'abcde123') }

  it 'signs in' do
    post '/api/v1/sessions.json?email=' + user.email + '&password=abcde123'

    # test for the 200 status-code
    expect(response).to be_success

    # check the token
    expect(json['token']).not_to be_nil
  end

  it 'does not sign in - no password' do
    post '/api/v1/sessions.json?email=' + user.email 

    # test for the 200 status-code
    expect(response).not_to be_success

    # check the token
    expect(json['token']).to be_nil
  end

  it 'does not sign in' do
    post '/api/v1/sessions'

    # test for the 200 status-code
    expect(response).not_to eq 200

    # check the token
    expect(json['token']).to be_nil
  end
end

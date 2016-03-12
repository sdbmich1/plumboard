require 'spec_helper'

describe "Registrations API" do
  let(:attr) {{"first_name"=>"John", "last_name"=>"Doe", "email"=>"jdoe@test.com", "gender"=>"Male", "birth_date"=>"1994-04-04"}}
  let(:attrs) {{"first_name"=>"John", "last_name"=>"Doe", "email"=>"jdoe@test.com", "gender"=>"Male", "birth_date"=>"1994-04-04", 
      "password"=>"abcde123", "home_zip"=>"94108"}}
  let(:params) {{format: :json, user: attrs}}
  let(:param) {{format: :json, user: attr}}

  it 'signs in' do
    post '/api/v1/registrations.json', params

    # test for the 200 status-code
    expect(response).to be_success

    # check the token
    expect(json['token']).not_to be_nil
  end

  it 'does not sign in' do
    post '/api/v1/registrations.json', param

    # test for the 200 status-code
    expect(response).not_to eq 200

    # check the token
    expect(json['message']).not_to be_nil
  end
end

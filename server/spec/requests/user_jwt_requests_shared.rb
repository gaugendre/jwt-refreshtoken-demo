RSpec.shared_context 'jwt on user request' do
  before do
    Devise.setup do |config|
      config.jwt do |jwt|
        jwt.secret ||= 'testing'
      end
    end
  end

  let(:email) { 'john@doe.test' }
  let(:password) { 'password' }

  let!(:user) do
    User.create!(
      email: email,
      password: password,
      password_confirmation: password
    )
  end

  let(:new_jwt) do
    Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
  end

  let(:access_token) do
    new_jwt[0]
  end

  let(:sign_in_payload) do
    {
      "user": {
        "email": email,
        "password": password
      }
    }
  end

  let(:sign_in_payload_bad_email) do
    {
      "user": {
        "email": 'john@doe.invalid',
        "password": password
      }
    }
  end

  let(:sign_in_payload_bad_password) do
    {
      "user": {
        "email": email,
        "password": 'bad password'
      }
    }
  end
end

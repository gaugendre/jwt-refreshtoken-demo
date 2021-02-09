RSpec.shared_context "jwt on user request" do
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

  let(:request_headers) do
    { 'Accept' => 'application/json',
      'Content-Type' => 'application/json' }
  end

  let(:new_jwt) do
    Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
  end

  let(:access_token) do
    new_jwt[0]
  end
end

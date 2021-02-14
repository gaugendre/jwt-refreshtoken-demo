RSpec.shared_context "json api" do
  let(:accept_header) do
    { 'Accept' => 'application/json' }
  end

  let(:content_type_header) do
    { 'Content-Type' => 'application/json' }
  end

  subject(:json_content) do
    JSON.parse response.body
  end
end

RSpec.shared_examples 'ok response' do
  it { expect(response).to have_http_status(:ok) }
  it { expect(response.content_type).to include('application/json') }
end

RSpec.shared_examples 'unauthorized response' do
  it { expect(response).to have_http_status(:unauthorized) }
  it { expect(response.content_type).to include('application/json') }
end

RSpec.shared_examples 'no content response' do
  it do
    expect(response).to have_http_status(:no_content)
    expect(response.content_type).to be_blank
    expect(response.body).to be_blank
  end
end

RSpec.shared_examples 'no auth headers' do
  it { expect(response.headers.key?('Set-Cookie')).to be_falsy }
  it { expect(response.headers.key?('Authorization')).to be_falsy }
end

RSpec.shared_examples 'error description' do
  it { expect(json_content.key?('error')).to be_truthy }
  it { expect(json_content['error']).to be_kind_of String }
end

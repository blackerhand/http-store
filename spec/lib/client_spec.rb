class MockClient < HttpStore::Client
  def set_request
    {
      url:         'http://129.28.201.134/',
      http_method: 'get',
    }
  end
end

RSpec.describe HttpStore::Client do
  it "get a request" do
    client = MockClient.execute(nil, store_class: false)

    expect(client.response).not_to be_nil
    expect(client.response.status).to eq('ok')
  end
end

assert '#address' do
  http = SimpleHttp.new('http', '127.0.0.1', 80)
  assert_equal '127.0.0.1', http.address
end

assert '#port' do
  http = SimpleHttp.new('http', '127.0.0.1')
  assert_equal 80, http.port

  http = SimpleHttp.new('https', '127.0.0.1')
  assert_equal 443, http.port

  http = SimpleHttp.new('http', '127.0.0.1', 10080)
  assert_equal 10080, http.port
end


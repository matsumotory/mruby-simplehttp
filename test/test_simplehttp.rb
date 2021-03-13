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


host = '127.0.0.1'
port = 8000
app = Proc.new do |env|
  code = 200
  headers = { 'Server' => 'mruby-simplehttpserver' }
  path = env['PATH_INFO']
  method = env['REQUEST_METHOD']
  body = nil

  case path
  when '/index.html'
    headers['Content-Type'] = 'text/html; charset=utf-8'
    body = 'Hello World'
  when '/notfound'
    # Custom error response message
    body = "Not Found on this server: #{path}"
    code = 404
  end

  if method == 'POST' or method == 'PUT'
    headers['Content-Type'] = 'text/html; charset=utf-8'
    headers['Content-Length'] = env['Content-length']
  end

  [code, headers, [body]]
end

server = SimpleHttpServer.new(server_ip: host, port: port, app: app)
pid = fork { server.run }

# WORKAROUND: if without sleep, it often fails to test.
sleep 1

assert 'SimpleHttp#get' do
  http = SimpleHttp.new('http', host, port)

  res = http.get('/index.html', {'User-Agent' => 'test-agent'})
  assert_equal 200, res.code
  assert_equal '200 OK', res.status
  assert_include res.header.split("\r\n"), 'Content-Type:text/html; charset=utf-8'
  assert_equal 'Hello World', res.body

  res = http.get('/notfound', {'User-Agent' => 'test-agent'})
  assert_equal 404, res.code
  assert_equal '404 Not Found', res.status
  assert_equal 'Not Found on this server: /notfound', res.body
end

assert 'SimpleHttp#post http' do
  http = SimpleHttp.new('http', host, port)

  res = http.post('/upload', {'Body' => 'Hello World', 'Content-Length' => '11'})
  assert_equal 200, res.code
  assert_equal '200 OK', res.status
  assert_include res.header.split("\r\n"), 'Content-Length:11'
end

assert 'SimpleHttp#post http body longer than WRITE_BUF_SIZE' do
  body_length = SimpleHttp::WRITE_BUF_SIZE + 1
  body = 'a' * body_length

  http = SimpleHttp.new('http', 'httpbin.org')
  res = http.post('/post', {'Body' => body})

  assert_equal 200, res.code
  assert_equal '200 OK', res.status
  assert_equal body, JSON.parse(res.body)['data']
end

assert 'SimpleHttp#post https' do
  body = 'Hello World'

  https = SimpleHttp.new('https', 'httpbin.org')
  res = https.post('/post', {'Body' => body})

  assert_equal 200, res.code
  assert_equal '200 OK', res.status
  # https://httpbin.org/post returns POSTed body
  assert_equal body, JSON.parse(res.body)['data']
end

# Boundary value test around SimpleHttp::WRITE_BUF_SIZE
[SimpleHttp::WRITE_BUF_SIZE - 1, SimpleHttp::WRITE_BUF_SIZE, SimpleHttp::WRITE_BUF_SIZE + 1].each do |body_length|
  assert 'SimpleHttp#post https body longer than WRITE_BUF_SIZE' do
    body = 'a' * body_length

    https = SimpleHttp.new('https', 'httpbin.org')
    res = https.post('/post', {'Body' => body})

    assert_equal 200, res.code
    assert_equal '200 OK', res.status
    # https://httpbin.org/post returns POSTed body
    assert_equal body, JSON.parse(res.body)['data']
  end
end

assert 'SimpleHttp#put' do
  http = SimpleHttp.new('http', host, port)

  res = http.put('/upload', {'Body' => 'Hello World', 'Content-Length' => '11'})
  assert_equal 200, res.code
  assert_equal '200 OK', res.status
  assert_include res.header.split("\r\n"), 'Content-Length:11'
end

Process.kill :TERM, pid

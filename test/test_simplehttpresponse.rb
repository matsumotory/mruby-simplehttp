def message_body
  "Hello World"
end

def message_header
  <<-EOS.chomp.gsub("\n", "\r\n")
HTTP/1.1 200 OK
Date: Fri, 30 Mar 2018 16:55:37 GMT
Content-Type: text/html; charset=utf-8
Content-Length: #{message_body.length}
  EOS
end

def response
  SimpleHttp::SimpleHttpResponse.new("#{message_header}\r\n\r\n#{message_body}")
end

assert 'SimpleHttp::SimpleHttpResponse#initialize' do
  assert_nil SimpleHttp::SimpleHttpResponse.new("").header

  res = SimpleHttp::SimpleHttpResponse.new(message_header)
  assert_equal message_header, res.header

  assert_equal message_header, response.header
  assert_equal message_body, response.body
end

assert 'SimpleHttp::SimpleHttpResponse#[]' do
  assert_true response.respond_to? (:[])
end

assert 'SimpleHttp::SimpleHttpResponse#[]=' do
  assert_equal 'World Hello', response['body'] = 'World Hello'
end

assert 'SimpleHttp::SimpleHttpResponse#header' do
  assert_kind_of String, response.header
  assert_equal message_header, response.header
end

assert 'SimpleHttp::SimpleHttpResponse#headers' do
  assert_kind_of Hash, response.headers
  assert_equal '11', response.headers['content-length']
  assert_equal 'text/html; charset=utf-8', response.headers['content-type']
  assert_equal 'Fri, 30 Mar 2018 16:55:37 GMT', response.headers['date']
end

assert 'SimpleHttp::SimpleHttpResponse#body' do
  assert_kind_of String, response.body
  assert_equal message_body, response.body
end

assert 'SimpleHttp::SimpleHttpResponse#status' do
  assert_kind_of String, response.status
  assert_equal '200 OK', response.status
end

assert 'SimpleHttp::SimpleHttpResponse#code' do
  assert_kind_of Integer, response.code
  assert_equal 200, response.code
end

assert 'SimpleHttp::SimpleHttpResponse#date' do
  assert_kind_of String, response.date
  assert_equal 'Fri, 30 Mar 2018 16:55:37 GMT', response.date
end

assert 'SimpleHttp::SimpleHttpResponse#content_type' do
  assert_kind_of String, response.content_type
  assert_equal 'text/html; charset=utf-8', response.content_type
end

assert 'SimpleHttp::SimpleHttpResponse#content_length' do
  assert_kind_of String, response.content_length
  assert_equal message_body.length.to_s, response.content_length
end

assert 'SimpleHttp::SimpleHttpResponse#each' do
  assert_nothing_raised { response.each { |k, v| k.inspect } }
end

assert 'SimpleHttp::SimpleHttpResponse#each_name' do
  assert_nothing_raised { response.each_name { |n| n.inspect } }
end

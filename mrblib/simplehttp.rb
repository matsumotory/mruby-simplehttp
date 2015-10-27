class SimpleHttp
  DEFAULTPORT = 80
  DEFAULTHTTPSPORT = 443
  HTTP_VERSION = "HTTP/1.0"
  DEFAULT_ACCEPT = "*/*"
  SEP = "\r\n"

  def socket_class_exist?
      c = Module.const_get("TCPSocket")
      c.is_a?(Class)
  rescue
      return false
  end

  def uv_module_exist?
      c = Module.const_get("UV")
      c.is_a?(Module)
  rescue
      return false
  end

  def initialize(schema, address, port = nil)
    @use_socket = false
    @use_uv = false
    if socket_class_exist?
      @use_socket = true
    end

    if uv_module_exist?
      @use_uv = true
    end
    @uri = {}
    if @use_socket
      # nothing
    elsif @use_uv
      ip = ""
      UV::getaddrinfo(address, "http", ai_family: :ipv4) do |x, info|
        if info 
          ip = info.addr
        end
      end
      UV::run()
      @uri[:ip] = ip
    else
      raise "Not found Socket Class or UV Module"
    end
    @uri[:schema] = schema
    @uri[:address] = address
    if schema == "https"
      @uri[:port] = port ? port.to_i : DEFAULTHTTPSPORT
    else
      @uri[:port] = port ? port.to_i : DEFAULTPORT
    end
    self
  end

  def address; @uri[:address]; end
  def port; @uri[:port]; end

  def get(path = "/", req = nil)
    request("GET", path, req)
  end

  def post(path = "/", req = nil)
    request("POST", path, req)
  end

  # private
  def request(method, path, req)
    @uri[:path] = path
    if @uri[:path].nil?
      @uri[:path] = "/"
    elsif @uri[:path][0] != "/"
      @uri[:path] = "/" + @uri[:path]
    end
    request_header = create_request_header(method.upcase.to_s, req)
    response_text = send_request(request_header)
    SimpleHttpResponse.new(response_text)
  end

  def send_request(request_header)
    response_text = ""
    if @use_socket
      socket = TCPSocket.new(@uri[:address], @uri[:port])
      if @uri[:schema] == "https"
        entropy = PolarSSL::Entropy.new
        ctr_drbg = PolarSSL::CtrDrbg.new entropy
        ssl = PolarSSL::SSL.new
        ssl.set_endpoint PolarSSL::SSL::SSL_IS_CLIENT
        ssl.set_rng ctr_drbg
        ssl.set_socket socket
        ssl.handshake
        ssl.write request_header
        while chunk = ssl.read(2048)
          response_text += chunk
        end
        ssl.close_notify
        socket.close
        ssl.close
      else
        socket.write(request_header)
        while (t = socket.read(1024))
          response_text += t
        end
        socket.close
      end
    elsif @use_uv
      socket = UV::TCP.new()
      socket.connect(UV.ip4_addr(@uri[:ip].sin_addr, @uri[:port])) do |x|
        if x == 0
          socket.write(request_header) do |x|
            socket.read_start do |b|
              response_text += b.to_s 
            end
          end
        else
          socket.close()
        end
      end
      UV::run()
    else
      raise "Not found Socket Class or UV Module"
    end
    response_text
  end

  def create_request_header(method, req)
    req = {}  unless req
    str = ""
    body   = ""
    str += sprintf("%s %s %s", method, @uri[:path], HTTP_VERSION) + SEP
    header = {}
    req.each do |key,value|
      if ! header[key.capitalize].nil?
        if header[key.capitalize].kind_of?(Array)
          header[key.capitalize] << value
        else
          header[key.capitalize] = [header[key.capitalize], value]
        end
      else
        header[key.capitalize] = value
      end
    end
    header["Host"] = @uri[:address]  unless header.keys.include?("Host")
    header["Accept"] = DEFAULT_ACCEPT  unless header.keys.include?("Accept")
    header["Connection"] = "close"
    if header["Body"]
      body = header["Body"]
      header.delete("Body")
    end
    if method == "POST" && (not header.keys.include?("content-length".capitalize))
        header["Content-Length"] = (body || '').length
    end
    header.keys.sort.each do |key|
      str += sprintf("%s: %s", key, header[key]) + SEP
    end
    str + SEP + body
  end

  class SimpleHttpResponse
    SEP = SimpleHttp::SEP
    def initialize(response_text)
      @response = {}
      @headers = {}
      if response_text.empty?
        @response["header"] = nil
      elsif response_text.include?(SEP + SEP)
        @response["header"], @response["body"] = response_text.split(SEP + SEP, 2)
      else
        @response["header"] = response_text
      end
      parse_header
      self
    end

    def [](key); @response[key]; end
    def []=(key, value);  @response[key] = value; end

    def header; @response['header']; end
    def headers; @headers; end
    def body; @response['body']; end
    def status; @response['status']; end
    def code; @response['code']; end
    def date; @response['date']; end
    def content_type; @response['content-type']; end
    def content_length; @response['content-length']; end

    def each(&block)
      if block
        @response.each do |k,v| block.call(k,v) end
      end
    end
    def each_name(&block)
      if block
        @response.each do |k,v| block.call(k) end
      end
    end

    # private
    def parse_header
      return unless @response["header"]
      h = @response["header"].split(SEP)
      if h[0].include?("HTTP/1")
        @response["status"] = h[0].split(" ", 2).last
        @response["code"]   = h[0].split(" ", 3)[1].to_i
      end
      h.each do |line|
        if line.include?(": ")
          k,v = line.split(": ")
          if !  @response[k.downcase].nil?
            if  @response[k.downcase].kind_of?(Array)
              @response[k.downcase] << v
              @headers[k.downcase] << v
            else
              @response[k.downcase] = [@response[k.downcase], v]
              @headers[k.downcase] = [@headers[k.downcase], v]
            end
          else
            @response[k.downcase] = v
            @headers[k.downcase] = v
          end
        end
      end
    end
  end
end



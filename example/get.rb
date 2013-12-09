http = SimpleHttp.new("http", "127.0.0.1", 80)

http.get("/index.html", {'User-Agent' => "test-agent"})

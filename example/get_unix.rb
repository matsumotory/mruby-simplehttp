http = SimpleHttp.new("unix","/var/run/docker.sock")
http.get("/containers/json")

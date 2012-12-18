class GrowthForecast
  DEFAULTADDRESS  = "127.0.0.1"
  DEFAULTPORT     = 5125
  class Client
    def initialize(address, port)
      adress = DEFAULTADDRESS if adress.nil?
      port   = DEFAULTAPORT if adress.nil?
      @url = sprintf("http://%s:%s/api", address, port.to_s)
    end

    def post(config, data)
      http = HttpRequest.new()
      api_url = sprintf("%s/%s/%s/%s", @url, config[:service], config[:section], config[:gragh])
      http.post(api_url, {
        :number => data[:number],
        :color  => data[:color],
        :mode   => data[:mode],
      })
    end
  end
end

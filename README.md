# SimpleHttp Class for mruby
refactored SimpleHttp using mruby-socket or mruby-uv and mruby-http

original code is iij/mruby 

## install by mrbgems
 - add conf.gem line to `build_config.rb`
```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :git => 'https://github.com/matsumoto-r/mruby-simplehttp.git'
end
```

## example

```ruby
p SimpleHttp.new("127.0.0.1", 80).request("GET", "/index.html", {'User-Agent' => "test-agent"})
```

# License
under the MIT License:

* http://www.opensource.org/licenses/mit-license.php



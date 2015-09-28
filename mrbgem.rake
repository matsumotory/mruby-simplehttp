MRuby::Gem::Specification.new('mruby-simplehttp') do |spec|
  spec.license = 'MIT'
  spec.authors = 'MATSUMOTO Ryosuke'
  spec.version = '0.0.1'
  # need mruby-socket or mruby-uv
  spec.add_dependency('mruby-socket')
  spec.add_dependency('mruby-sprintf')
  # bug: https://gist.github.com/matsumoto-r/79d265bc0b51626f100c
  #spec.add_dependency('mruby-polarssl')
end

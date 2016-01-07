MRuby::Gem::Specification.new('mruby-simplehttp') do |spec|
  spec.license = 'MIT'
  spec.authors = 'MATSUMOTO Ryosuke'
  spec.version = '0.0.1'
  # need mruby-socket or mruby-uv
  spec.add_dependency('mruby-socket')
  spec.add_dependency('mruby-sprintf')
  spec.add_dependency('mruby-polarssl')
end

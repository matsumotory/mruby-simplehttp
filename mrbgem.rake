MRuby::Gem::Specification.new('mruby-simplehttp') do |spec|
  spec.license = 'MIT'
  spec.authors = 'MATSUMOTO Ryosuke'
  # need mruby-socket or mruby-uv
  spec.add_dependency('mruby-socket')
  spec.add_dependency('mruby-http')
end

require "#{MRUBY_ROOT}/lib/mruby/source"

MRuby::Gem::Specification.new('mruby-simplehttp') do |spec|
  spec.license = 'MIT'
  spec.authors = 'MATSUMOTO Ryosuke'
  spec.version = '0.0.1'
  spec.add_dependency('mruby-env')
  spec.add_test_dependency('mruby-sprintf', :core => 'mruby-sprintf')
  spec.add_dependency('mruby-polarssl')
  spec.add_test_dependency('mruby-simplehttpserver')

  # need mruby-socket or mruby-uv
  if MRuby::Source::MRUBY_VERSION >= '1.4.0'
    spec.add_dependency('mruby-io', core: 'mruby-io')
    spec.add_dependency('mruby-socket', :core => 'mruby-socket')
  else
    spec.add_dependency('mruby-io')
    spec.add_dependency('mruby-socket')
  end
end

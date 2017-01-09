Gem::Specification.new do |s|
  s.name        = 'active_record_postgresql_retry'
  s.version     = '0.0.1'
  s.date        = '2017-01-09'
  s.summary     = "This gem provides a patch that once included will retry the PostgreSQL operation in case the server has gone away"
  s.description = "This gem provides a patch that once included will retry the PostgreSQL operation in case the server has gone away"
  s.authors     = ["Alexandru Szasz"]
  s.email       = 'alexxed@gmail.com'
  s.files       = ["lib/active_record_postgresql_retry.rb", "LICENSE", "README.md"]
  s.homepage    =
    'https://github.com/alexxed/active_record_postgresql_retry'
  s.license       = 'MIT'
  s.add_dependency 'activerecord'
end
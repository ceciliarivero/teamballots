require_relative '../app.rb'

prepare do
  Ohm.redis.call('flushdb')
end

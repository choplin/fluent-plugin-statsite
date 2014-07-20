require 'test/unit'
require 'fluent/log'
require 'fluent/test'

$log = Fluent::Log.new(Fluent::Test::DummyLogDevice.new, Fluent::Log::LEVEL_WARN)

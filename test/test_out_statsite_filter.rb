require 'helper'
require 'fluent/plugin/out_statsite_filter'

class Fluent::StatsiteFilterOutput
  attr_reader :respawns
end

class StatsiteFilterOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  ROOT = File.expand_path('..', File.dirname(__FILE__))
  PATH = ROOT + '/vendor/statsite/statsite'

  CONFIG = %[
    type statsite
    tag statsite
    metrics [
      "${status}:1|c"
    ]
    histograms [
      {"prefix": "k", "min": 0, "max": 10, "width": 1.0}
    ]
    statsite_path "#{PATH}"
    statsite_flush_interval 1s
    timer_eps 0.01
    set_eps 0.02
    child_respawn 5
  ]

  RECORDS = [
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::OutputTestDriver.new(Fluent::StatsiteFilterOutput).configure(conf, true)
  end

  def test_configure
    d = create_driver

    assert_equal 'statsite', d.instance.tag
    assert d.instance.metrics.all?{|m| m.class == Fluent::StatsitePlugin::Metric}
    assert d.instance.histograms.all?{|m| m.class == Fluent::StatsitePlugin::Histogram}
    assert_equal PATH, d.instance.statsite_path
    assert_equal 1, d.instance.statsite_flush_interval
    assert_equal 0.01, d.instance.timer_eps
    assert_equal 0.02, d.instance.set_eps
    assert_equal 5, d.instance.respawns
  end

  def test_emit
    d = create_driver

    d.run do
      records.each { |r| d.emit(r, Time.now) }
    end

    emits = d.emits

    count_result = emits.pop
    assert_equal 'statsite', count_result[0]
    assert_equal({type: 'counts', key: '${status}', value: 4.0}, count_result[2])
  end
end

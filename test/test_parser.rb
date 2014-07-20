require 'helper'
require 'fluent/plugin/statsite/format'

include Fluent::StatsitePlugin

class StatsiteParserTest < Test::Unit::TestCase
  def setup
    @res = []
    proc = Proc.new {|time, record| @res << {time: time, record:record } }
    @parser = StatsiteParser.new(proc)
  end

  def test_eachline_kv
    line = 'kv.k|1.000000|1405869579'
    @parser.each_line(line)
    expected = {
      time: 1405869579,
      record: { type: 'kv', key: 'k', value: 1.000000 }
    }
    assert_equal expected, @res.pop
  end

  def test_eachline_gauge
    line = 'gauges.k|1.000000|1405869579'
    @parser.each_line(line)
    expected = {
      time: 1405869579,
      record: { type: 'gauges', key: 'k', value: 1.000000 }
    }
    assert_equal expected, @res.pop
  end

  def test_eachline_counts
    line = 'counts.k|1.000000|1405869579'
    @parser.each_line(line)
    expected = {
      time: 1405869579,
      record: { type: 'counts', key: 'k', value: 1.000000 }
    }
    assert_equal expected, @res.pop
  end

  def test_eachline_sets
    line = 'sets.k|1|1405869579'
    @parser.each_line(line)
    expected = {
      time: 1405869579,
      record: { type: 'sets', key: 'k', value: 1 }
    }
    assert_equal expected, @res.pop
  end

  def test_eachline_timers
    line = 'timers.k.sum|1.000000|1405869579'
    @parser.each_line(line)
    expected = {
      time: 1405869579,
      record: { type: 'timers', key: 'k', value: 1.000000, statistic: 'sum' }
    }
    assert_equal expected, @res.pop
  end

  def test_eachline_timers_count
    line = 'timers.k.count|1|1405869579'
    @parser.each_line(line)
    expected = {
      time: 1405869579,
      record: { type: 'timers', key: 'k', value: 1, statistic: 'count' }
    }
    assert_equal expected, @res.pop
  end

  def test_eachline_timers_histogram
    line = 'timers.k.histogram.bin_<0.00|0|1405869579'
    @parser.each_line(line)
    expected = {
      time: 1405869579,
      record: { type: 'timers', key: 'k', value: 0, statistic: 'histogram', range: '<0.00' }
    }
    assert_equal expected, @res.pop
  end

  def test_eachline_invalid_line
    line = 'test'
    assert_raise(RuntimeError) { @parser.each_line(line) }
  end
end

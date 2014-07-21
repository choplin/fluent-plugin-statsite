require_relative 'statsite/child_process'
require_relative 'statsite/format'
require_relative 'statsite/metric'
require_relative 'statsite/histogram'

require 'tempfile'
require 'timeout'

module Fluent
  class StatsiteFilterOutput < Fluent::BufferedOutput
    include Fluent::StatsitePlugin

    Fluent::Plugin.register_output('statsite_filter', self)

    # TODO: should be configurable?
    CONFIG_VALIDATION_WAIT = 0.1

    config_param :tag,                     :string
    config_param :metrics,                 :array
    config_param :histograms,              :array,    :default => []
    config_param :statsite_path,           :string,   :default => 'statsite'
    config_param :statsite_flush_interval, :time,     :default => 10
    config_param :timer_eps,               :float,    :default => 0.01
    config_param :set_eps,                 :float,    :default => 0.02
    config_param :child_respawn,           :string,   :default => nil
    # TODO: should support input_counter?

    def initialize
      super
    end

    def configure(conf)
      super
      @metrics = validate_metrics
      @metrics.each{|m| @log.info "out_statsite: #{m}"}

      @histograms = validate_histograms

      @respawns = configure_respawns

      @parser = StatsiteParser.new(method(:on_message))
      @formatter = StatsiteFormatter.new(@metrics)

      $log.info "out_statsite: statsite config\n\n#{config}"
      @conf = Tempfile.new('fluent-plugin-statsite-')
      @conf.puts config
      @conf.flush

      @child = ChildProcess.new(@parser, @respawns, log)

      @cmd = "#{@statsite_path} -f #{@conf.path}"
      validate_statsite_confg
    end

    def start
      super

      begin
        $log.info "out_statsite: launching statsite process", cmd: @cmd
        @child.start(@cmd)
      rescue
        shutdown
        raise
      end
    end

    def before_shutdown
      super
      $log.debug "out_statsite#before_shutdown called"
      @child.finished = true
      sleep 0.5  # TODO wait time before killing child process
    end

    def shutdown
      super
      @conf.close
      @child.shutdown
    end

    def format(tag, time, record)
      @formatter.call(record)
    end

    def write(chunk)
      @child.write chunk
    end

    private

    def run
      @loop.run
    rescue => e
      log.error "out_statsite: unexpected error", :error => e, :error_class => e.class
      log.error_backtrace
    end

    def configure_respawns
      if @child_respawn.nil? or @child_respawn == 'none' or @child_respawn == '0'
        0
      elsif @child_respawn == 'inf' or @child_respawn == '-1'
        -1
      elsif @child_respawn =~ /^\d+$/
        @child_respawn.to_i
      else
        raise ConfigError, "child_respawn option argument invalid: none(or 0), inf(or -1) or positive number"
      end
    end

    def validate_metrics
      @metrics.map {|m| Metric.validate(m)}
    end

    def validate_histograms
      @histograms.map {|h| Histogram.validate(h)}
    end

    def validate_statsite_confg
      $log.debug "lanuch statsite process to validate statsite config"
      pid = spawn(@cmd, out: '/dev/null')
      if pid.nil?
        raise ConfigError, 'failed to launch statsite process', cmd: @cmd
      else
        begin
          Timeout::timeout(CONFIG_VALIDATION_WAIT) do
            Process.waitpid(pid)
          end
          raise ConfigError, 'Statsite process cannot be launched correctly. A config is probably invalid.'
        rescue Timeout::Error
          # launched correctly
          Process.kill(:KILL, pid)
          Process.waitpid(pid)
        end
      end
    end

    def config
      <<-CONFIG
[statsite]
port = 0
udp_port = 0
parse_stdin = 1
log_level = INFO
flush_interval = #{@statsite_flush_interval}
timer_eps = #{@timer_eps}
set_eps = #{@set_eps}
stream_cmd = cat

#{@histograms.map(&:to_ini).join("\n\n")}
      CONFIG
    end

    def on_message(time, record)
      Engine.emit(@tag, time, record)
    end
  end
end

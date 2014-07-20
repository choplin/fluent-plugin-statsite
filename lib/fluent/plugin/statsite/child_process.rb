module Fluent
  module StatsitePlugin
    class ChildProcess
      attr_accessor :finished

      def initialize(parser, respawns=0, log = $log)
        @pid = nil
        @thread = nil
        @parser = parser
        @respawns = respawns
        @mutex = Mutex.new
        @finished = nil
        @log = log
      end

      def start(command)
        @command = command
        @mutex.synchronize do
          @io = IO.popen(command, "r+")
          @pid = @io.pid
          @io.sync = true
          @thread = Thread.new(&method(:run))
        end
        @finished = false
      end

      def kill_child(join_wait)
        begin
          Process.kill(:TERM, @pid)
        rescue #Errno::ECHILD, Errno::ESRCH, Errno::EPERM
          # Errno::ESRCH 'No such process', ignore
          # child process killed by signal chained from fluentd process
        end
        if @thread.join(join_wait)
          # @thread successfully shutdown
          return
        end
        begin
          Process.kill(:KILL, @pid)
        rescue #Errno::ECHILD, Errno::ESRCH, Errno::EPERM
          # ignore if successfully killed by :TERM
        end
        @thread.join
      end

      def shutdown
        @finished = true
        @mutex.synchronize do
          kill_child(60) # TODO wait time
        end
      end

      def write(chunk)
        begin
          chunk.write_to(@io)
        rescue Errno::EPIPE => e
          # Broken pipe (child process unexpectedly exited)
          @log.warn "statsite Broken pipe, child process maybe exited.", :command => @command
          if try_respawn
            retry # retry chunk#write_to with child respawned
          else
            raise e # to retry #write with other ChildProcess instance (when num_children > 1)
          end
        end
      end

      def try_respawn
        return false if @respawns == 0
        @mutex.synchronize do
          return false if @respawns == 0

          kill_child(5) # TODO wait time

          @io = IO.popen(@command, "r+")
          @pid = @io.pid
          @io.sync = true
          @thread = Thread.new(&method(:run))

          @respawns -= 1 if @respawns > 0
        end
        @log.warn "statsite child process successfully respawned.", :command => @command, :respawns => @respawns
        true
      end

      def run
        @parser.call(@io)
      rescue
        @log.error "statsite thread unexpectedly failed with an error.", :command=>@command, :error=>$!.to_s
        @log.warn_backtrace $!.backtrace
      ensure
        pid, stat = Process.waitpid2(@pid)
        unless @finished
          @log.error "statsite process unexpectedly exited.", :command=>@command, :ecode=>stat.to_i
          unless @respawns == 0
            @log.warn "statsite child process will respawn for next input data (respawns #{@respawns})."
          end
        end
      end
    end
  end
end

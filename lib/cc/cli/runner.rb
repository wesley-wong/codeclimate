require "active_support"
require "active_support/core_ext"

module CC
  module CLI
    class Runner
      include CC::CLI::Checker

      def self.run(argv)
        new(argv).run
      rescue => ex
        $stderr.puts("error: (#{ex.class}) #{ex.message}")

        CLI.debug("backtrace: #{ex.backtrace.join("\n\t")}")
      end

      def initialize(args)
        @args = args
      end

      def run
        check_version

        if command_class
          command = command_class.new(command_arguments)
          command.execute
        else
          command_not_found
        end
      end

      def command_not_found
        $stderr.puts "unknown command #{command}"
        exit 1
      end

      def command_class
        command_const = Command[command]
        if command_const.abstract?
          nil
        else
          command_const
        end
      rescue NameError
        nil
      end

      def command_arguments
        @args[1..-1]
      end

      def command
        command_name = @args.first
        case command_name
        when nil, "-h", "-?", "--help"
          "help"
        when "-v", "--version"
          "version"
        else
          command_name
        end
      end
    end
  end
end

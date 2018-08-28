require "forwardable"

module Rototiller
  module Task
    # The base ParamCollection class to collect more than one parameter for a task,
    #   or other parameters. delegates to Array for most of Array's methods
    # @api public
    # @example ParamCollection.new
    # @since v0.1.0
    class ParamCollection
      extend Forwardable

      def_delegators :@collection, :clear, :delete_if, :include?, :include,
                     :inspect, :each, :[], :map, :any?, :compact

      # setup the collection as a composed Array
      # @api public
      # @example ParamCollection.new
      # @return the collection
      def initialize
        @collection = []
      end

      # push to the collection
      # @api public
      # @example mycollection.push(param1)
      # @param [Param] args instances of the child classes allowed_class
      # @return the new collection
      def push(*args)
        check_classes(allowed_class, *args)
        @collection.push(*args)
      end

      # format the messages inside this ParamCollection
      # @param indent [String] how far to indent each message
      # @api public
      # @example puts mycollection.messages
      # @return [String] messages from the contents of this ParamCollection
      def messages(indent=0)
        @collection.map { |param| param.message(indent) }.join("")
      end

      # Do any of the contents of this ParamCollection require the task to stop
      # @api public
      # @example exit 1 if mycollection.stop?
      # @return [true, nil] should the values of this ParamCollection stop the task
      def stop?
        @collection.any?(&:stop)
      end

      # convert a ParamCollection to a string
      #   the value sent by author, or overridden by any EnvVar
      # @api public
      # @example puts mycollection
      # @return [String] the Param's value
      def to_str
        @collection.join(" ") unless @collection.empty?
      end
      alias to_s to_str

      private

      # @api private
      # rubocop:disable Style/Next
      def check_classes(allowed_klass, *args)
        args.each do |arg|
          unless arg.is_a?(allowed_klass)
            argument_error = "Argument was of class #{arg.class}, \
            Can only be of class #{allowed_klass}"
            raise(ArgumentError, argument_error)
          end
        end
      end
    end
  end
end

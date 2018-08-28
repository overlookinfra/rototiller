module Rototiller
  module Task
    # some functions for meta-programming hash keys into methods in a block
    module HashHandling
      # equates methods to keys inside a hash or an array of hashes
      # @api public
      # @example HashHandling.send_hash_keys_as_methods_to_self({:name => "myname"})
      # @param [Hash] hash attempt to use keys as setter or getter methods on self
      # @raise [ArgumentError] if a key is not a valid method on self
      # @return [void]
      def send_hash_keys_as_methods_to_self(hash)
        hash = [hash].flatten
        method_list = methods
        hash.each do |h|
          raise ArgumentError unless h.is_a?(Hash)
          call_the_method_or_not(h, method_list)
        end
      end

      private

      # @api private
      def call_the_method_or_not(h, method_list)
        h.each do |k, v|
          if method_list.include?(k) && method_list.include?("#{k}=".to_sym)
            # methods that have attr_accesors
            send("#{k}=", v)
          elsif method_list.include?(k)
            send(k, v)
          else
            raise ArgumentError, "'#{k}' is not a valid key: #{self.class}"
          end
        end
      end
    end
  end
end

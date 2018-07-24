require "rototiller/task/collections/param_collection"
require "rototiller/task/params/env_var"

module Rototiller
  module Task
    # @api public
    # @example EnvCollection.new
    class EnvCollection < ParamCollection
      # Ensure we only have envs in this collection
      # @api public
      # @example assert(Klass == EnvCollection.allowed_class)
      # @return [Type] allowed class for this collection (EnvVar)
      def allowed_class
        EnvVar
      end

      # remove the nils and return the last known value
      # @api public
      # @example mostrecent = thiscollection.last
      # @return [String] last set environment variable or default
      def last
        if any?
          last_known_env_var = map(&:value).compact.last
          # ruby converts nil to "", so guard against single non-set env vars here
          last_known_env_var.to_s if last_known_env_var
        end
      end
    end
  end
end

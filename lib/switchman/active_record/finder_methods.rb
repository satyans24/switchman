module Switchman
  module ActiveRecord
    module FinderMethods
      # find_one uses binds, so we can't depend on QueryMethods
      # catching it
      def find_one(id)
        local_id, shard = Shard.local_id_for(id)

        return super(local_id) if shard_source_value != :implicit

        if shard
          begin
            old_shard_value = shard_value
            self.shard_value = shard
            super(local_id)
          ensure
            self.shard_value = old_shard_value
          end
        else
          super
        end
      end

      def find_or_instantiator_by_attributes(match, attributes, *args)
        primary_shard.activate { super }
      end
    end
  end
end

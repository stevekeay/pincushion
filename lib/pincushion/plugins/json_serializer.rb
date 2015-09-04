require 'multi_json'

module Pincushion
  module Plugins
    module JsonSerializer
      module RootModuleMethods
        def to_json(*args)
          MultiJson.dump(all_identifiers_predicates_hashes, *args)
        end
      end # module RootModuleMethods
    end # module JsonSerializer
  end # module Plugins
end # module Pincushion

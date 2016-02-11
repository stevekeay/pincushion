module Pincushion
  module Plugins
    module JsonSerializer
      OPTS = { symbolize_names: true }

      module PincushionMethods
        def from_json(json, *args)
          args << {} unless args.last.is_a?(Hash)
          args.last.merge!(OPTS)
          from_rows(JSON.parse(json, *args))
        end
      end

      module RootModuleMethods
        def to_json(*args)
          JSON.dump(rows, *args)
        end
      end # module RootModuleMethods
    end # module JsonSerializer
  end # module Plugins
end # module Pincushion

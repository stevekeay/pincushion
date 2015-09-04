module Pincushion
  module Plugins
    def self.camelize(string)
      string.to_s
        .gsub(/\/(.?)/) { "::" + Regexp.last_match(1).upcase }
        .gsub(/(^|_)(.)/) { Regexp.last_match(2).upcase }
    end

    def plugin(name)
      require "pincushion/plugins/#{name}"
      mod = Plugins.const_get(Plugins.camelize(name))
      extend mod::ModuleMethods if defined?(mod::ModuleMethods)
      extend mod::RootModuleMethods if defined?(mod::RootModuleMethods)
      include mod::InstanceMethods if defined?(mod::InstanceMethods)
    rescue LoadError
      raise LoadError, "Plugin not found: #{name}"
    rescue NameError => e
      raise NameError, "#{e} for plugin: #{name}"
    end
  end # module Plugins
end # module Pincushion

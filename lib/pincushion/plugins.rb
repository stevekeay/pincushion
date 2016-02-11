module Pincushion
  def self.plugins
    @plugins || []
  end

  def self.plugin(name)
    require "pincushion/plugins/#{name}"
    mod = Plugins.const_get(Plugins.camelize(name))
    extend mod::PincushionMethods if defined?(mod::PincushionMethods)
    @plugins ||= []
    @plugins << name
  rescue LoadError
    raise LoadError, "Plugin not found: #{name}"
  rescue NameError => e
    raise NameError, "#{e} for plugin: #{name}"
  end

  module Plugins
    def self.camelize(string)
      string.to_s
        .gsub(/\/(.?)/) { "::" + Regexp.last_match(1).upcase }
        .gsub(/(^|_)(.)/) { Regexp.last_match(2).upcase }
    end

    attr_reader :plugins

    def plugin(name)
      require "pincushion/plugins/#{name}"
      mod = Plugins.const_get(Plugins.camelize(name))
      extend mod::ModuleMethods if defined?(mod::ModuleMethods)
      extend mod::RootModuleMethods if defined?(mod::RootModuleMethods)
      include mod::InstanceMethods if defined?(mod::InstanceMethods)
      @plugins ||= []
      @plugins << name
    rescue LoadError
      raise LoadError, "Plugin not found: #{name}"
    rescue NameError => e
      raise NameError, "#{e} for plugin: #{name}"
    end
  end # module Plugins
end # module Pincushion

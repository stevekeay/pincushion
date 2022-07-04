require 'csv'

module Pincushion
  def self.from_csv(csv, opts = {})
    opts = opts.merge(Plugins::CsvSerializer::OPTS)
    from_rows(CSV.parse(csv, **opts).map(&:to_hash))
  end

  module Plugins
    module CsvSerializer
      OPTS = {
        headers: true,
        header_converters: :symbol,
        converters: lambda { |string|
          case string
          when "true" then true
          when "false" then false
          else string
          end
        }
      }.freeze

      module RootModuleMethods
        def to_csv(opts)
          opts[:headers] ||= [:identifier, *predicates]

          CSV.generate(**opts) do |csv|
            rows.each { |row| csv << row }
          end
        end
      end # module RootModuleMethods
    end # module CsvSerializer
  end # module Plugins
end # module Pincushion

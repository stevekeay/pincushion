require 'csv'

module Pincushion
  module Plugins
    module CsvSerializer
      module RootModuleMethods
        def to_csv(*args, **kwargs)
          rows = all_identifiers_predicates_rows
          kwargs[:headers] ||= [:identifier, :predicate, :value]

          CSV.generate(*args, **kwargs) do |csv|
            rows.each { |row| csv << row }
          end
        end
      end # module RootModuleMethods
    end # module CsvSerializer
  end # module Plugins
end # module Pincushion

module SimpleSearchFilter
  module Models
    module SearchableClassMethods

      def make_search_by_filter(filter, options={})
        q = self

        # collect simple conditions
        w_string = '1=1 '
        w_values = []

        filter.fields.each do |name, f|
          val = filter.v(name)
          next if f.ignore_value?(val)

          # apply fields with custom scopes first
          wscope = f.condition_scope
          if f.condition==FilterField::QUERY_CONDITION_CUSTOM && wscope.present?
            q = q.send(wscope, val)
          else
            # where
            w_field = f.make_where(val)
            next if w_field.nil?

            w_cond, w_value = w_field

            w_string << " AND #{w_cond} "
            w_values << w_value
          end
        end

        q = q.where(w_string, *w_values) if w_values

        # order
        q = q.order(filter.order_string)

        # paging
        if options[:paging].nil? || options[:paging]==true
          q = q.page(filter.page)
        end

        q
      end

    end
  end
end


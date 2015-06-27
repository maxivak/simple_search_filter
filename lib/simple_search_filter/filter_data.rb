require 'simple_search_filter/filter_field'

module SimpleSearchFilter
  class FilterData
    attr_accessor :values


    def values
      @values ||= {}
      @values
    end

    def v(name, v_def=nil)
      name = name.to_s
      return values[name] if v_exist?(name)
      v_def
    end

    def v_empty?(name)
      a = values
      if (a.has_key? name) && (!a[name].nil?)
        return true
      end

      false
    end

    def v_exist?(name)
      values.has_key? name
    end

    def set(name, v)
      values[name.to_s] = v
    end

    def set_values(a_values)
      @values = a_values

    end

    def clear
      @values = {}
    end

    ####

    def method_missing(method_sym, *arguments, &block)
      # the first argument is a Symbol, so you need to_s it if you want to pattern match
      name = method_sym.to_s
      if v_exist?(name)
        return v(name)
      else
        super
      end
    end


  end
end


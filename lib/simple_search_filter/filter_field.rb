module SimpleSearchFilter
  class FilterField
    TYPE_STRING = 'string'
    TYPE_INT = 'int'
    TYPE_DATE = 'date'

    FORM_TYPE_EMPTY = 'empty'
    FORM_TYPE_TEXT = 'text'
    FORM_TYPE_HIDDEN = 'hidden'
    FORM_TYPE_SELECT = 'select' # drop-down select
    FORM_TYPE_AUTOCOMPLETE = 'autocomplete' # text with autocomplete


    # condition types
    QUERY_CONDITION_EMPTY = 'empty'
    QUERY_CONDITION_CUSTOM = 'custom'
    QUERY_CONDITION_EQUAL = 'equal'
    QUERY_CONDITION_LIKE = 'like'
    QUERY_CONDITION_LIKE_FULL = 'like_full'
    QUERY_CONDITION_LIKE_LEFT = 'like_left'
    QUERY_CONDITION_LIKE_RIGHT = 'like_right'


    CONDITIONS = {
        :empty => QUERY_CONDITION_EMPTY,
        :custom => QUERY_CONDITION_CUSTOM,
        :equal => QUERY_CONDITION_EQUAL,
        :like => QUERY_CONDITION_LIKE,
        :like_full => QUERY_CONDITION_LIKE_FULL,
        :like_left=>QUERY_CONDITION_LIKE_LEFT,
        :like_right=>QUERY_CONDITION_LIKE_RIGHT
    }


    #
    attr_reader :name
    attr_reader :type
    attr_reader :formtype
    attr_reader :options



    #
    def initialize(name, type, formtype, opt={})
      @name = name.to_sym
      @type = type.to_s
      @formtype = formtype

      @options = opt
      @options||={}

      # some attributes
      self.condition= options[:condition] unless options[:condition].nil?
    end


    def placeholder
      @options[:placeholder] || @options[:label] || ''
    end

    def label
      @options[:label] || ''
    end

    def default_value
      options[:default_value] || nil
    end

    def ignore_value
      v = options[:ignore_value]
      return v unless v.nil?

      # default ignore value from type
      t = type.to_s
      if t==TYPE_INT
        return 0
      elsif t==TYPE_STRING
        return ''
      end

      nil
    end

    def ignore_value?(v)
      v.nil? || v==ignore_value
    end

    def options
      @options ||= {}
      @options
    end


    def condition
      @condition || options[:condition] || QUERY_CONDITION_EQUAL
    end

    def condition=(cond)
      @condition= CONDITIONS[cond.to_sym]
    end

    def condition_scope
      @condition_scope || options[:condition_scope] || nil
    end

    def condition_where
      @condition_where || options[:condition_where] || nil
    end


    def fix_value(v)
      if type==TYPE_INT
        return (v.to_i rescue 0)
      elsif type==TYPE_STRING
        return v.to_s
      end

      v
    end




    def make_where(v)
      cond = condition

      # ignore
      return nil if ignore_value? v

      # make where
      if cond==QUERY_CONDITION_EMPTY
        return nil
      elsif cond==QUERY_CONDITION_EQUAL
        return ["#{name}= ? ", v]
      elsif cond==QUERY_CONDITION_LIKE
        return ["#{name} LIKE ? ", v]
      elsif cond==QUERY_CONDITION_LIKE_LEFT
        return ["#{name} LIKE ? ", v+'%']
      elsif cond==QUERY_CONDITION_LIKE_RIGHT
        return ["#{name} LIKE ? ", '%'+v]
      elsif cond==QUERY_CONDITION_LIKE_FULL
        return ["#{name} LIKE ? ", '%'+v+'%']
      elsif cond==QUERY_CONDITION_CUSTOM
        w = condition_where
        if w.present?
          return [w, v]
        end

      end

      return nil
    end

  end
end

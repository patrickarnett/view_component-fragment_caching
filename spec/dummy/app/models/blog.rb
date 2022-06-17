Blog =
  Struct.new :title do
    alias_method :to_s, :title

    def to_query
      "title=#{title}"
    end
  end

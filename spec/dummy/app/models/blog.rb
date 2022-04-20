class Blog < Struct.new(:title)
  alias to_s title

  def to_query
    "title=#{title}"
  end
end

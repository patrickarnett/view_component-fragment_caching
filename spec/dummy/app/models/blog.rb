class Blog
  attr_accessor :title

  alias to_s title

  def initialize(title:)
    @title = title
  end

  def to_query
    "title=#{title}"
  end
end

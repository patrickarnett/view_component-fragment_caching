class ApplicationController < ActionController::Base
  before_action :load_blog

  private

  def load_blog
    @blog = Blog.new title: params[:title]
  end
end

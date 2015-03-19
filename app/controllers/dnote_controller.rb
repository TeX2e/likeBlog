class DnoteController < ApplicationController
  def index
    @navigate_tags = []
    Post.where("publish = ?", true).select("tag").each do |recode|
      @navigate_tags << recode.tag
    end
    @navigate_tags.uniq!.reject!(&:blank?)
    @navigate_tags.sort_by! { |tag| tag.downcase }

    tag = params[:tag]
    if tag
      @posts = Post.where("tag = ? and publish = ?", tag, true).sort_by { |post| post.date }
    else
      @posts = Post.where("publish = ?", true).sort_by { |post| post.date }
    end
  end

  def show
    @post = Post.find(params[:id])
  end
end

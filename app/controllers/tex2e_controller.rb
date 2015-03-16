class Tex2eController < ApplicationController
  def index
    @navigate_tags = []
    Post.where("publish = ?", true).select("tag").uniq.each do |recode|
      @navigate_tags << recode.tag
    end
    @navigate_tags.reject!(&:blank?).sort_by! { |tag| tag.downcase }


    tag = params[:tag]
    if tag
      @posts = Post.where("tag = ? and publish = ?", tag, true)
    else
      @posts = Post.where("publish = ?", true)
    end
  end

  def show
    @post = Post.find(params[:id])
  end
end

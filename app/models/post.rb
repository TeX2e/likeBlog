require 'kramdown'

class Post < ActiveRecord::Base
  validates :title, presence: true
  validates :text, presence: true

  alias_method :old_save, :save
  def save
    before_create
    old_save
  end

  private

  # DBに記事の内容を保存する前に、md形式をhtml形式に変換させる
  def before_create
  	self.text = ERB::Util.html_escape(self.text).gsub(/^&gt;/, ">")
    self.html_text = Kramdown::Document.new(self.text).to_html
  end
end

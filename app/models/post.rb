require 'kramdown'
require 'sanitize'

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
    # self.text = ERB::Util.html_escape(self.text).gsub(/^&gt;/, ">")
    # gem install sanitize
    self.text.gsub!(/(#include\s*)<([\w.]+)>/, '\1&lt;\2&gt;')
  	self.text = Sanitize.clean(self.text)
    self.text.gsub!(/&gt;/, ">")
    self.text.gsub!(/&lt;/, "<")
    self.text.gsub!(/&amp;/, "&")
    self.html_text = Kramdown::Document.new(self.text).to_html
  end
end

require 'kramdown'
# require 'sanitize'

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
  # htmlタグのエスケープをしようと思ったが、htmlコードを正しく出力できなくなるので取り消し
  # ^ 任意のタイミングで削除してよい
  def before_create
    # self.text = ERB::Util.html_escape(self.text)
    # gem install sanitize
  	# self.text = Sanitize.clean(self.text)
    # self.text.gsub!(/&gt;/, ">")
    # self.text.gsub!(/&lt;/, "<")
    # self.text.gsub!(/&amp;/, "&")
    self.html_text = Kramdown::Document.new(self.text).to_html
  end
end

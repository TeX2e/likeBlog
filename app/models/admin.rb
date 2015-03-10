class Admin < ActiveRecord::Base
  def initialize
    super
    @password
  end

  attr_accessor :password
  validates_uniqueness_of :name
  validates_presence_of :name, :password
  
  # 認証を行う。
  def authoricate(name, password)
    return false if name != self.name
    return false if crypt_password(password, self.salt) != self.crypted_password
    true
  end

  # saveを行う直前にbefore_createを行う
  alias_method :old_save, :save
  def save
    before_create
    old_save
  end

  private
  
  # パスワードを暗号化する
  def crypt_password(password, salt)
    Digest::MD5.hexdigest(password + salt)
  end
  
  # パスワード暗号化のためのsalt生成
  def new_salt
    s = rand.to_s.tr('+', '.')
    s[0, if s.size > 32 then 32 else s.size end]
  end

  # DB格納前のフック
  # saltと暗号化されたパスワードを生成
  def before_create
    self.salt = new_salt
    self.crypted_password = crypt_password(@password, self.salt)
  end
end

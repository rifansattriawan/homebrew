require 'formula'

class Rvm <Formula
  url 'http://rvm.beginrescueend.com/releases/rvm-0.1.38.tar.gz'
  homepage 'http://rvm.beginrescueend.com/'
  md5 '9ee11f8d006321ae33bc06571334e611'

  def install
    ln_s prefix, "#{ENV['HOME']}/.rvm"
    system "./install", "--auto", "--prefix #{prefix}/"
  end
end

require 'formula'

class Bison <Formula
  url 'http://ftp.gnu.org/gnu/bison/bison-2.4.2.tar.bz2'
  homepage 'http://www.gnu.org/software/bison/'
  md5 '63584004613aaef2d3dca19088eb1654'

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"
    system "make install"
  end
end

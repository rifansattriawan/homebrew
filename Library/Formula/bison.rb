require 'formula'

class Bison <Formula
  url 'http://ftp.gnu.org/gnu/bison/bison-2.4.1.tar.bz2'
  homepage 'http://www.gnu.org/software/bison/'
  md5 '84e80a2a192c1a4c02d43fbf2bcc4ca4'

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"
    system "make install"
  end
end

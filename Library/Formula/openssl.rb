require 'formula'

class Openssl <Formula
  url 'http://www.openssl.org/source/openssl-0.9.8o.tar.gz'
  version '0.9.8o'
  homepage 'http://www.openssl.org'
  md5 '63ddc5116488985e820075e65fbe6aa4'

  def keg_only?
    :provided_by_osx
  end

  def install
    ENV.universal_binary
    ENV.j1
    system "./config", "--prefix=#{prefix}", "--openssldir=#{etc}",
                       "zlib-dynamic", "shared"
    system "make"
    system "make test"
    system "make install"
  end
end

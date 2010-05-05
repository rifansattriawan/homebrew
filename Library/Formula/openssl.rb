require 'formula'

class Openssl <Formula
  url 'http://www.openssl.org/source/openssl-0.9.8n.tar.gz'
  version '0.9.8n'
  homepage 'http://www.openssl.org'
  md5 '076d8efc3ed93646bd01f04e23c07066'
  
  def keg_only?
    :provided_by_osx
  end

  def install
    ENV.j1
    system "./config", "--prefix=#{prefix}", "--openssldir=#{etc}",
                       "zlib-dynamic", "shared"
    system "make"
    system "make test"
    system "make install"
  end
end

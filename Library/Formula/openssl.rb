require 'formula'

class Openssl <Formula
  url 'http://www.openssl.org/source/openssl-0.9.8k.tar.gz'
  version '0.9.8k'
  homepage 'http://www.openssl.org'
  md5 'e555c6d58d276aec7fdc53363e338ab3'
  
  def keg_only?
    :provided_by_osx
  end

  def install
    ENV.j1
    
    system "./config",  "--prefix=#{prefix}", "--openssldir=#{etc}",
                          "zlib-dynamic", "shared"
    system "make"
    system "make test"
    system "make install"
  end
end

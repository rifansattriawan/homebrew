require 'formula'

class Curl <Formula
  url 'http://curl.haxx.se/download/curl-7.19.7.tar.bz2'
  homepage 'http://curl.haxx.se/'
  md5 '79a8fbb2eed5464b97bdf94bee109380'
  aka 'libcurl'

  depends_on 'libssh2' => :optional

  def install
    # if libssh2, then include it in ./configure
    system "./configure", "--prefix=#{prefix}",
                          "--disable-debug",
                          "--disable-dependency-tracking",
                          "--with-libssh2"
    system "make install"
  end
end

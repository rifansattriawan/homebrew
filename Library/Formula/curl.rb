require 'formula'

class Curl <Formula
  url 'http://curl.haxx.se/download/curl-7.21.0.tar.bz2'
  homepage 'http://curl.haxx.se/'
  md5 'e1a2a773e93a39f3c04cab92c55bf197'
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

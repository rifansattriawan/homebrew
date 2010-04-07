require 'formula'

class Gource <Formula
  homepage 'http://code.google.com/p/gource/'
  url 'git://github.com/acaudwell/Gource.git', :tag => "24feaee4"
  version "0.27"
  head 'git://github.com/acaudwell/Gource.git'

  depends_on 'pkg-config'
  depends_on 'sdl'
  depends_on 'sdl_image'
  depends_on 'ftgl'
  depends_on 'jpeg'
  depends_on 'libpng'
  depends_on 'pcre'
  depends_on 'glew'

  def install
    # Put freetype-config in path
    ENV.x11
    ENV.prepend 'PATH', "/usr/X11/bin", ":"

    system "autoreconf -f -i" unless File.exist? "configure"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-sdltest",
                          "--disable-freetypetest"
    system "make install"
  end
end

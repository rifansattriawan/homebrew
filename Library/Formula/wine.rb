require 'formula'
require 'hardware'

class Wine <Formula
  if MACOS_VERSION >= 10.6 and Hardware.is_64_bit?
    url 'http://prdownloads.sourceforge.net/wine/wine-1.2-rc1.tar.bz2'
    sha1 '31ea3a75ea560cd486fb58825242ac0a6fc664ca'
  else
    url 'http://downloads.sourceforge.net/project/wine/Source/wine-1.1.42.tar.bz2'
    sha1 'ea932f19528a22eacc49f16100dbf2251cb4ad5c'
  end
  homepage 'http://www.winehq.org/'
  head 'git://source.winehq.org/git/wine.git'

  depends_on 'jpeg'
  depends_on 'mpg123' => :optional

  def wine_wrapper; <<-EOS
#!/bin/sh
DYLD_FALLBACK_LIBRARY_PATH="/usr/X11/lib" \
"#{bin}/wine.bin" "$@"
EOS
  end

  def install
    # Wine does not compile with LLVM yet
    ENV.gcc_4_2
    ENV.x11

    ENV["LIBS"] = "-lGL -lGLU"
    ENV.append "LDFLAGS", ["-framework CoreServices", "-lz", "-lGL -lGLU"].join(' ')

    if MACOS_VERSION >= 10.6 and Hardware.is_64_bit?
      # ENV.m64
    else
      build32 = "-arch i386 -m32"
      ENV.append "CFLAGS", build32
      ENV.append "CXXFLAGS", "-D_DARWIN_NO_64_BIT_INODE"
      ENV.append "LDFLAGS", build32
    end

    ENV.append "DYLD_FALLBACK_LIBRARY_PATH", "/usr/X11/lib"

    args = ["--prefix=#{prefix}", "--disable-win16"]
    args << "--without-freetype" << "--enable-win64" if MACOS_VERSION >= 10.6 and Hardware.is_64_bit?
    system "./configure", *args
    system "make install"

    # Use a wrapper script, so rename wine to wine.bin
    # and name our startup script wine
    mv (bin+'wine'), (bin+'wine.bin')
    (bin+'wine').write(wine_wrapper)
  end

  def caveats
    <<-EOS.undent
      You may also want to get winetricks:
        brew install winetricks
    EOS
  end
end

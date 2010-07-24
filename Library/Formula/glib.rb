require 'formula'

class Libiconv <Formula
  url 'http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.13.1.tar.gz'
  md5 '7ab33ebd26687c744a37264a330bbe9a'
  homepage 'http://www.gnu.org/software/libiconv/'
end

def build_tests?; ARGV.include? '--test'; end

class Glib <Formula
  url 'http://ftp.gnome.org/pub/gnome/sources/glib/2.24/glib-2.24.1.tar.bz2'
  sha256 '014c3da960bf17117371075c16495f05f36501db990851ceea658f15d2ea6d04'
  homepage 'http://www.gtk.org'

  depends_on 'pkg-config'
  depends_on 'gettext'

  def patches
    {
      :p0 => [
        "http://trac.macports.org/export/69965/trunk/dports/devel/glib2/files/patch-configure.in.diff",
      ]
    }
  end

  def options
    [['--test', 'Build a debug build and run tests. NOTE: Tests may hang.']]
  end

  def install
    # Snow Leopard libiconv doesn't have a 64bit version of the libiconv_open
    # function, which breaks things for us, so we build our own
    # http://www.mail-archive.com/gtk-list@gnome.org/msg28747.html
    iconvd = Pathname.getwd+'iconv'
    iconvd.mkpath

    Libiconv.new.brew do
      system "./configure", "--prefix=#{iconvd}", "--disable-debug", "--disable-dependency-tracking",
                            "--enable-static", "--disable-shared"
      system "make install"
    end

    # indeed, amazingly, -w causes gcc to emit spurious errors for this package!
    ENV.enable_warnings

    # Statically link to libiconv so glib doesn't use the bugged version in 10.6
    ENV['LDFLAGS'] += " #{iconvd}/lib/libiconv.a"

    args = ["--disable-dependency-tracking", "--disable-rebuilds",
            "--prefix=#{prefix}",
            "--with-libiconv=gnu"]

    args << "--disable-debug" unless build_tests?

    system "./configure", *args

    # Fix for 64-bit support, from MacPorts
    curl "http://trac.macports.org/export/69965/trunk/dports/devel/glib2/files/config.h.ed", "-O"
    system "ed - config.h < config.h.ed"

    system "make"
    system "make test" if build_tests?
    system "make install"

    # This sucks; gettext is Keg only to prevent conflicts with the wider
    # system, but pkg-config or glib is not smart enough to have determined
    # that libintl.dylib isn't in the DYLIB_PATH so we have to add it
    # manually.
    gettext = Formula.factory('gettext')
    inreplace lib+'pkgconfig/glib-2.0.pc' do |s|
      s.gsub! 'Libs: -L${libdir} -lglib-2.0 -lintl',
              "Libs: -L${libdir} -lglib-2.0 -L#{gettext.lib} -lintl"

      s.gsub! 'Cflags: -I${includedir}/glib-2.0 -I${libdir}/glib-2.0/include',
              "Cflags: -I${includedir}/glib-2.0 -I${libdir}/glib-2.0/include -I#{gettext.include}"
    end

    (prefix+'share/gtk-doc').rmtree
  end
end

require 'formula'

# Derived from the MacPorts build:
# http://trac.macports.org/browser/trunk/dports/net/nss/Portfile
class Nss <Formula
  url 'ftp://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/NSS_3_12_6_RTM/src/nss-3.12.6.tar.gz'
  homepage 'http://www.mozilla.org/projects/security/pki/nss/'
  md5 'da42596665f226de5eb3ecfc1ec57cd1'

  depends_on 'nspr'
  depends_on 'gdbm'
  depends_on 'sqlite'

  def install
    inreplace "mozilla/security/coreconf/UNIX.mk" do |s|
      s.gsub! "DEFINES    += -DDEBUG -UNDEBUG -DDEBUG_$(USERNAME)",
              "DEFINES    += -DDEBUG -UNDEBUG -DDEBUG_$(USERNAME) -I#{HOMEBREW_PREFIX}/include/nspr"
    end

#  -I#{HOMEBREW_PREFIX}/include -L#{HOMEBREW_PREFIX}/lib

    make_flags = ""
    make_flags += " USE_64=1" if Hardware.is_64_bit? and MACOS_VERSION >= 10.6

    ENV.j1
    system "make -C mozilla/security/coreconf/nsinstall #{make_flags}"
    system "make -C mozilla/security/dbm USE_64=1 #{make_flags}"
    system "make -C mozilla/security/nss USE_64=1 #{make_flags}"
    raise "halt"
  end
end

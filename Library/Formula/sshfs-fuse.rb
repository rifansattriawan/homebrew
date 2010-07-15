require 'formula'

class SshfsFuse < Formula
  url 'http://downloads.sourceforge.net/project/fuse/sshfs-fuse/2.2/sshfs-fuse-2.2.tar.gz'
  homepage 'http://fuse.sourceforge.net/sshfs.html'
  md5 '26e9206eb5169e87e6f95f54bc005a4f'

  depends_on 'pkg-config'
  depends_on 'glib'

  def caveats
    <<-EOS.undent
    This depends on the MacFUSE installation from http://code.google.com/p/macfuse/
    MacFUSE must be installed prior to installing this formula.
    EOS
  end

  def patches
    # OS X sshfs patch from MacFUSE
    { :p1 => "http://macfuse.googlecode.com/svn/tags/macfuse-2.0/filesystems/sshfs/sshfs-fuse-2.2-macosx.patch" }
  end

  def install
    if MACOS_VERSION >= 10.6 and Hardware.is_64_bit?
      arch = "x86_64"
    else
      arch = "i386"
    end

    ENV.append "CFLAGS", "-O0 -g -arch #{arch} -isysroot /Developer/SDKs/MacOSX#{MACOS_VERSION}.sdk -I/usr/local/include -D__FreeBSD__=10 -DDARWIN_SEMAPHORE_COMPAT -DSSH_NODELAY_WORKAROUND"
    ENV.append "LDFLAGS", "-Wl,-syslibroot,/Developer/SDKs/MacOSX#{MACOS_VERSION}.sdk -arch #{arch} -L/usr/local/lib"
    system "./configure", "--disable-debug", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make install"
  end
end

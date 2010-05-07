require 'formula'

# See:
#  http://www.virtualbox.org/wiki/Mac%20OS%20X%20build%20instructions

class Virtualbox <Formula
  url 'http://213.239.192.22/download/3.2.0_BETA2/VirtualBox-3.2.0_BETA2-OSE.tar.bz2'
  version '3.2.0_BETA2-OSE'
  homepage 'http://www.virtualbox.org/'
  md5 'b4ddc60205daa95536e040d8347d5052'
  
  depends_on "libidl"
  depends_on "openssl" # System-provided version is too old.
  depends_on "qt"

  def install
    openssl_prefix = Formula.factory("openssl").prefix
    qt_prefix = Formula.factory("qt").prefix
    
    system "./configure", "--disable-hardening",
                          "--with-openssl-dir=#{openssl_prefix}",
                          "--with-qt-dir=#{qt_prefix}"
    system ". ./env.sh ; kmk"

    # Move all the build outputs into libexec
    libexec.install Dir["out/darwin.x86/release/dist/*"]

    app_contents = libexec+"VirtualBox.app/Contents/MacOS/"

    # remove test scripts and files
    (app_contents+"testcase").rmtree
    FileUtils.rm Dir.glob(app_contents+"tst*")
    
    
    # Slot the command-line tools into bin
    bin.mkpath

    cd prefix do
      %w[ VBoxHeadless VBoxManage VBoxVRDP vboxwebsrv ].each do |c|
        ln_s "libexec/VirtualBox.app/Contents/MacOS/#{c}", "bin" if File.exist? app_contents+c
      end
    end
  end
  
  def caveats
    <<-EOS
    Compiled outputs installed to #{libexec}.
    You'll have to figure out what to do about the kernel extensions.
    
    Pre-compiled binaries are available from:
      http://www.virtualbox.org/wiki/Downloads
    EOS
  end
end

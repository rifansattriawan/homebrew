require 'formula'

# See:
#  http://www.virtualbox.org/wiki/Mac%20OS%20X%20build%20instructions

class Virtualbox <Formula
  url 'http://download.virtualbox.org/virtualbox/3.1.4/VirtualBox-3.1.4-OSE.tar.bz2'
  version '3.1.4'
  homepage 'http://www.virtualbox.org/'
  md5 'd32066cb9ebfa4930a2c5ad6227de26f'
  
  depends_on "doxygen" => :optional
  depends_on "libidl"
  depends_on "openssl"
  depends_on "qt"


  def install
    openssl_prefix = Formula.factory("openssl").prefix
    qt_prefix = Formula.factory("qt").prefix
    
    system "./configure", "--disable-hardening",
                          "--with-openssl-dir=#{openssl_prefix}",
                          "--with-qt-dir=#{qt_prefix}"
    system ". ./env.sh ; kmk"

    # We don't install "for real" yet, because we have to figure out
    # what to do about the kernel extensions.
    libexec.install Dir["out/darwin.x86/release/dist/*"]


    app_contents = libexec+"VirtualBox.app/Contents/MacOS/"

    # remove test scripts and files
    (app_contents+"testcase").rmtree
    FileUtils.rm Dir.glob(app_contents+"tst*")
    
    
    # Slot the command-line tools into bin
    bin.mkpath

    # TODO: build vboxwebsrv
    cd prefix do
      %w[ VBoxHeadless VBoxManage VBoxVRDP vboxwebsrv ].each do |command|
        source_file = app_contents+command
        if File.exist? source_file
          ln_s "libexec/VirtualBox.app/Contents/MacOS/#{command}", "bin/#{command}"
        end
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

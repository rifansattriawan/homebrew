require 'formula'

class Ruby <Formula
  url 'http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.1-p429.tar.bz2'
  homepage 'http://www.ruby-lang.org/en/'
  md5 '09df32ae51b6337f7a2e3b1909b26213'

  head 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_9_2/', :using => :svn

  depends_on 'readline'

  def options
    [
      ["--with-suffix", "Add a 19 suffix to commands"],
      ["--with-doc", "Install with the Ruby documentation"]
    ]
  end

  # Stripping breaks dynamic linking
  skip_clean :all

  def install
    fails_with_llvm

    args = ["--prefix=#{prefix}", "--enable-shared", "--enable-pthread"]
    args << "--program-suffix=19" if ARGV.include? "--with-suffix"

    system "autoconf" unless File.exists? 'configure'

    system "./configure", *args
    system "make"
    system "make install"
    system "make install-doc" if ARGV.include? "--with-doc"

    # Make sure that install paths for this Ruby are "real folders" in the
    # HOMEBREW_PREFIX, so they survive between patchlevel updates.
    # which_version = ARGV.build_head? ? "1.9.2" : "1.9.1"
    # which_arch = Dir["#{lib}/ruby/site_ruby/#{which_version}/*"].first
    # (HOMEBREW_PREFIX+"lib/ruby/site_ruby/#{which_version}/#{which_arch}").mkpath
    # (HOMEBREW_PREFIX+"lib/ruby/vendor_ruby/#{which_version}/#{which_arch}").mkpath
  end

  def caveats; <<-EOS.undent
    Consider using RVM or Cider to manage Ruby environments:
      * RVM: http://rvm.beginrescueend.com/
      * Cider: http://www.atmos.org/cider/intro.html

    If you install gems with the RubyGems installed with this formula they will
    be installed to this formula's prefix. This needs to be fixed, as for example,
    upgrading Ruby will lose all your gems.
    EOS
  end
end

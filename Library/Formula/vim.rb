require 'formula'

class Vim <Formula
  # Get patch-level 446 from Subversion;
  # downloading and applying separate patches is completely ridiculous.
  head 'http://vim.svn.sourceforge.net/svnroot/vim/branches/vim7.2/', :revision => '1889'
  version '7.2.446'
  homepage 'http://www.vim.org/'

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--enable-gui=no",
                          "--without-x",
                          "--disable-nls",
                          "--enable-multibyte",
                          "--with-tlib=ncurses",
                          "--enable-pythoninterp",
                          "--enable-rubyinterp",
                          "--with-features=huge"
    system "make"
    system "make install"
  end
end

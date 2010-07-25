require 'formula'

class Node <Formula
  url 'http://nodejs.org/dist/node-v0.1.102.tar.gz'
  head 'git://github.com/ry/node.git'
  homepage 'http://nodejs.org/'
  md5 '93279f1e4595558dacb45a78259b7739'

  # Stripping breaks dynamic loading
  skip_clean :all

  def install
    fails_with_llvm

    # Note, this was more useful when Node had a dependency
    # on "gnutls"; since Node is mostly self-contained now,
    # these replacments might no longer be needed.
    inreplace 'wscript' do |s|
      s.gsub! '/usr/local', HOMEBREW_PREFIX
      s.gsub! '/opt/local/lib', '/usr/lib'
    end

    system "./configure", "--prefix=#{prefix}", "--destdir=#{HOMEBREW_PREFIX}"
    system "make install"
  end
end

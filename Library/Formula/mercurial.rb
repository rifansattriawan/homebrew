require 'formula'

class Mercurial <Formula
  url 'http://mercurial.selenic.com/release/mercurial-1.5.1.tar.gz'
  homepage 'http://mercurial.selenic.com/downloads/'
  md5 '22eac5602d777f9601e23700e641503f'

  def install
    # Make Mercurial into the Cellar.
    system "make", "PREFIX=#{prefix}", "install"
    # Now we have lib/python2.[56]/site-packages/ with Mercurial
    # libs in them. We want to move these out of site-packages into
    # a self-contained folder. Let's choose libexec.
    libexec.mkpath
    libexec.install Dir["#{lib}/python*/site-packages/*"]

    # Move the hg startup script into libexec too, and link it from bin
    libexec.install bin+'hg'
    ln_s libexec+'hg', bin+'hg'

    # Remove the hard-coded python invocation from hg
    inreplace bin+'hg', %r[#!/.*/python], '#!/usr/bin/env python'

    # We now have a self-contained Mercurial install.
  end
end

require 'formula'

class Rvm <Formula
  url 'http://rvm.beginrescueend.com/releases/rvm-0.1.40.tar.gz'
  homepage 'http://rvm.beginrescueend.com/'
  md5 '2cff08697543c28267a11e89a1082a9a'

  # Don't kill empty folders
  def skip_clean? path
    true
  end

  def install
    # TODO
    # If ~/.rvm exists, and is a symlink to the cellar (or broken symlink)
    # then remove it and continue.
    # If it is a real folder with existing rvm stuff in it, then exit instead
    # of munging a user's existing install.

    (prefix+'rvm').mkpath
    ln_s (prefix+'rvm'), "#{ENV['HOME']}/.rvm"
    system "./install", "--prefix", "#{prefix}/"

    bin.mkpath
    Dir.chdir prefix do
      Dir['rvm/bin/*'].each do |p|
        ln_s prefix+p, bin
      end
    end
  end

  def caveats
    <<-EOS.undent
      This formula created a symlink ~/.rvm that points to:
        #{prefix}

      To enable rvm you'll want to add this to your .bashrc or other shell profile:
        [[ -s "#{prefix}/scripts/rvm" ]] && source "#{prefix}/scripts/rvm"
    EOS
  end
end

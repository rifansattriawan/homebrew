require 'formula'

class Cabal <Formula
  url 'http://www.haskell.org/cabal/release/cabal-install-0.8.2/cabal-install-0.8.2.tar.gz'
  homepage 'http://www.haskell.org/cabal/'
  md5 '4abd0933dff361ff69ee9288a211e4e1'

  depends_on 'ghc'

  aka 'cabal-install'

  def cabal_wrapper
    <<-WRAPPER.undent
      #!/bin/sh
      export CABAL_CONFIG=#{etc}/cabal/config
      #{bin}/cabal.real \$*
    WRAPPER
  end

  def cabal_config
    <<-CONFIG.undent
      remote-repo: hackage.haskell.org:http://hackage.haskell.org/packages/archive
      remote-repo-cache: #{var}/cabal/packages
      user-install: False
      documentation: True
      build-summary: #{var}/cabal/logs/build.log
      install-dirs global
        prefix: #{prefix}
    CONFIG
  end

  def install
    # unregister broken packages
    `ghc-pkg --simple-output check`.split.each do |p|
      safe_system 'ghc-pkg', '--force', 'unregister', p
    end
    
    File.chmod 0755, 'bootstrap.sh'
    ENV['PREFIX'] = prefix
    system "./bootstrap.sh"
    
    rm (etc+'cabal/config') # Remove existing config, if it exists
    (etc+'cabal/config').write cabal_config

    # Use a wrapper script to call cabal
    mv "#{bin}/cabal", "#{bin}/cabal.real"
    (bin+'cabal').write cabal_wrapper
  end

  def caveats
    <<-EOS.undent
    To update Cabal's package list:
      cabal update
    EOS
  end
end

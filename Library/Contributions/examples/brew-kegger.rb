# Usage: brew kegger <list of keg-only formulae>
# Links the given keg into a "Current" folder.
# This is a step towards better support of upgrading
# versioned keg-only formulae.

require 'formula'
require 'fileutils'

ARGV.formulae.each do |f|
  next unless f.keg_only?
  cellar_root = HOMEBREW_CELLAR+f.name

  if f.prefix.exist?
    puts f.name
    puts "Linking #{f.prefix} to #{cellar_root}/Current"
    (cellar_root+"Current").unlink if (cellar_root+"Current").exist?
    FileUtils.ln_s f.prefix, cellar_root+"Current"
    puts
  end
end

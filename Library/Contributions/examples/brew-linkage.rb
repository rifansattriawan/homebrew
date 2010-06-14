require 'formula'

SYSLIBS = ['/usr/lib/', '/usr/X11/lib/']
BREWLIBS = ["#{HOMEBREW_CELLAR}/", "#{HOMEBREW_CELLAR.realpath}/"].uniq

class String
  def starts_with?(prefix)
    prefix = prefix.to_s
    self[0, prefix.length] == prefix
  end
end

class Linkage
  attr_reader :library
  attr_reader :name

  def initialize(line)
    @library = line
    @name = File.basename(library)
  end

  def is_system_library?
    SYSLIBS.each.any? {|p| @library.starts_with? p}
  end

  def is_homebrew_library?
    BREWLIBS.each.any? {|p| @library.starts_with? p}
  end

  def is_suspicious?
    return ! (is_homebrew_library? or is_system_library?)
  end

  def to_s
    s = @library
    s = "$ "+s if is_system_library?
    s = "# "+s if is_homebrew_library?
    s = "! "+s if is_suspicious?
    return s
  end
end


class Linkages
  attr_reader :linkages

  def initialize(lines)
    @linkages = Array.new
    lines.each do |l|
      l =~ /^\s*(.*)\s*\(/
      @linkages << Linkage.new($1)
    end
  end
end


class Tool
  attr_reader :linkages, :name

  def initialize(filename)
    lines = `otool -L "#{filename}"`.strip.split("\n")

    # First line is "tool:"
    lines.shift =~ /(.*):$/
    @tool = $1

    @linkages = Array.new
    lines.each do |l|
      l =~ /^\s*(.*)\s*\(/
      @linkages << Linkage.new($1)
    end
  end
end


def is_executable? filename
  file_output = `file "#{filename}"`

  lines = file_output.strip.split("\n")
  lines.each do |line|
    case line
    when /Mach-O (executable|dynamically linked shared library) i386/
      return true
    when /Mach-O 64-bit (executable|dynamically linked shared library) x86_64/
      return true
    end
  end

  return false
end


def show_linkages filename
  tool = Tool.new(filename)
  puts "tool: #{tool.name}"
  puts tool.linkages
  puts
end


def main
  target = ARGV.named.first
  puts "Reading: #{target}"
  (f = Formula.factory(target)) rescue exit 3
  puts "found"
  exit 4 unless f.installed?
  puts "installed"
  puts

  Dir["#{f.bin}/*"].each do |p|
    next if File.symlink? p
    next unless is_executable? p
    show_linkages p
  end

  Dir["#{f.lib}/*.dylib"].each do |p|
    next if File.symlink? p
    show_linkages p
  end
end


main()

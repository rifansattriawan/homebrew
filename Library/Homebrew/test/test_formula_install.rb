require 'testing_env'

require 'extend/ARGV' # needs to be after test/unit to avoid conflict with OptionsParser
ARGV.extend(HomebrewArgvExtension)

require 'formula'
require 'test/testball'
require 'keg'
require 'utils'


class TestScriptFileFormula <ScriptFileFormula
  url "file:///#{Pathname.new(ABS__FILE__).realpath}"
  version "1"
  
  def initialize
    @name='test-script-formula'
    @homepage = 'http://example.com/'
    super
  end
end


class ConfigureTests < Test::Unit::TestCase
  def test_detect_failed_configure
    f=ConfigureFails.new
    begin
      f.brew { f.install }
    rescue ExecutionError => e
      assert e.was_running_configure?
    end
  end
end


class UnknownCommandTests < Test::Unit::TestCase
  def temporary_brew f
    # Brew and install the given formula
    # nostdout do
      f.brew { yield }
    # end

    # Remove the brewed formula and double check
    # that it did get removed. This lets multiple
    # tests use the same formula name without
    # stepping on each other.
    if File.exist? f.prefix
      keg=Keg.new f.prefix
      keg.uninstall
      assert !keg.exist?
      assert !f.installed?
    end
  end

  def test_detect_unknown_command
    testball_class = Class.new(TestBall) do
      @md5='71aa838a9e4050d1876a295a9e62cbe6'
    end

    read, write = IO.pipe
    # I'm guessing this is not a good way to do this, but I'm no UNIX guru
    ENV['HOMEBREW_ERROR_PIPE'] = write.to_i.to_s

    f=testball_class.new
    
    temporary_brew f do
      begin
        safe_system "./notacommand"
      rescue ExecutionError => e
        puts e.class
        puts e
        puts e.ps
        puts e.exit_status
        flunk("Failure message.")
      end
    end
  end
end

class InstallTests < Test::Unit::TestCase
  def temporary_install f
    # Brew and install the given formula
    nostdout do
      f.brew { f.install }
    end

    # Allow the test to do some processing
    yield
    
    # Remove the brewed formula and double check
    # that it did get removed. This lets multiple
    # tests use the same formula name without
    # stepping on each other.
    keg=Keg.new f.prefix
    keg.uninstall
    assert !keg.exist?
    assert !f.installed?
  end

  def test_a_basic_install
    f=TestBall.new
    
    assert_equal Formula.path(f.name), f.path
    assert !f.installed?
    
    temporary_install f do
      assert_match Regexp.new("^#{HOMEBREW_CELLAR}/"), f.prefix.to_s
    
      # Test that things made it into the Keg
      assert f.bin.directory?
      assert_equal 3, f.bin.children.length
      libexec=f.prefix+'libexec'
      assert libexec.directory?
      assert_equal 1, libexec.children.length
      assert !(f.prefix+'main.c').exist?
      assert f.installed?
    
      # Test that things make it into the Cellar
      keg=Keg.new f.prefix
      keg.link
      assert_equal 2, HOMEBREW_PREFIX.children.length
      assert (HOMEBREW_PREFIX+'bin').directory?
      assert_equal 3, (HOMEBREW_PREFIX+'bin').children.length
    end
  end
  
  def test_script_install
    f=TestScriptFileFormula.new
    
    temporary_install f do
      nostdout do
        f.brew { f.install }
      end
    
      assert_equal 1, f.bin.children.length
    end
  end

end

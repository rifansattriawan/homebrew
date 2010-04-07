require 'formula'

class Solr <Formula
  url 'http://apache.deathculture.net/lucene/solr/1.4.0/apache-solr-1.4.0.tgz'
  homepage 'http://lucene.apache.org/solr/'
  md5 '1cc3783316aa1f95ba5e250a4c1d0451'

  def script; <<-end_script
#!/bin/sh
if [ -z "$1" ]; then
  echo "Usage: $ solr path/to/config/dir"
else 
  cd #{prefix}/example && java -Dsolr.solr.home=$1 -jar start.jar
fi
end_script
  end

  def install
    prefix.install Dir['*']
    (bin+'solr').write script
  end

  def caveats
    <<-END_CAVEATS
To start solr: 
    $ solr path/to/solr/config/dir

See the solr homepage for more setup information:
    $ brew home solr

    END_CAVEATS
  end
end

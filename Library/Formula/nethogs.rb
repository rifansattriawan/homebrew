require 'formula'

class Nethogs <Formula
  url 'http://downloads.sourceforge.net/project/nethogs/nethogs/0.7/nethogs-0.7.0.tar.gz'
  homepage 'http://nethogs.sourceforge.net/'
  md5 'e5f04071571e469e14c89f637cfa34a2'

  def patches
    DATA # No malloc.h on OS X
  end

  def install
    # This could be a patch too, I suppose.
    inreplace "nethogs.cpp" do |s|
      s.gsub! "tcp->source", "tcp->th_sport"
      s.gsub! "tcp->dest", "tcp->th_dport"
      s.gsub! "udp->source", "udp->uh_sport"
      s.gsub! "udp->dest", "udp->uh_dport"
    end

    system "make"
    bin.install "nethogs"
    (man+"man8").install "nethogs.8"
  end

  def caveats; <<-EOS.undent
    You need to be root to run nethogs:
      sudo nethogs
    EOS
  end
end

__END__
diff --git a/nethogs.h b/nethogs.h
index c9969bb..f1672af 100644
--- a/nethogs.h
+++ b/nethogs.h
@@ -7,7 +7,9 @@
 #include <arpa/inet.h>
 #include <assert.h>
 #include <string.h>
+#ifndef __APPLE__
 #include <malloc.h>
+#endif
 #include <iostream>
 
 #define _BSD_SOURCE 1
diff --git a/connection.cpp b/connection.cpp
index 8d608c3..e717660 100644
--- a/connection.cpp
+++ b/connection.cpp
@@ -1,6 +1,8 @@
 #include <iostream>
 #include <assert.h>
+#ifndef __APPLE__
 #include <malloc.h>
+#endif
 #include "nethogs.h"
 #include "connection.h"
 
diff --git a/packet.cpp b/packet.cpp
index d28a3c4..7ede3ef 100644
--- a/packet.cpp
+++ b/packet.cpp
@@ -3,7 +3,9 @@
 #include "packet.h"
 #include <netinet/tcp.h>
 #include <netinet/in.h>
+#ifndef __APPLE__
 #include <malloc.h>
+#endif
 #include <assert.h>
 #include <net/if.h>
 #include <net/ethernet.h>
diff --git a/process.cpp b/process.cpp
index cedf7ea..fe6b026 100644
--- a/process.cpp
+++ b/process.cpp
@@ -2,7 +2,9 @@
 #include <strings.h>
 #include <string>
 #include <ncurses.h>
+#ifndef __APPLE__
 #include <asm/types.h>
+#endif
 #include <sys/types.h>
 #include <sys/stat.h>
 #include <unistd.h>
diff --git a/decpcap.c b/decpcap.c
index 4194875..ce99bef 100644
--- a/decpcap.c
+++ b/decpcap.c
@@ -1,3 +1,6 @@
+#ifdef __APPLE__
+#include <sys/socket.h>
+#endif
 #include <net/ethernet.h>
 #include <net/if.h>
 #include <netinet/ip.h>
diff --git a/conninode.cpp b/conninode.cpp
index a3afa88..1b0b8d6 100644
--- a/conninode.cpp
+++ b/conninode.cpp
@@ -57,6 +57,9 @@ void addtoconninode (char * buffer)
 	if (strlen(local_addr) > 8)
 	{
 		/* this is an IPv6-style row */
+#ifdef __APPLE__
+#define s6_addr32 __u6_addr.__u6_addr32
+#endif
 
 		/* Demangle what the kernel gives us */
 		sscanf(local_addr, "%08X%08X%08X%08X", 

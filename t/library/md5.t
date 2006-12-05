#!perl
# Copyright (C) 2001-2005, The Perl Foundation.
# $Id$

use strict;
use warnings;
use lib qw( t . lib ../lib ../../lib );
use Test::More;
use Parrot::Test tests => 6;


=head1 NAME

t/library/md5.t - test MD5 library

=head1 SYNOPSIS

        % prove t/library/md5.t

=head1 DESCRIPTION

Tests the MD5 library. You can create the test results using using
the command-line md5sum like this:

 $ echo -n Hello World! | md5sum
 a0f32c7d31302c1427285b1a0fcbb015  -

As well as testing the MD5 library itself, it is useful for spotting
regressisions in the parrot VM, JIT and GC

=cut


##############################
# Stress parrot using MD5 library

pir_output_is(<<'CODE', <<'OUT', "Miscellaneous words");
.sub _main
    load_bytecode "library/Digest/MD5.pbc"
    $P0 = _md5sum ("Hello")
    _md5_print ($P0)
    print "\n"

    $P0 = _md5sum ("Goodbye")
    _md5_print ($P0)
    print "\n"

    $P0 = _md5sum ("Parrot")
    _md5_print ($P0)
    print "\n"

    $P0 = _md5sum ("Hello World!")
    _md5_print ($P0)
    print "\n"

    end
.end
CODE
8b1a9953c4611296a827abf8c47804d7
6fc422233a40a75a1f028e11c3cd1140
e7cb1e977e896954fec46d2ea7832072
ed076287532e86365e841e92bfc50d8c
OUT



pir_output_is(<<'CODE', <<'OUT', "Funny chars");
.sub _main
    load_bytecode "library/Digest/MD5.pbc"
    $P0 = _md5sum ("\n\n\n\n\t")
    _md5_print ($P0)
    print "\n"
    end
.end
CODE
b66434493525523b4393ce0d1f2425d7
OUT


my $code = join
    ("\n\n",
     map
     {
         <<CODE
             \$P0 = _md5sum ("$_")
             _md5_print (\$P0)
             print "\\n"
CODE
;
     }
     (
      "",
      "0",
      "01",
      "012",
      "0123",
      "01234",
      "012345",
      "0123456",
      "01234567",
      "012345678",
      "0123456789",
      "01234567890",
      "012345678901",
      "0123456789012",
      "01234567890123",
      "012345678901234",
      "0123456789012345",
      "01234567890123456",
      "012345678901234567",
      "0123456789012345678",
      "01234567890123456789",
      "012345678901234567890",
      "0123456789012345678901",
      "01234567890123456789012",
      "012345678901234567890123",
      "0123456789012345678901234",
      "01234567890123456789012345",
      "012345678901234567890123456",
      "0123456789012345678901234567",
      "01234567890123456789012345678",
      "012345678901234567890123456789",
      "0123456789012345678901234567890",
      "01234567890123456789012345678901",
      "012345678901234567890123456789012",
      "0123456789012345678901234567890123",
      "01234567890123456789012345678901234",
      "012345678901234567890123456789012345",
      "0123456789012345678901234567890123456",
      "01234567890123456789012345678901234567",
      "012345678901234567890123456789012345678",
      "0123456789012345678901234567890123456789",
      "01234567890123456789012345678901234567890",
      "012345678901234567890123456789012345678901",
      "0123456789012345678901234567890123456789012",
      "01234567890123456789012345678901234567890123",
      "012345678901234567890123456789012345678901234",
      "0123456789012345678901234567890123456789012345",
      "01234567890123456789012345678901234567890123456",
      "012345678901234567890123456789012345678901234567",
      "0123456789012345678901234567890123456789012345678",
      "01234567890123456789012345678901234567890123456789",
      "012345678901234567890123456789012345678901234567890",
      "0123456789012345678901234567890123456789012345678901",
      "01234567890123456789012345678901234567890123456789012",
      "012345678901234567890123456789012345678901234567890123",
      "0123456789012345678901234567890123456789012345678901234",
      "01234567890123456789012345678901234567890123456789012345",
      "012345678901234567890123456789012345678901234567890123456",
      "0123456789012345678901234567890123456789012345678901234567",
      "01234567890123456789012345678901234567890123456789012345678",
      "012345678901234567890123456789012345678901234567890123456789",
      "0123456789012345678901234567890123456789012345678901234567890",
      "01234567890123456789012345678901234567890123456789012345678901",
      "012345678901234567890123456789012345678901234567890123456789012",
      "0123456789012345678901234567890123456789012345678901234567890123",
      "01234567890123456789012345678901234567890123456789012345678901234",
      "012345678901234567890123456789012345678901234567890123456789012345",
      "0123456789012345678901234567890123456789012345678901234567890123456",
      "01234567890123456789012345678901234567890123456789012345678901234567",
      "012345678901234567890123456789012345678901234567890123456789012345678",
      "0123456789012345678901234567890123456789012345678901234567890123456789",
      "01234567890123456789012345678901234567890123456789012345678901234567890",
      "012345678901234567890123456789012345678901234567890123456789012345678901",
      "0123456789012345678901234567890123456789012345678901234567890123456789012",
      "01234567890123456789012345678901234567890123456789012345678901234567890123",
      "012345678901234567890123456789012345678901234567890123456789012345678901234",
      "0123456789012345678901234567890123456789012345678901234567890123456789012345",
      "01234567890123456789012345678901234567890123456789012345678901234567890123456",
      "012345678901234567890123456789012345678901234567890123456789012345678901234567",
      "0123456789012345678901234567890123456789012345678901234567890123456789012345678",
      "01234567890123456789012345678901234567890123456789012345678901234567890123456789",
      "012345678901234567890123456789012345678901234567890123456789012345678901234567890",
      "0123456789012345678901234567890123456789012345678901234567890123456789012345678901",
      "01234567890123456789012345678901234567890123456789012345678901234567890123456789012",
      "012345678901234567890123456789012345678901234567890123456789012345678901234567890123",
      "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234",
      "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345",
      "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456",
      "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567",
      "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678",
      "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789",
      "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890",
      "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901",
      "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012",
      "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123",
      "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234",
      "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345",
      "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456",
      "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567",
      "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678",
      "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789",
      "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890",
      "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901",
      "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012",
      "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123",
      "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234",
      "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345",
      "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456",
      "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567",
      "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678",
      "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789",
      "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890",


      )) ;

pir_output_is(<<CODE, <<'OUT', "String lengths");
.sub _main
    load_bytecode "library/Digest/MD5.pbc"
    $code
    end
.end
CODE
d41d8cd98f00b204e9800998ecf8427e
cfcd208495d565ef66e7dff9f98764da
96a3be3cf272e017046d1b2674a52bd3
d2490f048dc3b77a457e3e450ab4eb38
eb62f6b9306db575c2d596b1279627a4
4100c4d44da9177247e44a5fc1546778
d6a9a933c8aafc51e55ac0662b6e4d4a
124bd1296bec0d9d93c7b52a71ad8d5b
2e9ec317e197819358fbc43afca7d837
22975d8a5ed1b91445f6c55ac121505b
781e5e245d69b566979b86e28d23f2c7
ebe596017db2f8c69136e5d6e594d365
9a09ac0f4c8c2f92d77f2d77612b6f78
28e23e897f070c849a86cd60b9a852c1
ae248bb2a77e470cb92d8e69e5f5affc
78f40ab0050544f9de011de7a4c6ecdb
d927ad81199aa7dcadfdb4e47b6dc694
6def23346f64e0163d9924f2f40c9cf2
d02ebde979264c79e141559fc9f6b65c
b61fd0bcc895bb16c784558934586d97
be497c2168e374f414a351c49379c01a
eaf9acee4b07a9986ce13edadd72ffcc
8b50575826e6ab4102f1335396b29bba
dbdf3116a6627638bff94877f31e56af
607e25deb0f2d06cbbb4d774d60e9aeb
845379ce1cb6ab954f40261250a7d9c8
c548d9f9273d070ada6070611b609e29
d0e16d114b9299f418e781feb7e189ca
7ab3976c761a67b2a1e57bf9eade8576
fecfbf31a749c7403612c47c3633ba6e
4f7223ebadee9fb57b6796570d60638f
274f173711cb1d36f5ce2d4d48ac2350
298bf0197a05149e366b6bb61835a1c1
cf09b5cb769d068e70d248ac7e013ac9
c448e84be268303d169b20280f82bc8b
541a6eada38facbba17bff5ed44512e5
358ab3835dd5371cc890ebadba6c6d6d
3887ce467d1e74ad307acb8896bffeea
f8ea4cba02b3cb898dcb8cef543845b7
8fbaa7868a809afb8a10f910dc6ce372
9f0ae0380ed27dbf6b852843d2eece1f
258b326512843f996b693fe0fc3ab34a
486011c2adb42c5dba82bec5114dc1fc
4870e0d70c0ef3f920286ccbd316a23d
e8d950dec279b91a52d06283592ce27c
604a4d755ea290e04ed2999243bf5b4a
985170ea843a93803a560dc7f445e938
a99cecea30006f01a7ca56b4845cfb7a
a73df556df9e6ceca5d2d3903d639813
fa7499e1c713703d7b28f99cd7f5c654
baed005300234f3d1503c50a48ce8e6f
8c3ef34e616209cb0efe0f6b735c110d
240d6ec1fe28630a9cc9a4978e5524f1
a3360e2d7e28ed4572c3dc16ef705372
3dff83c8fadd26370d5b098409644457
6e7a4fc92eb1c3f6e652425bcc8d44b5
8af270b2847610e742b0791b53648c09
c620bace4cde41bc45a14cfa62ee3487
66f6bb54a54f967caa2607ad2990ecb4
ad76b175d22a98a4e3bc2ad72affc53e
1ced811af47ead374872fcca9d73dd71
057a79e90fca0d805e0938d8e38a638b
10f0b5ba92a04c7502dec778490a9acb
c5e256437e758092dbfe06283e489019
7f7bfd348709deeaace19e3f535f8c54
beb9f48bc802ca5ca043bcc15e219a5a
d6329b22b4b67da8120d0074eb28cb31
061accc64d9dbd228685091cf76d6f58
7ad76683ed7802615406f4efaa1b8d8b
b5c71592955c35707a4ba4edf8dd66de
109eb12c10c45d94ddac8eca7b818bed
8ca2dc1109ec719046f23d92efe819f7
4e4c090b615aa77e69eacc7b77b5cf95
841dba25c1ecaffe412e2e748330a8ae
deb3cb2636d15d6aeccc1951b9d5f183
a6407577c4b42b2e738ad6d56ed1f486
e441c22735877b6c3c9357ba1820d708
778a111027ce535d272143817e6e9d8d
bcb0b673b05701772b02d6b747622c62
471814de0f707d1f04ba37a7d31aba36
0faef1f4cb01d560d59016a2d5e91da6
6e0c4c53a4178accb1c9b98556b8b945
240b6fbc9d3be13b28e949fc5e94a92c
004ef599b79db30564f653354fa2165a
92d36974a72cdde56527eb7e26603075
42b33f3421b374998baab3d0ce9915c7
6cda32041571c398fad2b5979321949b
dcf3495e733de25b7a0465159c48b098
0c6b4c69e1380ecc74124be9a080a2bd
321c5993da3dee64c550e87b81f9af73
3b9739dbce23373276d22e2709e82f6e
db52e041b6faca67496bae11d5177ce9
6e9f209cf47edc69a21b6cc1f7f616f9
95e99b94cdcec3b6f4a2820fb87cd9ed
08eed5e9006f867fb5dedfc42b082df8
7418f52788313c121eef974cd283e8a5
b2b23cfd66f6bdd522c47315752d7731
7c962704271a7a905cbec236de469626
84e15104f912a6cb2768ebdde00e5b33
dde798bd1d5336a07337aec45cb02576
7a08b07e84641703e5f2c836aa59a170
525cce3d8c3eaf36a756a91fcb996d59
6fd9044eb098d000b86615ff9df50e11
364603b2cf1662d139496c12f36f490a
375e3afc44bf428c445bff4363f0dbe5
477ac3a1c002d85755b40451c8db87d2
3c6f3dfa17a3022cf18db24e42f54b96
d2cfbebc441bea6a9c9c4a2faba865e2
01fb84949f9192411682b39e2642b662
2468a5c59cccb56bd51ed5ee766b2d2b
09e32555adc12a6f2c8fed9a459935af
6c27622d1d5365e4abfd02f2eccfd8f9
OUT


my $text = "Hello Parrot World! " x 50_000;

pir_output_is(<<CODE, <<'OUT', "REALLY long string");
.sub _main
    load_bytecode "library/Digest/MD5.pbc"
    \$P0 = _md5sum ("$text")
    _md5_print (\$P0)
    print "\\n"
    end
.end
CODE
840e4dec51660b1f52473e0b0b9545f5
OUT


=begin bash

test output created with:

#!/bin/bash
str=$1
echo "$str"
for i in $(seq 1 200); do
    str=$(echo -n "$str" | md5sum | cut -d ' ' -f 1)
    echo "$str"
done

=end bash

=cut

pir_output_is(<<'CODE', <<'OUT', "recursive md5sum (1)");
.sub _main
    load_bytecode "library/Digest/MD5.pbc"

    $S0 = "Hello World!"
    $I0 = 0

loop:
    print $S0
    print "\n"
    if $I0 >= 200 goto end
    $P0 = _md5sum($S0)
    $S0 = _md5_hex($P0)
    inc $I0
    branch loop
end:
    end
.end
CODE
Hello World!
ed076287532e86365e841e92bfc50d8c
153163e20c7dd03b131fe2bf21927e1e
95b9b73c7a8abe6d5bf5ad8067a53cee
d7b6778d149c5a085f2675b959503c2b
4a3dd453c637dabbdce7433653e6d7cb
88648d19a031133d87b093997813a740
a07578c3f0bebca3f2cca2b1d0b8f9fe
6134e6ee02e25ea0faf7a348ef599cdd
188ee3fb92bb86c91a08198100fa167a
dc06bc1fb41cae72a4b60e8480817085
c492befd605b7b05007d91db742600d3
2a07fa4fc4318d11908102c355ca81a8
6270c9b254b7c7c245100afb0778189f
31ca2cf9439c7f4f1da11a16a7bed6de
19626ef62b26446d35860ff932863894
3fe6e0f6adff71bc0a1a5b272527408d
3ef498d8ff923f1f91c0be6606da6dc1
34c5a11fc7d4a5ba70472f98e43c2f7b
7f0e1ffc3c4e3aa21bce804fd15cca1c
da76374e9095cdeb3bc95d3f9444f47e
f0dee836be39db7440b3c6ca4671afba
645a3f6129b1db41e986d94c7c6df03b
09300ce54fbae580ca496975bc3746af
65721cae6209d5ce50b17b06a9d693c8
b0038c2e9e9e01bf6883aaffc7726dec
18e9b196e808d2de844269b0608050d6
e563825454806b0ef84cf92fc9f54bfe
312f040493d0f7e4cc300bf70522e7bb
f4b2951c999e85a0db42799cfac9cca9
5dc63983b315585c8b68614c1837f358
ab577e59aa6a91d46f3f0bbe4f8f52a0
479b376dc5bc108efddb9139e3f48683
5fac17e1a48c1e1b3b8a696cc9f8992d
bef9fd06a052823abcfed2851cc2c505
09682b791db555c9867dc750eee0dd92
d9cb3599d16c4d197af9d1d54ad8fd0b
d9f1f852cf0dc85f3f676a492bfa6165
366d491706ad8ae5e726cedd3b08da77
a2849d41666406842463e406210df7da
63dc097352e3e637cc06b5682f781bd4
bc8ac884c97864f3d00d51240eeb06e6
7bc0f81018700689eecd45a4c70d4fae
33a71e77fd62d81d0cf6bda304606919
f32bd05330a93b0f95d88484908af7cd
8c4d905dd7fc8e965713f04841654cf4
33d7e3b19719f6b7386dae5bc2bfe881
069e844b1ef6230502f21ab8305fce67
801a4cfd4974f7267a8717faa7ec1dea
69d1a0fc4115f3f2e1e7db00c9d9cc10
79d62c23d99e920058aacfb3a71727c9
4386f8f55928bf946715d475caee6329
c2c9922ca2dae04985aa6488b87a7920
c0362fd0f999083411a34554901f8bb2
b6006163f03a93160879dcf4c930f769
6bc51c74e5a48f55dfdd6ec832c729c4
3f358f1893cfabdcd2020d8a1a2228d9
0d58c1a1dc62d768bfce37629c0f13c1
de66ee9f9d5373aa9ad259c8b3252909
c4e752f1a4c371ed24c4432941a5c2ea
778932a44e59ab759d8c5dc58f708242
54ce309ae9d4180a5a0adfee5dbc9c09
155a9f73f32ee6daf9c63e0051fdde6b
4025eb29c97dff3a44272b80b59963f4
7422ed91f76bf90e563c2002975632da
2a852d35bd49b7615321116725a32d0a
4b51d3d0f011b47d3f19e46dd1b525c6
62b3f84c8ad8762800efd35e67b02870
87483a3a842997956624542314accd89
d16383146ca5f31899d0d67f70e0395f
8beb021063ab267d37299fda68493ce7
7c2861c7d3318a11232ce920b14b13ad
1bf15129d5dfdf031921884175560813
b122b76f62757700c94f364cffef4cb5
89654021f6cec4d23a4c0f432d43eace
3f8021e428a41481b6454621eefec06d
44d7f6a4a01e1f06ae99751f9f82724f
07e7463bc04afb99ca64f65065954c90
c4c917cde83ed67e046cc3d88dbd662d
50dd647fe2f8daac51b1e9fd82cd0c59
6996c802026e01b31c2c5335ecbd189c
facb55614a088253f7f523d6d866e0f3
2be76a537c144f68b373a3994cd54c00
1a1a5b5acf50e98b1b9e8b918842b06e
0db736e817c45e4b653ed7f0c4e11962
5bf01fad828b838eeb1ff1274d876ccf
0fc2f4335bb190fa426abdb25de3da63
76b18e07cfdc6b293d91bdddbb61ec44
d0e138c4c80fa3915ba39b65512b799e
2144a5cb38bfc3691e3f8320e206aa5a
d11ec2aa70f7e58fc8f870d971352c79
17997c047bf5a2f401df7b908e47d2d1
85127ad7f64592b3e26cf0a1cdb2d890
5caaff4022e4f11f7f3e90d9974e2532
ab7193c2ed710ac8a0751b440e6448bc
6f2f2a3608de8fb79dc3309bd175e8e4
5a61579726264cc970497364cbbe191f
013c4f7a6b922542ea633f095b62fa6d
ce78937e0701406f642ebc3b9a29736b
e982e60d843c27b4858de896fcd075f9
8010f2cc72ba2554831348eebf6f8063
898ca64355754b2739b197a12f81e72b
b10bd7a27a36d90db7404079249a9f2a
cc673e2f9e08dd4a5da13931fb12f256
5a330e820ae46926566728f4abf6b87c
cbd0dd745c96ded00ff4627ea09bf97e
13a6d457cb091d0d9fe6deb410bc5d61
d7fa1c426850c9fee843f26b8c77c2d3
a604741ba924f4eafba8bd901b211f71
9299b0abdee549d55201efb3cc2fedde
f7a77b983776ec5eb3623476abffd222
9b276abb98aab4679006837318f9c64f
9c26edea8dc26d13e08a2cb4a4e4bd0f
56509b48041cf2de19f95688c53411af
bdf23fd1e120588501b012e7f58f2f4e
c588a957d5c8aded27a80e61c10e6723
88cd2ece9f5a8f40e20db49e2ee665cc
81088b08083648a6389a885791999f80
b45f5958a624def39c6bb1ac08c65605
01bd47325d69032df808d77304ddb250
3de24ffe65f69f32e2ffad7660f9da80
894a41dc061257bff5d1dc01f0c53288
52051634a70acb7576124d7a58a95109
75972f135bc8352457e20a3a90a6a589
c4a3008d30a7301cac9e9c62768fbed6
a965aa510d98ccd2727739e7e0ad9baf
fe789ea51ba9c2dfd89201957dbed4e8
ac65a4908d1453f02099da5fe395b874
dd97042c49e4d5e02543e6fec306dc1d
fdf60f998f585cc0077642fce8d968d8
686bc6f7a5ae6c0b24244514ba31bcb3
82e8a11f78293cdef3aed1b409cc4341
1cbb3fc50103062e3af258ca7fa76fef
e79344cd8e4889cd96aae999ac7f1d92
203e9fba5f417f6818ac5997dea57c36
62d2dfb64abd0e990edacb7dd380789c
b588fddddc8bdeacca65a3898ccc31c6
0de848c93df70d3f8b4536daedb965e7
cb672ab063522a764f14e9146d8b50f6
c5e2f087d25d0a32f14e9e30cd42b3e5
e81920116df890f329496f3374b2916a
2a03fcb63f2fdac03e4efa49607d1204
12fcc5b48205df7f6765200f134bed6b
54be0d792fb11d71511a39b0981b8855
f84aa178ad34aa06d9a1eb1560a51473
7e754096ec34c6255fbadd10cc99271c
d37e8a1c3ba5127e2f671f2af1b1c147
6648d37231e0384b9e7673d05a71c805
2d33995591700d28dab2a981d9aa1c1b
938e810ff307c91e9c71db1951d626e2
7197ab005cbf62eb87534e9565046c7e
76c74a72f5c4423cdfe712b1e094c705
6970e6209350fd4872f61232de6de4c4
ff1e26affac06a63377cb299b139f051
282c7b64cb49aa8d6d9b3902e858ee01
364ded1ae5536a7de60c388631c62a7a
33772fd38d48ab5e2af9da19ac0a57a2
c3cd53f270b6f2c90cedef280393316a
7fa3df3e898e84003370b7508fb1197f
d482c8e2dbada445bc42b5acc7c19fb7
2bb874c958b5920c5a30e64eb1f77977
1e24628bf4267a0d4d70e90bc9cb8301
c6ad085d3a908edfef296eff1d76d0f4
a87ff6b28555da307ae1457566c7d54d
2606de1537cc67239e7ea6e9c4f215ae
1e78c6c735f345c69520f0ff2e041f2c
07367b754860d1c176fd7b5cb7a530e0
528567c7710daf2ff6129e64a8ebdb08
a54f097f1361b635bde2320f39109fd9
0944ed06737d5c875f60c54c4b232daa
1878f76bfda90a8865095ea555b8dd45
501e41071b2d775d2f5937e7eb6de26a
0eb6cc9233a88feacb7ab28d21e87ae8
7a39b11879c2cc4579e2a2c4ea67d122
97f170e24df3a9fdd177843c3a02776c
201e15125105249507addd3090967894
c02dd79a529a7c6a1296309a47a2877a
adc96507fd2c76221222b33b73dd9292
46ffcbdae112435edb1e0b6f66859cbb
696b64eca6825fd628f10a1263077bff
813ef0bc04145562fb3d03a54b2f4b8e
15605a3407c1551375476401e39e5342
c8346e15ac6c745ca168f9223eff2439
72209f28cedf359957667eb913f5c57d
9d594e36709e5e9afca1eea8fbc26d50
7e63eb5c61256ae7728685b7af74d9bc
c683e12918f470c5778a69af6e9e55d6
768cc7983d4944f46aa3541c7353c4d8
a8c93832333f39e34b2e337e5e617953
ca8258d669b07b992f04ac1d2e58db02
c4a7d67e32d1a06621e19e721cfe972c
54bacec5eae8c4a2bc1093794bce5e2c
8a6d7f412dc7e53e3f0b025b7f073493
8a9c2d66d8bb5e267fe5ad1e3ff83efa
7be4b86f931da25073f5409b9885c376
efe082b4afffc6e5ef3fdbfabcbe817f
09c7aa151ecbb67865ecedbaf5c3f4ad
d3ea9bd2f33e17e699517912322fe972
b63d8a186e272754b70953ddd441e9fd
84a112f819bf780dd268c68f21238374
eab26f6455a08779bcb43bc48c02c717
OUT

=begin bash

test output created with:

#!/bin/bash
str=$1
echo "$str"
for i in $(seq 1 200); do
    str=$(echo -n "$str$str" | md5sum | cut -d ' ' -f 1)
    echo "$str"
done

=end bash

=cut

pir_output_is(<<'CODE', <<'OUT', "recursive md5sum (2)");
.sub _main
    load_bytecode "library/Digest/MD5.pbc"

    $S0 = "Hello World!"
    $I0 = 0

loop:
    print $S0
    print "\n"
    if $I0 >= 200 goto end
    $S0 = clone $S0
    $S0 = concat $S0, $S0
    $P0 = _md5sum($S0)
    $S0 = _md5_hex($P0)
    inc $I0
    branch loop
end:
    end
.end
CODE
Hello World!
ee41c968530f7715ab70805b341c3956
9548194ce84b2f7953386080da112c3a
9fb892cc0766429a1d8b0f752636c0fa
2fe752de4df1987b5682806c3ef37c5a
3030c16c1bac91e414f49394dbdd4f55
49d17233607383b6a7de5596cbfa40eb
1ef11b372f3d918c35901be67376207a
37369890630daa6fa20bab9293b3349e
1fe9a9f66fb556cccab339e684626a84
5039c55c89342feda99186afbe03c33d
52d20c3601d13cbb5caa9d26ab37723e
daaf532ebbbb00724a6a79be0cab1bfe
8c1e07121bd5e95013952fb5f55dd060
fc4bc5ee4d3347de8b517c27c0a8eed1
94d9d734e97421f64a71ec8d45781cdd
4b6ecae770f66dbb02ff3a59d6eedeb3
4ed31aa15d35ef52778508dc4cf7f84f
e14fc1e6320fa34660b27ef86b15caac
b79c5e129315c530b9b80a7c5a130c1b
9c4db0bc1cba0bc7a31e59db901d1362
75f5fcb94015872ca0c23bd5ed21c224
d3cdb5b27a0185365b42fdebfc5a1e33
98508cba7dfd5deeec4b8561c6bba42f
c0b8211ff3cd39cbbd6436e02cfedbda
783ed8f7d844efbc1c579b4b209360d9
a2b5528f3e2c506632601ea51df56d4f
2b46b6024f925419d79e6f86b33a3cf5
0276b6ca7eef6549d42b476ac4d2b049
e62ea2d5a6a7df48fe217909dc14a760
b84fe25ba8510f8a20da5e073992f6f9
0fb9bfff70bdd01b6e66f5864fb3c83f
3b10269c809a34d5239a0387422f66bc
3e0510deff0ef5e5b0dcbc0897d0622d
4d7fb6d3a50095b746f293ebe55a0bcd
cefd97e21fa803e960747a77e60fe39c
d7aa1e54cd8f7305391a236d1e56db42
3bbad66887cab24bb7e983bba3eac325
046b89e3a25c8372973113ff82b21abe
e4c174ab190ae7d59a2c9efa358ee60e
965544e7ee1040a234423c7708c45fd4
d92ed17d3817e51dac84e3bbd654f61c
34d00ed230a1fe8ba612f134326f0032
b8fe0ca50d70e605a0a65757affddf27
8cb68a7e99ac140f570188e92d1d2e45
6c45c11f3288af98126032b83454bdd7
82a5e65630a6df3d3272c4d706642804
17f51bff9ae985dee9547bbecef516a9
ace5283938a1003cbe1a25e32cb10057
364c61ec3fa510a2fdea988a04700ee2
de47aab46499b65cb73137c5ef161b28
877d37e40be25eff0e5a34f8701e9ff0
b2ba5696640f6c9d49ace67dbf178003
c38f63c86d919b38ceb8eb3bdae39f35
2ec338a2045b0d7a90ad279afd45eaee
05587d4ce4269f05c7e99e8bc790fed4
79e8bb5b94e687127b53f70eee64f403
1ff5dbd7c303f5ecb688cbc64e7a135f
07cfb35560313b13c83b34fa57076f14
5b562211545af5a95a873a5d8e3b9a6d
b08cf4400af1f8f13864da377fa97bff
bb706135638a8d77ea2c1ef5a5539bf7
6e08ae82fc5fbf55855602751b2d2c42
384b9112e19f5eaf187287e4dcee75e3
599ce20a11961b6e322106fed1b1f2e0
0e28143d15e6203ee316ed4c0558ff7a
4687a81afe698c362b3b3bb14d6c8ba9
419468fd66d946a0c892fa49106519ef
bb1b91d55152ba71777846fc2d4ebdf1
b405a24631d8fcd03eeed4249e9e1094
7be108fc15f3520b4ac637bd35597c95
8109f5a7ada16a51a9b6f1544ea85ea8
977433a6b14e766c41fa394007022096
124991f749a3f57bec7a72491349d2ab
8c671f8ebd350e9f79f127dd1c2dd048
f0ec2da36ad8cb2a0634fb2f70986c73
84a19613368ed9db0f3a42306872e29b
7b2f70096518e2d1d1a78e2c03065a69
9d150b414105e1289819df8efa567020
bb23274b2905ad3b623ccef55f75a468
4a75965a2b7f36e835201f3bfea10275
e22f29c343270f374c97687f3b7b0b66
2c55a15b3b9f3a97e114788ab26ce25e
a47134ba65aac9d0247b883e1ae387a2
367996de14121db2b8acc08b4716d125
ff7ff06cc7a6b12411d0f12dba779a13
f02344372ed7545d6dece5235c67327d
177a0082d277eb5efb6611a8fcaebf60
c9cef0b43563e9e12db3fe7b8a963a83
628867de0dcffae9f9435e0ea934769a
2a5389f9e88440e2e10b1ee61c476c9a
00ccb3071dc68daf6073d47453184ac7
70c89453989edb537bead30e83315166
2798118ce1c06a07989d89ab576a0b10
405ecd4ba790ebf79c7ee0eac3302430
ed76f9555303667976542e6481e6b6de
1aaac64d40d418414d5cc45e179998d2
725f3969179a13a88bd4710a68c7125a
cfdb37edcb3dfb65833e024b5190ac3d
bc33bcccad3bc958254cb5c9c24021e9
332b640f26b61dd553eeec4368e66ec2
d901771fd533f45aa9f8e6a89cdc50fd
a8b7c7a75da36a48cb521ba6c47b3d5d
0df89d833f2cfc704a54048a4fc25aa1
d0fdba931c657ae40db6de92fd1ad46f
3372e1f3859eb3133cbfb3ad4eb7ec87
58c050421e7063a3f228d8469a593706
e0efb8a7318d6aa3f4bb5504014169bd
bb76e71f387e28233023f6fcb363e77d
8708a28d0a12f36b8c814e1b23ae7d18
e4a2db9c1eb240a29519d47231a281b2
c1dccedeee5db48a8b850d4168f263b2
8b6540063c1867930ad609f78550ab45
61c8de37be3d7487e576a14ce519e402
4c39d3f4b7c5261b8b69278cd01cf61e
24b233c65768eafb144ffe4b237b2cda
624a97bd2d8d7945f0c79f660db79a6f
023eb3047f11a098e94c9b2f4dc395ad
77c08226ccc5722b777d79a2dacad01b
4ada0a4ed2a378da6ab3e36397ed933f
8e55ecd7bea4c69dd5411bed4f6af7a0
5890e55ed991429e062ed9bba2434fa2
6f29cdee26d8f59e399c75adc3ca963e
6f95058ad5897aac4c2c4e0a3447fddd
76a4b0b68df0015d5032f710a89b1989
553ea59edaec8245ca0b15f7f07d87c2
0ac57da5cd62c875b635d67c518d6972
a2216e7284bcf53f33da68b34170d869
08e4982dc84b56ad28948f0dd901bc05
d392a218b0f43a64489056256f969771
cd5543ca0553ee65d8b6d3404bf8b4ff
caeffa85a366f9bdd250cf1ecf3521ec
9a31f0f5b2f3e7e923bcc963502faf77
6ba7674cd36efbbbbcedab61d0cfdd95
df70da7d729efa4bcf037e0c2ed5aa0a
c69a07323e7105f3bbec3c287176c832
718f43dc297883de170d6e202dde9304
586ca71bfc8346b5d66613eb61a62392
220be4284d452c8205cf7767b774391c
54c9fc8f87b97a365834939ae4f047c6
baa53a78af5b174a674d0aecebcaf61c
897cdb62345099a3ce61c79148232d6b
b27b90a56eb999ed1b4f8f1fe20a03b8
bc37714ce2429460f363dfeb9e0fe130
451ce3e7aeb0fe575fd81acb9310c075
fc5223fd5a7457467413ef308484d3c7
18e58dd646ded1f8d973c0622c291ea8
1a34942df9b6b4c37d8694dd623cf4ed
1e540d9eb73f6a77135965f7ac52705f
01e6c944693e1ab23f176770948b63f3
440ad0e977d7b29240fc25645d271679
22c32fa8419ce0e9016e12f1cf9bd087
2fe03c2d4eab897c3ee7bc1ba687c1ca
9d7a2b063f7c375ea2528cd3c130a3c5
30318b3885c6f8e529d47e855a147753
09bbb9619dfd40414219a61fb5cb3f97
49f70a0b8dc368699e5509acc86067e8
1a3f2f5ac50b11d0f1441542f4103cdb
f62c4148d6a1a0d8bfc0830d92ed6ff8
c5868b2705f5a6c4e09b27e0c5e02fc4
d7611c94b236170077a9ccc3aed12b68
88fbb89660b33af29c0235c16e649d14
060054d8da83373e890586474bb0b844
ea0460399040570c24228aeba16ea548
e012db2951dacbc563fd1009908e26f7
9624f225fce79c7641f9fddedf1bb0e8
a13457b3b70f0377f93293ed26686b48
8c7f01c853c9f01248975e0c5838be36
f214e4e994f5d43e6d0b66d7c83909f7
31e1ef44d59205f8b70aa51247c4da5a
ee2f5bbb91dcb60545ed43b27ecf69b4
83f8f26970509c1f7958c42d3f4666c8
beb27e4616ed743cbde0e90e8fcedd85
64193d5ebb92c2a6e259818ee1a7b3cd
f36944249177ec4130719fd368eaf134
dfda44c7e068eb7d51f5925c4cbe4e3d
4f84611f754fbe80ba73cb278e6878e0
2bd7d30e73cb7a41842ca84782cfd3e6
c5532ffacc9cb4118b9dfcb6df5c92f1
d599e219cb43d15cd5a762052f71ab31
39a83debb4728212bc99b52375b2e6fe
773e28213d42e67a28d30509bb270741
36622bbee96e8d25d0a99f3d8e123b56
740495ae233ac2cc700183c550f871c3
0b34a880f5b434f40b5c777286dd9846
ae9773b3bc76125b06c0a6a441ec2ddc
39eaf3f8c28604aa5003f525ac900aac
c3c96034913b7b16451760c7cb707017
e696e2429c1c0ad48d68d5f8ccbf1d82
b45bc13eeb6ed7998fa94b676318fef1
16d61b48946c94a1b9a1cb7261ab812d
029bb7d6bf6b4c1eeb59c13543be7992
1840f1eb4b6516c1eb302d1b175070c5
a83c6cd9e67c60b5e745e40eb2d3b00f
6a7b7139dacfba962b392dfa5a9169a6
746d6f9a4c02bf3fcb1997a1d947a260
f67fa138069da8fce68c131106492372
614def545c4a4ecba07bf62966f0cc0b
982d93d2437c46edbf99f542900231c0
8408bf5f0144309374e66278bec290b2
982e0fde28cd2f62ef8db2d8dfd0f0d7
OUT




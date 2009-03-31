# Copyright (C) 2001-2008, Parrot Foundation.
# $Id: http.pir 36833 2009-02-17 20:09:26Z allison $

=head1 NAME

examples/io/http.pir - HTTP client

=head1 SYNOPSIS

    % ./parrot examples/io/http.pir

=head1 DESCRIPTION

HTTP client, connects to WWW port and grabs a page (L<http://www.ibm.com>).

You should be running the echo service on your box (port 7). Be sure to
set C<PARROT_NET_DEVEL> to 1 in F<io/io_private.h> and rebuld Parrot or
the network layer won't exist.

=cut

.sub example :main
    .local pmc sock
    .local pmc address
    .local string buf
    .local int ret
    .local int len

    # create the socket handle
    print "Creating socket.\n"
    sock = new 'Socket'
    sock.'socket'(2, 1, 0)
    unless sock goto ERR

    # Pack a sockaddr_in structure with IP and port
    address = sock.'sockaddr'("www.ibm.com", 80)
    print "Connecting to http://www.ibm.com:80\n"
    ret = sock.'connect'(address)
    print "connect returned "
    print ret
    print "\n"

    ret = sock.'send'("GET /us/en/ HTTP/1.0\r\nUser-agent: Parrot\r\n\r\n")
MORE:
    buf = sock.'recv'()
    ret = length buf
    if ret <= 0 goto END
    print buf
    goto MORE
ERR:
    print "Socket error\n"
    end
END:
    close sock
    end
.end

=head1 SEE ALSO

F<io/io_private.h>.

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

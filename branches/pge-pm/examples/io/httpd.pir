# Copyright (C) 2005 The Perl Foundation.  All rights reserved.
# $Id$

=head1 NAME

examples/io/httpd.pir - HTTP server

=head1 SYNOPSIS

    % ./parrot examples/io/httpd.pir

=head1 DESCRIPTION

A very tiny HTTP-Server. It currently only understands the GET method.
It's a nice way of testing pretty much all io functions.

By default it binds to localhost:1234, and serves the HTML Documentation
in ./docs/html. Make sure you have built them with

    % make html

After that you can browse the documentation with

    http://localhost:1234

which redirects to

    http://localhost:1234/docs/html/index.html

Currently the URL isn't decoded, so the docs get served only partially.

Make sure that C<PARROT_NET_DEVEL> is set to 1 in F<io/io_private.h> when
parrot is built or the network layer won't exist.

=head1 TODO

make it work on W32/IE

Transcode the received string to ascci, in order to have access to an implemented 'index' op.

=head1 AUTHOR

Markus Amsler - <markus.amsler@oribi.org> 

=cut

.sub main :main
    .local pmc sock, work, fp
    .local pmc fp               # read requested files from disk
    .local string address
    .local string buf, req, rep, temp
    .local string meth, url, file_content
    .local int ret
    .local int len, pos, occ1, occ2

    .local string doc_root
    doc_root = "."

    socket sock, 2, 1, 0
    unless sock goto ERR_NO_SOCKET

    # Pack a sockaddr_in structure with IP and port
    address = sockaddr 1234, "localhost"
    print "Binding to port 1234 on localhost.\n"
    ret = bind sock, address
    print "The Parrot documentation can now be accessed at http://localhost:1234 .\n"

NEXT:
    listen ret, sock, 5
    accept work, sock
    req = ""
MORE:
    recv ret, work, buf
    # charset I0, buf
    # charsetname S1, I0
    # print "\nret: "
    # print ret
    # print "\ncharset of buf: "
    # print S1
    # print "\nbuf:"
    # print buf
    # print "\nafter buf"

    if ret <= 0 goto SERVE_REQ
    concat req, buf
    index pos, req, "\r\n\r\n"
    # print "\npos1:"
    # print pos
    if pos >= 0 goto SERVE_REQ
    index pos, req, "\n\n"
    # print "\npos2:"
    # print pos
    if pos >= 0 goto SERVE_REQ
    index pos, req, "\r\r"
    # print "\npos3:"
    # print pos
    if pos >= 0 goto SERVE_REQ
    goto MORE

SERVE_REQ:
#    print "Request:\n"
#    print req
# split is not implemented, so parse it the old way
# GET the method and file
    index occ1, req, " "
    add occ1, occ1, 1
    index occ2, req, " ", occ1
    sub len, occ1, 1
    substr meth, req, 0, len
    sub len, occ2, occ1
    substr url, req, occ1, len

    if meth == "GET" goto SERVE_GET

    print "unknown method:'"
    print meth
    print "'\n"
    goto NEXT

SERVE_GET:
    # decode the url
    url = urldecode(url)

    # redirect instead of serving index.html
    if url == "/" goto SERVE_docroot

    # Those little pics in the URL field or in tabs
    if url == "/favicon.ico" goto SERVE_favicon

    # try to server a file
    goto SERVE_file

SERVE_file:
    # try to open the file in url
    concat url, doc_root, url
    fp = open url, "<"
    unless fp goto SERVE_404

    read file_content, fp, 65535
    rep = "HTTP/1.x 200 OK\n"
    concat rep, "Server: Parrot-httpd/0.1\n"
    concat rep, "Content-Length: "
    length len, file_content
    temp = to_string (len)
    concat rep, temp
    concat rep, "\n\n"
    concat rep, file_content
    send ret, work, rep
    print "served file '"
    print url
    print "'\n"
    goto NEXT

SERVE_docroot:
    rep = "HTTP1/1 301 Moved Permamently\nLocation: /docs/html/index.html\nContent-Length: "
    file_content = "Please go to <a href='docs/html/index.html'>Parrot Documentation</a>." 
    length len, file_content
    temp = to_string (len)
    concat rep, temp
    concat rep, "\n\n"
    concat rep, file_content
    send ret, work, rep
    print "Redirect to 'docs/html/index.hmtl'\n"
    goto NEXT

SERVE_favicon:
    url = urldecode( '/docs/resources/favicon.ico')
    goto SERVE_file

SERVE_404:
    rep = "HTTP1/1 404 Not Found\nContent-Length: 3\n\n404\n"
    print "File not found: '"
    print url
    print "'\n"
    send ret, work, rep
    goto NEXT

ERR_NO_SOCKET:
    print "Could not open socket.\n"
    print "Did you enable PARROT_NET_DEVEL in include/io_private.h?\n"
    end
END:
    close sock
    end
.end


.sub to_string
    .param int n

    .local string ret
    .local string char
    .local int rest
    ret = ""
NEXT_CHAR:
    mod rest, n, 10
    sub n, n, rest
    div n, n, 10
    add rest, 48, rest
    chr char, rest
    concat ret, char, ret
    if n > 0 goto NEXT_CHAR

    .return( ret )
.end


.sub urldecode
    .param string in

    .local string out, char_in, char_out
    .local int    c_out, pos_in, len
    .local string hex

    len = length in
    pos_in = 0
    out = ""
START:
    if pos_in >= len goto END
    substr char_in, in, pos_in, 1
    char_out = char_in
    if char_in != "%" goto INC_IN
    # OK this was a escape character, next two are hexadecimal
    add pos_in, 1, pos_in
    substr hex, in, pos_in, 2
    c_out = hex_to_int (hex)
    chr char_out, c_out
    add pos_in, 1, pos_in

INC_IN:
    concat out, char_out
    add pos_in, 1, pos_in
    goto START
END:
   .return( out )
.end


.sub hex_to_int
    .param string in

    .local string char
    .local int ret
    .local int pos
    .local int factor
    .local int temp
    .local int len

    ret = 0
    factor = 1
    length len, in
    sub pos, len, 1

NEXT_CHAR:
    substr char, in, pos, 1

    if char=="0" goto CHAR0
    if char=="1" goto CHAR1
    if char=="2" goto CHAR2
    if char=="3" goto CHAR3
    if char=="4" goto CHAR4
    if char=="5" goto CHAR5
    if char=="6" goto CHAR6
    if char=="7" goto CHAR7
    if char=="8" goto CHAR8
    if char=="9" goto CHAR9
    if char=="A" goto CHARA
    if char=="B" goto CHARB
    if char=="C" goto CHARC
    if char=="D" goto CHARD
    if char=="E" goto CHARE
    if char=="F" goto CHARF

CHAR0:
    temp = 0
    goto CHAREND
CHAR1:
    temp = 1
    goto CHAREND
CHAR2:
    temp = 2
    goto CHAREND
CHAR3:
    temp = 3
    goto CHAREND
CHAR4:
    temp = 4
    goto CHAREND
CHAR5:
    temp = 5
    goto CHAREND
CHAR6:
    temp = 6
    goto CHAREND
CHAR7:
    temp = 7
    goto CHAREND
CHAR8:
    temp = 8
    goto CHAREND
CHAR9:
    temp = 9
    goto CHAREND
CHARA:
    temp = 10
    goto CHAREND
CHARB:
    temp = 11
    goto CHAREND
CHARC:
    temp = 12
    goto CHAREND
CHARD:
    temp = 13
    goto CHAREND
CHARE:
    temp = 14
    goto CHAREND
CHARF:
    temp = 15
    goto CHAREND

CHAREND:
    mul temp, factor, temp
    add ret, temp, ret
    mul factor, factor, 16
    sub pos, pos, 1
    if pos>=0 goto    NEXT_CHAR

    .return( ret )
.end

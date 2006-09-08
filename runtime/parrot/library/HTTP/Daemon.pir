# Copyright (C) 2006, The Perl Foundation.
# $Id: httpd.pir 14438 2006-09-06 11:59:32Z leo $

=head1 NAME

['HTTP' ; 'Daemon'] - A Simple HTTPD Server

=head1 SYNOPSIS

  load_bytecode "HTTP/Daemon.pir"
  opts = new .Hash
  opts['LocalPort'] = 1234
  opts['LocalAddr'] = 'localhost'
  clid = find_type ['HTTP'; 'Daemon']
  d = new clid, opts
  unless d goto err
  d.'run'()

=head1 TODO

A lot. The code is by now just an objectified version of httpd.pir.

=head1 SEE ALSO

RFC2616, F<examples/io/httpd2.pir>

=head1 AUTHOR

Leopold Toetsch <lt@toetsch.at> - some code based on httpd.pir.

=cut

.sub '_onload' :load
    .local pmc cl
    # server clsass
    cl = newclass ['HTTP'; 'Daemon']
    addattribute cl, 'socket'	# pio where httpd is listening
    addattribute cl, 'opts'     # options TBdoced
    addattribute cl, 'active'   # list of active ClientConns
    addattribute cl, 'to_log'   # list of strings to be logged
    
    # client connection
    # XXX this should subclass ParrotIO but opcode or PIO code 
    # just doesn't work with classes
    cl = newclass ['HTTP'; 'Daemon'; 'ClientConn']
    addattribute cl, 'socket'	# the connected pio
    addattribute cl, 'server'	# whom are we working for
.end

.namespace ['HTTP'; 'Daemon']

.const string CRLF     = "\r\n"
.const string CRLFCRLF = "\r\n\r\n"
.const string LFLF     = "\n\n"
.const string CRCR     = "\r\r"

.include "stat.pasm"

.sub __init :method
    .param pmc args

    .local pmc opts, active
    opts = new .Hash
    setattribute self, 'opts', opts
    active = new .ResizablePMCArray
    setattribute self, 'active', active
    $P0 = new .ResizableStringArray
    setattribute self, 'to_log', $P0

    # create socket
    .local pmc sock
    sock = socket 2, 1, 6 	# PF_INET, SOCK_STREAM, tcp
    unless sock goto err_sock
    setattribute self, 'socket', sock

    .local int port
    .local string adr
    port = args['LocalPort']
    if port goto port_ok
    port = 80
port_ok:
    adr = args['LocalAddr']
    if adr goto addr_ok
    adr = 'localhost'
addr_ok:
    opts['LocalAddr'] = adr
    opts['LocalPort'] = port
    $P0 = args['debug']
    opts['debug'] = $P0

    # bind
    .local string i_addr
    .local int res
    i_addr = sockaddr port, adr
    res = bind sock, i_addr
    if res == -1 goto err_bind

    # listen
    res = listen sock, 1
    if res == -1 goto err_listen

    # add connection
    $I0 = find_type ['HTTP'; 'Daemon'; 'ClientConn']
    .local pmc conn
    conn = new $I0, sock
    conn.'server'(self)
    push active, conn
    .return()

err_listen:    
err_bind:
    close sock
err_sock:
    $P0 = new .Undef
    setattribute self, 'socket', $P0
.end

.sub 'run' :method
    print "running\n"

loop:
    self.'_select_active'()
    # while idle dump the logfile
    self.'_write_logs'()
    sleep 0.1
    goto loop
.end

# === server utils

.sub '_write_logs' :method
    .local pmc to_log
    to_log = getattribute self, 'to_log'
    .local int n
loop:
    # log can fill, while we are running here
    n = elements to_log
    unless n goto ex
    $S0 = shift to_log
    print $S0
    goto loop
ex:
.end

.sub '__get_bool' :method
    $P0 = getattribute self, 'socket'
    $I0 = istrue $P0
    .return ($I0)
.end

.sub 'debug' :method
    .param pmc args :slurpy

    .local pmc opts
    opts = getattribute self, 'opts'
    $I0 =  opts['debug']
    if $I0 goto do_debug
    .return()
do_debug:
    .local int n
    .local string fmt, res
    n = elements args
    fmt = repeat "%Ss", n
    res = sprintf fmt, args
    printerr res	
.end

.sub 'log' :method
    .param pmc args :slurpy

    .local int n, now
    .local string fmt, res, t
    n = elements args
    n += 3
    now = time
    $S0 = gmtime now
    chopn $S0, 2	# XXX why 2?
    unshift args, ", "
    unshift args, $S0
    push args, "\n"
    fmt = repeat "%Ss", n
    res = sprintf fmt, args
    .local pmc to_log
    to_log = getattribute self, 'to_log'
    # Yay! The fun of any async server
    # write to log when we idling
    push to_log, res
.end

# === connection handling

# add select even to all active pios
.sub '_select_active' :method
    .local pmc active, conn, sock
    .local int i, n
    .const .Sub req_handler = "req_handler"
    active = getattribute self, 'active'
    n = elements active
    i = 0
add_lp:
    conn = active[i]
    sock = conn.'socket'()
    add_io_event sock, req_handler, conn, 2	# XXX magic 2
    inc i
    if i < n goto add_lp
.end

# accept new connection and add to active
.sub 'new_conn' :method
    .local pmc active, orig, work, conn
    active = getattribute self, 'active'
    orig   = getattribute self, 'socket'
    accept work, orig
    $I0 = find_type ['HTTP'; 'Daemon'; 'ClientConn']
    conn = new $I0, work
    conn.'server'(self)
    push active, conn
    self.'debug'("accept new conn\n")
.end

# remove work from active connections and close it
.sub 'del_conn' :method
    .param pmc work

    .local pmc active, orig, sock
    .local int i, n
    sock = getattribute work, 'socket'
    close sock
    active = getattribute self, 'active'
loop:
    n = elements active
    i = 0
rem_lp:
    $P0 = active[i]
    eq_addr $P0, work, del_it
    inc i
    if i < n goto rem_lp
del_it:
    delete active[i]
    .return()
not_found:
    self.'debug'("connection not found to delete\n")
.end

# if work is the original httpd conn, it's a new connection
.sub 'exists_conn' :method
    .param pmc work

    .local pmc active, orig
    active = getattribute self, 'active'
    orig = active[0]
    ne_addr work, orig, yes
    .return (0)
yes:
    .return (1)
.end

# reguest handler sub - not a method
# this is called from the async select code, i.e from the event
# subsystem
.sub req_handler
    .param pmc work	# a pio
    .param pmc conn     # Conn obj

    .local pmc srv

    srv = conn.'server'()
    $I0 = srv.'exists_conn'(conn)
    if $I0 goto do_read
    .return srv.'new_conn'()

do_read:    
    conn.'_handle_request'()
.end


.namespace ['HTTP'; 'Daemon'; 'ClientConn']

.sub '_handle_request' :method

    .local pmc fp, srv, work
    .local int ret
    .local string buf, req, rep, temp
    .local string meth, url, file_content
    .local int len, pos, occ1, occ2, do_close

    srv = self.'server'()
    work = self.'socket'()
    srv.'debug'("reading from work\n")
    req = ""
    do_close = 0
MORE:
    recv ret, work, buf
    ## read buf, work, 8192
    ## ret = length buf
    srv.'debug'("**read ", ret, " bytes\n")

    if ret >= 0 goto no_close
    do_close = 1
no_close:
    if ret <= 0 goto close_it
    concat req, buf
    index pos, req, CRLFCRLF
    if pos >= 0 goto SERVE_REQ
    index pos, req, LFLF
    if pos >= 0 goto SERVE_REQ
    index pos, req, CRCR
    if pos >= 0 goto SERVE_REQ
    goto MORE

SERVE_REQ:
#    print "Request:\n"
#    print req
#    print "*******\n"

# parse
# GET the_file HTTP*
    index occ1, req, " "
    substr meth, req, 0, occ1
    inc occ1
    index occ2, req, " ", occ1
    len = occ2 - occ1
    substr url, req, occ1, len

    if meth == "GET" goto SERVE_GET

    srv.'debug'("unknown method:'", meth, "'\n")
DONE:
    if do_close goto close_it
    .return()
close_it:
    srv.'debug'("******* closed work\n")
    .local int i, n
    srv.'del_conn'(self)
    .return()

SERVE_GET:
    .local int is_cgi
    srv.'debug'("req url: ", url, "\n")
    (is_cgi, file_content, len) = check_cgi(url)
    if is_cgi goto SERVE_blob
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
    .local string doc_root
    doc_root = "."
    concat url, doc_root, url
    fp = open url, "<"
    unless fp goto SERVE_404
    len = stat url, .STAT_FILESIZE
    read file_content, fp, len
    close fp

SERVE_blob:
    # TODO make more subs
    # takes: file_content, len
    rep = "HTTP/1.1 200 OK"
    rep .= CRLF
    rep .= "Server: Parrot-httpd/0.2"
    rep .= CRLF
    rep .= "Content-Length: "
    temp = to_string (len)
    srv.'debug'("Content-Length: ", temp, "\n")
    rep .= temp
    rep .= CRLFCRLF
    rep .= file_content
    send ret, work, rep
    srv.'log'(200, ", ", url)
    goto DONE

SERVE_docroot:
    rep = 'HTTP/1.1 301 Moved Permamently'
    rep .= CRLF
    rep .= 'Location: /docs/html/index.html'
    rep .= CRLF
    rep .= 'Content-Length: '
    file_content = "Please go to <a href='docs/html/index.html'>Parrot Documentation</a>." 
    length len, file_content
    temp = to_string (len)
    concat rep, temp
    concat rep, CRLFCRLF
    concat rep, file_content
    send ret, work, rep
    srv.'log'(301, ", ", url, " - Redirect to 'docs/html/index.hmtl'")
    goto DONE

SERVE_favicon:
    url = urldecode( '/docs/resources/favicon.ico')
    goto SERVE_file

SERVE_404:
    $S0 = '404 Not found'
    $I0 = length $S0
    rep = 'HTTP/1.1 404 Not Found'
    rep .= CRLF
    rep .= 'Content-Length: '
    $S1 = $I0
    rep .= $S1
    rep .= CRLF
    rep .= 'Content-Type: text/plain'
    rep .= CRLFCRLF
    rep .= $S0
    srv.'log'(404, ", ", url)
    send ret, work, rep
    goto DONE
.end

# util functions
.sub to_string
    .param pmc args :slurpy

    .local string ret
    ret = sprintf "%d", args 
    .return( ret )
.end

# convert %xx to char 
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
    inc pos_in
    substr hex, in, pos_in, 2
    c_out = hex_to_int (hex)
    chr char_out, c_out
    inc pos_in

INC_IN:
    concat out, char_out
    inc pos_in
    goto START
END:
   .return( out )
.end

.sub hex_to_int
    .param pmc hex
    .return hex.'to_int'(16)
.end

# if file is *.pir or *.pbc run it as CGI
.sub check_cgi
    .param string url
    $I0 = index url, ".pir"
    if $I0 > 0 goto cgi_1
    $I0 = index url, ".pbc"
    if $I0 > 0 goto cgi_1
    .return (0, '', 0)
cgi_1:
    # file.pir?foo=1+bar=2
    $I0 = index url, '?'
    if $I0 == -1 goto no_query
    .local string file, query
    .local pmc query_hash
    file = substr url, 0, $I0
    inc $I0
    query = substr url, $I0
    # TODO split into a hash, then decode parts
    query_hash = make_query_hash(query)
    query = urldecode(query)
    goto have_query
no_query:
    file = url
    query = ''
    query_hash = new .Hash
have_query:
    # escape %
    file = urldecode(file)
    #self.'debug'("CGI: '", file, "' Q: '", query, "'\n")
    file = "cgi-pir/" . file
    # TODO stat the file
    load_bytecode file
    .local string result
    null $P0	# not yet
    # TODO catch ex
    result = 'cgi_main'($P0, query, query_hash)
    $I0 = length result
    .return (1, result, $I0)
.end

# split query at '+', make hash from foo=bar items
.sub make_query_hash
    .param string query		# the unescapced one
    .local pmc query_hash, items
    .local string kv, k, v
    query_hash = new .Hash
    items = split '+', query
    .local int i, n
    i = 0
    n = elements items
lp_items:
    kv = items[i]
    $I0 = index kv, "="
    if $I0 == -1 goto no_val
    k = substr kv, 0, $I0
    inc $I0
    v = substr kv, $I0
    v = urldecode(v)
    goto set_val
no_val:
    k = kv
    v = 1
set_val:
    k = urldecode(k)
    query_hash[k] = v

next_item:
    inc i
    if i < n goto lp_items
    .return (query_hash)
.end

.sub __init :method
    .param pmc sock
    setattribute self, 'socket', sock
.end

.sub 'socket' :method
    $P0 = getattribute self, 'socket'
    .return ($P0)
.end

.sub 'server' :method
    .param pmc sv      :optional
    .param int has_sv  :opt_flag
    if has_sv goto set_it
    sv = getattribute self, 'server'
    .return (sv)
set_it:
    setattribute self, 'server', sv
.end



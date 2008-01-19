#! perl
# Copyright (C) 2005-2007, The Perl Foundation.
# $Id$
use strict;
use warnings;

#use CGI;
#use CGI::Carp qw<fatalsToBrowser>;
#use Fcntl qw<:DEFAULT :flock>;
#use Storable qw<store_fd fd_retrieve freeze>;
#use Digest::MD5 qw<md5_hex>;
#use HTML::Template;
#use Algorithm::TokenBucket;
#use Time::Piece;
#use Time::Seconds;
use lib qw( lib );
use Parrot::Smoke::Server qw(
    require_compression_modules
    process_upload
    process_list
);


require_compression_modules();

use constant {
    MAX_SIZE                    => 2**20 * 3.0,             # MiB limit
    BASEDIR                     => "/tmp/parrot_smokes/",
    BASEHTTPDIR                 => "/",
};

$CGI::POST_MAX = MAX_SIZE;
chdir BASEDIR or die "Couldn't chdir into \"@{[ BASEDIR ]}\": $!\n";

$SIG{PIPE} = "IGNORE";

my $t = do { local $/; <DATA> };

my $CGI = new CGI;

if ( $CGI->url( -path => 1 ) =~ /html$/ ) {
    print $CGI->header;
    my $file = $CGI->url( -absolute => 1, -path => 1 );
    my $basehttpdir = BASEHTTPDIR;
    $file =~ s!^$basehttpdir!!;
    die "Invalid File"
        if $file =~ m!/|\.\.!;
    if ( -e BASEDIR . "/" . $file ) {
        open my $f, "<", BASEDIR . "/" . $file or die $!;
        print do { local $/; <$f> };
    }
}
else {
    if ( $CGI->param("upload") ) {
        eval { process_upload($CGI) };
    }
    else {
        eval { process_list($CGI, $t) };
    }
}

exit;

__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
  <title>Parrot Smoke Reports</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

  <style type="text/css">
    body {
      background-color: white;
      margin:           0;

      font-family: sans-serif;
      line-height: 1.3em;
      font-size:   95%;
    }

    h1, h2 {
      background-color: #313052;
      color:            white;
      padding:          10px;
    }

    th       { text-align: left; }
    .indent0 { padding-top:  30px; border-bottom: 2px solid #313052; }
    .indent1 { padding-top:  10px; border-bottom: 1px solid #313052; }
    .indent2 { padding-left: 40px; }
    .indent3 { padding-left: 80px; padding-bottom: 10px; }

    p, dl, pre, table { margin:      15px; }
    dt    { font-weight: bold; }
    dd+dt { margin-top:  1em;  }
    .leftsep  { padding-left: 10px;  }
    .num      { text-align:   right; }

    .details  { display: none; }
    .expander { color: blue; cursor: pointer; }  /* hack? */

    .tests_ok       { color: #050; }
    .tests_failed   { color: #500; }
    .tests_todo     { color: #030; }
    .tests_skipped  { color: #555; }
    .tests_unexpect { color: #550; }
  </style>

  <script type="text/javascript">//<![CDATA[[
    function toggle_visibility (id) {
      var elem     = document.getElementById("details_"  + id),
          expander = document.getElementById("expander_" + id);
      if(elem.className == "details") {
        elem.className = "";  /* hack? */
        expander.innerHTML = "&laquo;";
      } else {
        elem.className = "details";
        expander.innerHTML = "&raquo;";
      }
    }
  //]]></script>
</head>

<body>
  <h1>Parrot Smoke Reports</h1>

  <p>
    Here's a list of recently submitted <a
    href="http://www.parrotcode.org/">Parrot</a> smoke reports. These smokes are
    automatically generated and show how various runcores are functioning across
    a variety of platforms. Individual languages targetting parrot (e.g. tcl),
    are also available.
  </p>

  <p>
    Submitting your own smoke is easy,
  </p>

  <pre class="indent2">$ make smoke
</pre>

  <p>
    should suffice. To test the languages that are shipped with parrot, change
    to the languages directory and issue the same command.
  </p>

  <p>
    Note that old smoke reports are automatically deleted, so you may not want
    to link directly to a smoke.
  </p>

  <p>
    Note: Timezone is UTC.<br />
  </p>

  <table>
    <tmpl_loop name=branches>
      <tr><th colspan="11" class="indent0"><tmpl_var name=name></th></tr>
      <tmpl_loop name=categories>
        <tr><th colspan="12" class="indent1"><tmpl_var name=catname></th></tr>
        <tmpl_loop name=smokes>
          <tr>
            <td class="indent2">Parrot&nbsp;<tmpl_var name=VERSION></td>
            <td>
              <tmpl_if name=revision>
                r<tmpl_var name=revision>
              </tmpl_if>
            </td>
            <td class="leftsep"><tmpl_var name=timestamp></td>
            <td class="leftsep"><tmpl_var name=harness_args></td>
            <td class="leftsep num"><tmpl_var name=duration></td>
            <td class="leftsep num"><tmpl_var name=percentage>&nbsp;%&nbsp;ok</td>
        <tmpl_loop name=summary>
          <td class="leftsep num tests_total"><tmpl_var name=total>:</td>
          <td class="num tests_ok"><tmpl_var name=ok>,</td>
          <td class="num tests_failed"><tmpl_var name=failed>,</td>
          <td class="num tests_todo"><tmpl_var name=todo>,</td>
          <td class="num tests_skipped"><tmpl_var name=skipped>,</td>
          <td class="num tests_unexpect"><tmpl_var name=unexpect></td>
        </tmpl_loop>
        <td><span title="Details" class="expander" onclick="toggle_visibility('<tmpl_var name=id>')" id="expander_<tmpl_var name=id>">&raquo;</span></td>
        <td><a style="text-decoration: none" href="<tmpl_var name=link>" title="Full smoke report">&raquo;</a></td>
          </tr>
          <tr class="details" id="details_<tmpl_var name=id>">
            <td colspan="12" class="indent3">
              <tmpl_loop name=summary>
                <span class="tests_total"><tmpl_var name=total> test cases</span>:<br />
                <span class="tests_ok"><tmpl_var name=ok> ok</span>,
                <span class="tests_failed"><tmpl_var name=failed> failed</span>,
                <span class="tests_todo"><tmpl_var name=todo> todo</span>,<br />
                <span class="tests_skipped"><tmpl_var name=skipped> skipped</span> and
                <span class="tests_unexpect"><tmpl_var name=unexpect> unexpectedly succeeded</span>
              </tmpl_loop><br />
              <a href="<tmpl_var name=link>" title="Full smoke report">View full smoke report</a>
            </td>
          </tr>
        </tmpl_loop>
      </tmpl_loop>
    </tmpl_loop>
  </table>
</body>
</html>

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

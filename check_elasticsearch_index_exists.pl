#!/usr/bin/perl -T
# nagios: -epn
#
#  Author: Hari Sekhon
#  Date: 2015-03-21 16:53:17 +0000 (Sat, 21 Mar 2015)
#
#  https://github.com/harisekhon/nagios-plugins
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  vim:ts=4:sts=4:sw=4:et

$DESCRIPTION = "Nagios Plugin to check a given index exists in Elasticsearch

Tested on Elasticsearch 1.2.1, 1.4.0, 1.4.4, 1.4.5, 1.5.2, 1.6.2, 1.7.5, 2.0.2, 2.2.2, 2.3.3, 2.4.1, 5.0.0";

$VERSION = "0.1";

use strict;
use warnings;
BEGIN {
    use File::Basename;
    use lib dirname(__FILE__) . "/lib";
}
use HariSekhonUtils;
use HariSekhon::Elasticsearch;

$ua->agent("Hari Sekhon $progname version $main::VERSION");

%options = (
    %hostoptions,
    %elasticsearch_index,
);

get_options();

$host  = validate_host($host);
$port  = validate_port($port);
$index = validate_elasticsearch_index($index);

vlog2;
set_timeout();

$status = "UNKNOWN";

list_elasticsearch_indices();

sub handler ($) {
   my $response = shift;
   my $msg = "Elasticsearch index";
   if($response->code eq "200"){
       quit "OK", "$msg '$index' exists";
   } elsif($response->code eq "404"){
       quit "CRITICAL", "$msg '$index' does not exist";
   } else {
       quit "UNKNOWN", "unrecognized response code '" . $response->code . "' returned by Elasticsearch";
   }
}

curl "http://$host:$port/$index/", "Elasticsearch", undef, undef, \&handler, "HEAD";

$status = "UNKNOWN";
$msg = "code error - $nagios_plugins_support_msg";

quit $status, $msg;

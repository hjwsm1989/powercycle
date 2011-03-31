#!/usr/bin/perl

use strict;
use Expect;

# Pull out information
my $pduaddr = $ARGV[0];
my $port = $ARGV[1];

my $job = Expect->spawn("ssh -o StrictHostKeyChecking=no -o BatchMode=yes admin\@$pduaddr");
$job->log_stdout(1);
sleep 2;
$job->expect(30,
	     ["Entering server port"],
	     ["Permission denied" => sub {$!=1; die "SSH got permission denied"}]);
print $job "\r";
TOPLEVEL:
sleep 1;
$job->expect(30, [ -re, "RPC-[0-9]+\>" => sub {return;}],
    [ qr/\s+Enter Request.*/ => sub {print $job "1\r"; goto TOPLEVEL;} ]);
sleep 1;
print $job "reboot $port\r";
$job->expect(10,"Reboot Outlet");
sleep 1;
print $job "Y\r";
$job->expect(20, -re => "RPC-[0-9]+\>");
print $job "Exit\r";
sleep 1;
print $job "\cZ\r";
if ( $job->expect(10, -re => "close current connection") ) {
  print $job "x";
}
sleep 1;
$job->soft_close();

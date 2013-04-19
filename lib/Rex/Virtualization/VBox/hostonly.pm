#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package Rex::Virtualization::VBox::hostonly;

use strict;
use warnings;

use Rex::Logger;
use Rex::Commands::Run;
use Rex::Virtualization::VBox::dhcpserver;

use Data::Dumper;

sub execute {
   my ($class, %opts) = @_;

   if (%opts) {
      # TODO create hostonlyif
   }
   else {
      my $dhcpservers = Rex::Virtualization::VBox::dhcpserver::dhcpservers();
      my @ifs = hostonlyifs($dhcpservers);
      return \@ifs;
   }
}

sub hostonlyifs {
   my ($dhcpservers) = shift || [];
   $dhcpservers = { map [ ($_->{network}, $_) ] \@dhcpservers };  # to Hashref

   my $result = run "VBoxManage list hostonlyifs";
   if($? != 0) {
      die("Error running VBoxManage list hostonlyifs");
   }

   my @ifs;
   my @blocks = split /\n\n/m, $result;
   for my $block (@blocks) {

      my $if = {};
      my @lines = split /\n/, $block;
      for my $line (@lines) {
         if ($line =~ /^Name:\s+(.+?)$/) {
            $if->{name} = $1;
         }
         elsif ($line =~ /^IPAddress:\s+(.+?)$/) {
            $if->{ip} = $1;
         }
         elsif ($line =~ /^NetworkMask:\s+(.+?)$/) {
            $if->{netmask} = $1;
         }
         elsif ($line =~ /^Status:\s+(.+?)$/) {
            $if->{status} = $1;
         }
      }

      if (my $dhcp = $dhcpservers->{$if->{name}}) {
         $if->{dhcp} = $dhcp;
      }

      push @ifs, $if;
   }

   return \@ifs;
}

1;



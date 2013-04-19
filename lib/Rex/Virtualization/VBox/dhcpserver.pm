#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package Rex::Virtualization::VBox::dhcpserver;

use strict;
use warnings;

use Rex::Logger;
use Rex::Commands::Run;

use Data::Dumper;

sub execute {
   my ($class, %opts) = @_;

   if (%opts) {
      # TODO create dhcpserver
   }
   else {
      my @servers = dhcpservers($dhcpservers);
      return \@servers;
   }
}

sub dhcpservers {
   my $result = run "VBoxManage list dhcpservers";
   if($? != 0) {
      die("Error running VBoxManage list dhcpservers");
   }

   my @servers;
   my @blocks = split /\n\n/m, $result;
   for my $block (@blocks) {

      my $sv = {};
      my @lines = split /\n/, $block;
      for my $line (@lines) {
         if ($line =~ /^NetworkName:\s+HostInterfaceNetworking-(.+?)$/) {
            $sv->{network} = $1;
         }
         elsif ($line =~ /^IP:\s+(.+?)$/) {
            $sv->{ip} = $1;
         }
         elsif ($line =~ /^lowerIPAddress:\s+(.+?)$/) {
            $sv->{lower} = $1;
         }
         elsif ($line =~ /^upperIPAddress:\s+(.+?)$/) {
            $sv->{upper} = $1;
         }
      }

      push @servers, $sv;
   }

   return \@servers;
}

1;



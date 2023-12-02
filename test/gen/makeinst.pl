#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

use Verilog::Netlist;
use Verilog::Getopt;

# Option
my $input = "verilog.sv";
my $top = "dut";
my @incdir;
GetOptions(
	'input|i=s' => \$input,
  'top|t=s' => \$top,
  'incdir=s' => \@incdir
);

# Input process
my $tb = $top . "_test";
my @param;
my @iport;
my @oport;
my @ioport;

# Include directory process
my $opt = new Verilog::Getopt;
my @optlist;
foreach my $elm (@incdir) {
  push(@optlist, "+incdir+" . $elm);
}
$opt->parameter(@optlist);

# Read verilog
my $netlist = new Verilog::Netlist(options=> $opt, link_read_nonfatal=>1);
$netlist->read_file(filename=>$input);
$netlist->link();

# verilog module parse
&parse_param($netlist);
&parse_port($netlist);
#&debug_out();
&inst_dump();



sub parse_param {
  my ($netlist) = @_;

  foreach my $module ($netlist->modules_sorted) {
    foreach my $x ($module->nets_sorted) {
      # Parameter 
      if ( $x->decl_type eq "parameter" ) {
        push(@param, [$x->name, $x->value]);
        #printf("  parameter: %s = %s\n", $x->name, $x->value);
      } 
    }
  }
}

sub parse_port {
  my ($netlist) = @_;

  foreach my $module ($netlist->modules_sorted) {
    # Port
    foreach my $x ($module->ports_sorted) {
      my $dir  = $x->direction;
      my $name = $x->name;
      my $type = $x->type;
      #printf("name: %s\n", $x->net->name);
      #printf("  dir:  %s\n", $x->direction);
      #printf("  type: %s\n", $x->net->type);

      if ( $dir eq "in" ) {
        push(@iport, [$name, $type]);
      } elsif ( $dir eq "out" ) {
        push(@oport, [$name, $type]);
      } elsif ( $dir eq "inout" ) {
        push(@ioport, [$name, $type]);
      }
    }
  }
}

sub inst_dump {
  # dut instanciation and connection
  printf("//***** DUT instanciation\n");
  my @list = (@iport, @oport, @ioport);
  printf("%s #(\n", $top);
  #foreach my $elm (@param) {
  for (my $i = 0; $i <= $#param; $i++) {
    my $name = $param[$i][0];
    if ( $i == $#param ) {
      printf("  .%s ( %s )\n", $name, $name);
    } else {
      printf("  .%s ( %s ),\n", $name, $name);
    }
  }
  printf(") %s0 (\n", $top);
  for (my $i = 0; $i <= $#list; $i++ ) {
    my $name = $list[$i][0];
    if ( $i == $#list ) {
      printf("  .%s ( )\n", $name);
    } else {
      printf("  .%s ( ),\n", $name);
    }
  }
  printf(");\n\n");
}

sub debug_out {
  printf("<Parameters>\n");
  foreach my $elm (@param) {
    printf("  Name  : %s\n", @$elm[0]);
    printf("        : %s\n", @$elm[1]);
  }

  printf("<Input Ports>\n");
  foreach my $elm (@iport) {
    printf("  Name  : %s\n", @$elm[0]);
    printf("        : %s\n", @$elm[1]);
  }

  printf("<Output Ports>\n");
  foreach my $elm (@oport) {
    printf("  Name  : %s\n", @$elm[0]);
    printf("        : %s\n", @$elm[1]);
  }

  printf("<Inout Ports>\n");
  foreach my $elm (@ioport) {
    printf("  Name  : %s\n", @$elm[0]);
    printf("        : %s\n", @$elm[1]);
  }
}


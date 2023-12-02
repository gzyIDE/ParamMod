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
&tb_dump();



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

sub tb_dump {
  printf("module %s;\n", $tb);

  # parameter dump
  foreach my $elm (@param) {
    printf("parameter %s = %s;\n", @$elm[0], @$elm[1]);
  }
  printf("\n");

  # input port decleration
  printf("//***** input port connection\n");
  foreach my $elm (@iport) {
    my $name = @$elm[0];
    my $type = @$elm[1];
    if ( $type =~ /^wire/ ) {
      $type =~ s/^wire/logic/;
      printf("%s %s;\n", $type, $name);
    } elsif ( $type =~ /^logic/ ) {
      printf("%s %s;\n", $type, $name);
    } elsif ( $type =~ /^port/ ) {
      printf("logic %s;\n", $name);
    } elsif ( $type =~ /^\[/ ) {
      printf("logic %s %s;\n", $type, $name);
    } else {
      printf("%s %s;\n", $type, $name);
    }
  }
  printf("\n");

  # output port decleration
  printf("//***** output port connection\n");
  foreach my $elm (@oport) {
    my $name = @$elm[0];
    my $type = @$elm[1];
    if ( $type =~ /^wire/ ) {
      printf("%s %s;\n", $type, $name);
    } elsif ( $type =~ /^reg/ ) {
      $type =~ s/^reg/wire/;
      printf("%s %s;\n", $type, $name);
    } elsif ( $type =~ /^logic/ ) {
      $type =~ s/^logic/wire/;
      printf("%s %s;\n", $type, $name);
    } elsif ( $type =~ /^port/ ) {
      printf("wire %s;\n", $name);
    } elsif ( $type =~ /^\[/ ) {
      printf("wire %s %s;\n", $type, $name);
    } else {
      printf("wire %s %s;\n", $type, $name);
    }
  }
  printf("\n");

  # inout port decleration
  printf("//***** inout port connection\n");
  foreach my $elm (@ioport) {
    my $name = @$elm[0];
    my $type = @$elm[1];
    if ( $type =~ /^wire/ ) {
      $type =~ s/^wire/tri/;
      printf("%s %s;\n", $type, $name);
    } elsif ( $type =~ /^reg/ ) {
      $type =~ s/^reg/tri/;
      printf("%s %s;\n", $type, $name);
    } elsif ( $type =~ /^logic/ ) {
      $type =~ s/^logic/tri/;
      printf("%s %s;\n", $type, $name);
    } elsif ( $type =~ /^port/ ) {
      printf("tri %s;\n", $name);
    } elsif ( $type =~ /^\[/ ) {
      printf("tri %s %s;\n", $type, $name);
    } else {
      printf("tri %s %s;\n", $type, $name);
    }
  }
  printf("\n");

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
      printf("  .%s ( %s )\n", $name, $name);
    } else {
      printf("  .%s ( %s ),\n", $name, $name);
    }
  }
  printf(");\n\n");

  # input port intialization
  printf("//***** Input initialize\n");
  printf("initial begin\n");
  foreach my $elm (@iport) {
    my $name = @$elm[0];
    printf("  %s <= 'h0;\n", $name);
  }
  printf("end\n\n");

  printf("endmodule\n");
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


#!/usr/bin/env perl

BEGIN {
   die "The PERCONA_TOOLKIT_BRANCH environment variable is not set.\n"
      unless $ENV{PERCONA_TOOLKIT_BRANCH} && -d $ENV{PERCONA_TOOLKIT_BRANCH};
   unshift @INC, "$ENV{PERCONA_TOOLKIT_BRANCH}/lib";
};

use strict;
use warnings FATAL => 'all';
use English qw(-no_match_vars);
use Test::More tests => 1;

use PerconaTest;
use Sandbox;
require "$trunk/bin/pt-table-sync";

my $q  = new Quoter();
my $tp = new TableParser(Quoter => $q);
my $tn = new TableNibbler(Quoter => $q, TableParser => $tp);

my $sample = "t/pt-table-sync/samples";

sub test_diff_where {
   my (%args) = @_;

   my $ddl        = load_file($args{file});
   my $tbl_struct = $tp->parse($ddl);
   my $where      = pt_table_sync::diff_where(
      tbl_struct   => $tbl_struct,
      diff         => $args{diff},
      TableNibbler => $tn,
   );
   is(
      $where,
      $args{where},
      $args{name},
   );
}

test_diff_where(
   name => "Single int col",
   file => "$sample/simple-tbl-ddl.sql",
   diff => {
      chunk          => '3',
      chunk_index    => 'PRIMARY',
      cnt_diff       => '-1',
      crc_diff       => '1',
      lower_boundary => '7',
      master_cnt     => '3',
      master_crc     => '1ddd6c71',
      table          => 'test.mt1',
      this_cnt       => '2',
      this_crc       => '4a57d814',
      upper_boundary => '9'
   },
   where => "((`id` >= 7)) AND ((`id` <= 9))",
);

# #############################################################################
# Done.
# #############################################################################
exit;

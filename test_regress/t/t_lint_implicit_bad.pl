#!/usr/bin/perl
if (!$::Driver) { use FindBin; exec("$FindBin::Bin/bootstrap.pl", @ARGV, $0); die; }
# DESCRIPTION: Verilator: Verilog Test driver/expect definition
#
# Copyright 2008 by Wilson Snyder. This program is free software; you can
# redistribute it and/or modify it under the terms of either the GNU
# Lesser General Public License Version 3 or the Perl Artistic License
# Version 2.0.

scenarios(vlt_all => 1);

top_filename("t/t_lint_implicit.v");

compile(
    v_flags2 => ["--lint-only -Wwarn-IMPLICIT"],
    fails => 1,
    expect_filename => $Self->{golden_filename},
    );

ok(1);
1;

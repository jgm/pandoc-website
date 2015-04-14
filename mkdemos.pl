#!/usr/bin/perl -w
# first argument is input filename - a demo template.
# second argument is output filename.

my $infile=$ARGV[0];
my $outfile=$ARGV[1];
my $dir=$ARGV[2];

open( IN, "< $infile" );
open( OUT, "> $outfile" );

chdir $dir;

while (<IN>) {

    my $line = $_;
    my $firstchar = substr ($line,0,1);
    if ( $firstchar eq '@' ) {
        my $command = substr ($line,4);
        my $commandExec = $command;
        $commandExec =~ s/[#].*$//g;  # strip off comments
        $commandExec =~ s/@@//g;   # strip off hotlink markers
        print STDERR "\n$commandExec";
        system("$commandExec") == 0 or
            die "System command $commandExec failed!";
        $line = $command;
        $line =~ s/@@([^@]*)@@/<a href="demo\/$1">$1<\/a>/g;
        $line =~ s/demo\/http/http/g;
        $line =~ s/^(.*)$/    <pre><code>$1<\/code><\/pre>/g;
    }
    print OUT $line;

}

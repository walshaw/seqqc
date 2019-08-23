#!/usr/bin/perl

use strict;
use warnings;
use autodie;
use Carp;

use List::Util qw( first );

my @headings;
my %data;

my $in_dir = shift || q{.};

my $ext    = shift || q{.stdout};
my $ext_qm = quotemeta $ext;

opendir(my $dh, $in_dir);

my @in_files = grep { m{ $ext_qm \z }xms } readdir $dh;

for my $file (@in_files) {

    chomp $file;
    (my $label = $file) =~ s{ $ext_qm \z }{}xms;

    open my $fh, '<', qq{$in_dir/$file};

    while (defined (my $line = <$fh>)) {

        chomp $line;
        next if $line !~ m{ \S }xms;
        my ($name, $value) = split m{ [:] }xms, $line;
        $data{$label}{$name} = $value;

        push @headings, $name if !defined first { $_ eq $name } @headings;

    }

    close $fh;

}

closedir $dh;

my @file_labels = (sort keys %data);

print join(qq{\t}, q{sequence file}, @headings), qq{\n};

for my $label (@file_labels) {

    my $href = $data{$label};
    my %row  = %{$href};
    my @data_row = @row{@headings};
    print join(qq{\t}, $label, @data_row), qq{\n};

}


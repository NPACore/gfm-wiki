#!/usr/bin/env perl
use v5.36;
use File::Glob ':bsd_glob';
use Data::Printer;
my @md = bsd_glob("*.md");
use File::Slurp 'read_file';
my %headers;
my %links;

my $SHOW_ORPHAN=0;

# translate header (or file name) to github anrchor
# will check if file exists if given a second argument (assumed to be file liked from)
sub linkify {
    $_ = shift;
    return if ! defined;
    my $check_file=shift;
    if($check_file and ! -f $_ ){
        say "WARNING: $check_file: link to '$_' does not exist";
    }
    s/\.md$//;
    s/ /-/g;
    s/[^-a-zA-Z0-9]/_/g;
    return lc($_);
}

my $intra_regexp = qr/ \[ [^\]]+? \] \(  \#  (?<header>[^)]+?) \) /xm;
# NB. bad matches on .md.md
my $inter_regexp = qr/ \[ [^\]]+? \] \( (?<page>[^\)]+?\.md) \#? (?<header>[^)]+?)? \) /xm;

#say linkify($+{page}) if '[Intake Form](intake-form.md)' =~ m/$inter_regexp/;
#exit;

# build database of headers:
#   $headers{users.md}->{flywheel} == 1
# and links (from page, to page, header)
#   $header{users.md}->{serives}->{undef}     # link to file only
#   $header{users.md}->{serives}->{education} # link to file and header
for my $f (@md){
    my $contents = read_file($f);

    # pull out e.g. '## markdown header'
    my @file_headers;
    push @file_headers, linkify($1)  while $contents =~ m/^\#+ (.+)/gm;
    ++${$headers{$f}}{$_} for @file_headers;

    # check file name isn't crazy and top level header matches file
    say "WARNING: filename '$f' does not conform!" if $f ne linkify($f) . ".md";
    say "WANRING: $f: first header should be match filename"
        if ($#file_headers < 0 or $file_headers[0].".md" ne $f ) and
        $f !~ /readme.md$/;

    ## Links

    # [link](#header)
    push @{$links{$f}{linkify($f)}}, $+{header} while $contents =~ /${intra_regexp}/g;

    # [link](file.md#header)
    # some links (esp to other github docs) end in .md. exclude those
    while($contents =~ /${inter_regexp}/g){
        # TODO: maybe exclude m,:/, instead of specific protocol
        push @{$links{$f}{linkify($+{page}, $f)}}, linkify($+{header}) unless $+{page} =~ /^http/;
    }
}

# check headers only given onces. and reset counts to reuse for linking
my %all_headers;
for my $f (keys %headers){
    for my $h (keys %{$headers{$f}}){
        say "$f#$h is repeated!" if $headers{$f}->{$h} != 1;

        # put file in all headers for check
        # TODO: could do this when reading files
        # maybe more ergonomic here, but out of place
        push @{$all_headers{$h}}, $f;

        # reset to zero for link counting
        # not a huge fan of mutatating a datastructure,
        #  and to represent 2 separate things
        $headers{$f}->{$h} = 0
    }
}

# is the same header in 2 places actually a problem?
# only for agenda export to pdf
for my $h (keys %all_headers){
    my @files_with_h = @{$all_headers{$h}};
    say "WARNING: $h shared by files: @files_with_h"
        if $#files_with_h>0;
}

# count all links to headers. warn when link doesn't exist
#say "all links:"; p(%links);
for my $from_file (keys %links){
    my %file_links = %{$links{$from_file}};
    for my $to_file (keys %file_links) {
        #say "$from_file->$to_file links to";
        #p($file_links{$to_file});
        for my $h (@{$file_links{$to_file}}) {
            if(! defined $h){
                say "$from_file links to '$to_file'. $to_file.md#$to_file does not exit"
                    if ! exists $headers{$to_file.".md"}->{$to_file};
                next;
            }
            say "$from_file: $to_file.md#$h link does not exist"
                if ! exists $headers{$to_file.".md"}->{$h};
            ++$headers{$to_file.".md"}->{$h};
        }
    }
}

# check everything has a link 
for my $f (keys %headers){
    for my $h (keys %{$headers{$f}}){
        say "ORPHAN: $f#$h" if $headers{$f}->{$h} < 1 and $SHOW_ORPHAN;
    }
}


# TODO:
# check all links. file should exist or link should contain ':'
# check github issues
# link to dot for graphviz map

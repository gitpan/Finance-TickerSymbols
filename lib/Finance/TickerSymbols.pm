package Finance::TickerSymbols;

use strict;
use warnings;
use bytes ;

use Carp ;

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT = qw'symbols_list
                 industries_list
                 industry_list
                ' ;

our $VERSION = '1.01';

our $long;

my %inds ;

sub _carp(@) { carp "@_\n" ; ()}

sub _http2name($){
    my  $n = shift ;
    for($n) {
        s/^\s+//s ;
        s/\s+$//s ;
        s/\s+/ /sg ;
        s/\&amp\;/&/g ;
    }
    $n
}

my  $_brws ;
sub  _brws(@) {
    use LWP ;
    $_brws ||= new LWP::UserAgent() ;
    my $res = $_brws->get(@_) ;
    return $res -> content() if $res -> is_success() ;
    $res = $_brws->get(@_) ;
    return $res -> content() if $res -> is_success() ;
    return _carp "download (@_):", $res->status_line() ;
}

sub _gimi($$;@) {
    my $prs = shift ;

    local $_ = _brws(@_) or return ;

    if ($prs eq 'nas' and $long) {

        my @ret ;
        while (
          m/\"([^\"]+)\"\s*,\s*
             \"(\w+)\"  \s*,\s*
             .*?
             \"\$[\d\,\.]+\"
           /xgm ) { push @ret, "$2:$1"}
        return @ret
    }
    elsif ($prs eq 'nas') {

        return
          m/\"[^\"]+\" \s*,\s*
            \"(\w+)\"  \s*,\s*
            .*?
            \"\$[\d\,\.]+\"
           /xgm ;
    }
    elsif ($prs eq 'ind' and $long) {
        my @ret ;
        while ( m{
                   http\://biz\.yahoo\.com/ic/\d+/\d+\.html\"\>([^\<]+).*?
                   http\://finance\.yahoo\.com/q\?s\=([\w\.]+)
             }xgs ) {push @ret, $2 . ':'. _http2name $1 }
        return @ret
    }
    elsif ($prs eq 'ind') {
        return
          m{http\://finance\.yahoo\.com/q\?s\=([\w\.]+)\s*\"}g
    }
    elsif ($prs eq 'inds') {

        while ( m{http\://biz\.yahoo\.com/ic/(\d+)\.html\s*\"\s*\>\s*([^\<]+)}sg ) {
            my ($d, $n) = ($1, $2) ;
            $inds{ _http2name $n } = $d ;
        }
        return keys %inds;
    }
}

sub symbols_list($) {

    my $wt = shift || '?';
    $wt eq 'nasdaq' and return _gimi nas => 'http://www.nasdaq.com//asp/symbols.asp?exchange=Q&start=0' ;
    $wt eq 'amex'   and return _gimi nas => 'http://www.nasdaq.com//asp/symbols.asp?exchange=1&start=0' ;
    $wt eq 'nyse'   and return _gimi nas => 'http://www.nasdaq.com//asp/symbols.asp?exchange=N&start=0' ;
    my @all = qw/nasdaq amex nyse/ ;
    $wt eq 'all'    and return map { symbols_list ($_) } @all ;

    return _carp "bad parameter: should be " . join '|', @all, 'all' ;
}

sub industries_list { _gimi inds => 'http://biz.yahoo.com/ic/ind_index.html' }

sub industry_list($) {
    %inds or industries_list() ;
    my $name = shift ;
    my $n = $inds{$name} or return _carp "'$name' is not recognized" ;

    my $p = 'pub' ; # shift || ''; $p = 'pub' unless $p eq 'prv' or $p eq 'all' ;
                    # ?? TODO ??
                    # support Private/Foreign ? what for?
    _gimi ind => "http://biz.yahoo.com/ic/${n}_cl_${p}.html"
}

1;

__END__

=head1 NAME

Finance::TickerSymbols - Perl extension for getting symbols lists
                         from web resources

=head1 SYNOPSIS

  use Finance::TickerSymbols;
  for my $symbol ( symbols_list('all') ) {

     # do something with this $symbol
  }

  for my $industry ( industries_list()) {

     for my $symbol ( industry_list( $industry ) ) {

         # do something with $symbol and $industry

     }
  }

=head1 DESCRIPTION

get lists of ticker symbols. this list can be used for market queries.

=over 2

=item symbols_list

symbols_list( 'nasdaq' | 'amex' | 'nyse' | 'all' )
returns the apropriate array of symbols.

=item industries_list

industries_list()
returns array of industries names.

=item industry_list

industry_list( $industry_name )
returns array of symbols related with $industry_name

=item $Finance::TickerSymbols::long

setting $Finance::TickerSymbols::long to non-false would attach company name to each symbol
  (as "ARTNA:Basin Water, Inc." compare to "ARTNA")

=back

=head2 TODO

=over 2

=item more markets

=back

=head1 SEE ALSO

  LWP::Simple
  http://quotes.nasdaq.com
  http://biz.yahoo.com/ic
  Finance::*

=head1 AUTHOR

Josef Ezra, E<lt>jezra@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Josef Ezra

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=head2 NOTES

- the returned data depends upon availability and format of
  external web sites. Needless to say, it is not guaranteed.


=head1 BUGS, REQUESTS, NICE IMPLEMENTATIONS, ETC.

Please email me about any of the above. I'll be more then happy to share
interesting implementation of this module.

=cut

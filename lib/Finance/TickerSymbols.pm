package Finance::TickerSymbols;

use strict;
use warnings;
use bytes ;

use Carp ;

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT = 'symbols_list' ;

our $VERSION = '0.02';

use LWP::Simple ;

sub _nasdaq_format($) {
    my $url = shift ;
    local $_ = get ( $url ) || get( $url ) ;
    unless($_) {
        carp "couldn't read $url" ;
        return () ;
    }

    /\"[^\"]+\" \s*,\s*
     \"(\w+)\"  \s*,\s*
     \"\$\d
     /xgm ;
}

sub symbols_list {

    for (@_) {
        /nasdaq/ix and return _nasdaq_format
          'http://www.nasdaq.com//asp/symbols.asp?exchange=Q&start=0' ;

        /amex  /ix and return _nasdaq_format
          'http://www.nasdaq.com//asp/symbols.asp?exchange=1&start=0' ;

        /nyse  /ix and return _nasdaq_format
          'http://www.nasdaq.com//asp/symbols.asp?exchange=N&start=0' ;

    }

    carp "bad parameter: should be nasdaq|amex|nyse" ;
}

1;

__END__

=head1 NAME

Finance::TickerSymbols - Perl extension for getting symbols lists
                         from web resources

=head1 SYNOPSIS

  use Finance::TickerSymbols;
  for my $symbol ( symbols_list('nasdaq') ) {

     # do something with this symbol
  }

=head1 DESCRIPTION

export the function symbols_list

=over 2

=item symbols_list

symbols_list( 'nasdaq' | 'amex' | 'nyse' )
returns the apropriate array of symbols.

=back

=head2 TODO

more markets, I guess

=head1 SEE ALSO

  LWP::Simple
  http://quotes.nasdaq.com
  Finance::*

=head1 AUTHOR

Josef Ezra, E<lt>jezra@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Josef Ezra

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=head2 NOTES

- currently (version 0.01) only supports 'nasdaq', 'amex', and 'nyse'
- the returned data depends upon availability and format of
  external web sites. Needless to say, it is not guaranteed .


=head1 BUGS, REQUESTS, NICE IMPLEMENTATIONS, ETC.

Please email me about any of the above. I'll be more then happy to share
interesting implementation of this module.

=cut



use lib '../lib' ;
use lib 'lib' ;
use Finance::TickerSymbols ;

local $, = "\n" ;

return warn "usage:\n $0 nasdaq|nyse|amex\n" unless @ARGV ;

for my $market (@ARGV) {
    print ":: $market ::", symbols_list( $market ), '' ;
}




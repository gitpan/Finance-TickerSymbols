
use ExtUtils::MakeMaker;

WriteMakefile

  ( NAME              => 'Finance::TickerSymbols',
    VERSION_FROM      => 'lib/Finance/TickerSymbols.pm',
    PREREQ_PM         => { LWP::Simple => 1.00
                         },
    ($] >= 5.005 ?
     (ABSTRACT_FROM  => 'lib/Finance/TickerSymbols.pm',
      AUTHOR         => 'Josef Ezra <jezra@cpan.org>'
     ) : ()),
  );

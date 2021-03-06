use 5.026002;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'Karma',
    VERSION_FROM      => 'lib/Karma.pm', # finds $VERSION, requires EU::MM from perl >= 5.5
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ABSTRACT_FROM     => 'lib/Karma.pm', # retrieve abstract from module
    AUTHOR            => 'Nicholas Killeen<nicholas.killeen2@gmail.com>',
);

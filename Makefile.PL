use strict;
use warnings;
use inc::Module::Install;

name('Test-WWW-Selenium-Catalyst');
author('Jonathan Rockway <jrockway@cpan.org>');
version_from('lib/Test/WWW/Selenium/Catalyst.pm');
abstract_from('lib/Test/WWW/Selenium/Catalyst.pm');
license('Perl');
include('ExtUtils::AutoInstall');
requires(
	 'Alien::SeleniumRC' => 0,
	 'Catalyst::Runtime' => 5.7001,
	 'Test::WWW::Selenium' => 0,
	 'Test::More' => 0,
	 'Catalyst::Utils' => 0,
	);

# Old vers of CPAN dont set the env var. safer to assume we are running than
# ask about deps twice
my $under_cpan = $ENV{PERL5_CPANPLUS_IS_RUNNING} || 
                 $ENV{PERL5_CPAN_IS_RUNNING} || 
                 do { require CPAN; $CPAN::VERSION < 1.92 };
$under_cpan or auto_install();
WriteAll();

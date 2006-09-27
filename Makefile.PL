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
auto_install();
WriteAll();

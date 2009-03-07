use strict;
use warnings;
use inc::Module::Install;

name          'Test-WWW-Selenium-Catalyst';
perl_version  '5.008000';
all_from      'lib/Test/WWW/Selenium/Catalyst.pm';
license       'Perl';
requires(
	 'Alien::SeleniumRC' => 0,
	 'Catalyst::Runtime' => 5.7001,
	 'Test::WWW::Selenium' => 0,
	 'Test::More' => 0,
	 'Catalyst::Utils' => 0,
);

test_requires 'IPC::Cmd' => '0.42';

WriteAll();

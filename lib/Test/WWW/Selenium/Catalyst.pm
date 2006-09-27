package Test::WWW::Selenium::Catalyst;

use warnings;
use strict;
use Carp;
use Alien::SeleniumRC;
use Test::WWW::Selenium;
use Test::More;
use Catalyst::Utils;

BEGIN { $ENV{CATALYST_ENGINE} ||= 'HTTP'; }

local $SIG{CHLD} = 'IGNORE';

my $DEBUG = $ENV{CATALYST_DEBUG};
my $app; # app name (MyApp)
my $sel_pid; # pid of selenium server
my $app_pid; # pid of myapp server

=head1 NAME

Test::WWW::Selenium::Catalyst - Test your Catalyst application with Selenium

=cut

our $VERSION = '0.00_01';

=head1 DEVELOPER RELEASE

This is a developer release.  It's working for me in production, but
it depends on a Java application (SeleniumRC), which can be
unreliable.  On my Debian system, I had to put C<firefox-bin> in my
path, and add C</usr/lib/firefox> to C<LD_LIBRARY_PATH>.  Every distro
and OS is different, so I'd like some feedback on how this works on
your system.  I would like to find a clean solution that lets this
module "Just Work" for everyone, but I have a feeling that it's going
to look more like C<if(gentoo){ ... } elsif (debian) { ... }> and so
on.  I can live with that, but I need your help to get to that stage!

Please report any problems to RT, the Catalyst mailing list, or the
#catalyst IRC channel on L<irc.perl.org>.  Thanks!

=head1 SYNOPSIS

    use Test::WWW::Selenium::Catalyst 'MyApp';
    use Test::More tests => 2;

    my $sel = Test::WWW::Selenium::Catalyst->start; 
    $sel->open_ok('/');
    $sel->is_text_present_ok('Welcome to MyApp');

This module starts the SeleniumRC server and your Catalyst app so that
you can test it with SeleniumRC.  Once you've called
C<Test::WWW::Selenium::Catalyst->start>, everything is just like
L<Test::WWW::Selenium|Test::WWW:Selenium>.

=head1 FUNCTIONS

=head2 start

Starts the Selenium and Catalyst servers, and returns a
pre-initialized, ready-to-use Test::WWW::Selenium object.

[NOTE] The selenium server is actually started when you C<use> this
module, and it's killed when your test exits.

=head2 sel_pid

Returns the process ID of the Selenium Server.

=head2 app_pid

Returns the process ID of the Catalyst server.

=cut


sub _start_server {
    # fork off a selenium server
    my $pid;
    if(0 == ($pid = fork())){
	local $SIG{TERM} = sub {
	    diag("Selenium server $$ going down (TERM)");
	    exit 0;
	};
	
	chdir '/';
	
	if(!$DEBUG){
	    close *STDERR;
	    close *STDOUT;
	    #close *STDIN;
	}
	
	diag("Selenium running in $$") if $DEBUG;
        Alien::SeleniumRC->start()
	    or croak "Can't start Selenium server";
	diag("Selenium server $$ going down") if $DEBUG;
	exit 1;
    }
    $sel_pid = $pid;
}

sub sel_pid {
    return $sel_pid;
}

sub app_pid {
    return $app_pid;
}

sub import {
    my ($class, $appname) = @_;
    croak q{Specify your app's name} if !$appname;
    $app = $appname;
    
    my $d = $ENV{Catalyst::Utils::class2env($appname). "_DEBUG"}; # MYAPP_DEBUG 
    if(defined $d && $d){
	$DEBUG = 1;
    }
    elsif(defined $d && $d == 0){
	$DEBUG = 0;
    }
    # if it's something else, leave the CATALYST_DEBUG setting in tact
    
    _start_server() or croak "Couldn't start selenium server";
    return 1;
}

sub start {
    my $class = shift;
    my $args  = shift || {};
    
    # start a Catalyst MyApp server
    eval("use $app");
    croak "Couldn't load $app: $@" if $@;
    
    my $pid;
    if(0 == ($pid = fork())){
	local $SIG{TERM} = sub {
	    diag("Catalyst server $$ going down (TERM)") if $DEBUG;
	    exit 0;
	};
	diag("Catalyst server running in $$") if $DEBUG;
	$app->run('3000', 'localhost');
	exit 1;
    }
    $app_pid = $pid;
    
    my $tries = 5;
    my $error;
    my $sel;
    while(!$sel && $tries--){ 
	sleep 1;
	diag("Waiting for selenium server to start")
	  if $DEBUG;
	
	eval {
	    $sel = Test::WWW::Selenium->
	      new(host => 'localhost',
		  port => 4444,
		  browser => $args->{browser} || '*firefox',
		  browser_url => 'http://localhost:3000/'
		 );
	};
	$error = $@;
    }
    
    eval { $sel->start }
      or croak "Can't start selenium: $@ (previous error: $error)";
    
    return $sel;
}

END {
    if($sel_pid){
	diag("Killing Selenium Server $sel_pid") if $DEBUG;
	kill 15, $sel_pid or diag "Killing Selenium: $!";
	undef $sel_pid;
    }
    if($app_pid){
	diag("Killing catalyst server $app_pid") if $DEBUG;
	kill 15, $app_pid or diag "Killing MyApp: $!";
	undef $app_pid;
    }
    diag("Waiting for children to die") if $DEBUG;
    waitpid $sel_pid, 0 if $sel_pid;
    waitpid $app_pid, 0 if $app_pid;
}


=head1 ENVIRONMENT

Debugging messages are shown if C<CATALYST_DEBUG> or C<MYAPP_DEBUG>
are set.  C<MYAPP> is the name of your application, uppercased.  (This
is the same syntax as Catalyst itself.)

=head1 DIAGNOSTICS

=head2 Specify your app's name

You need to pass your Catalyst app's name as the argument to the use
statement:

    use Test::WWW::Selenium::Catalyst 'MyApp'

C<MyApp> is the name of your Catalyst app.

=head1 SEE ALSO

=over 4 

=item * 

Selenium website: L<http://www.openqa.org/>

=item * 

Description of what you can do with the C<$sel> object: L<Test::WWW::Selenium>

=item * 

If you don't need a real web browser: L<Test::WWW::Mechanize::Catalyst>

=back

=head1 AUTHOR

Jonathan Rockway, C<< <jrockway at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-test-www-selenium-catalyst at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Test-WWW-Selenium-Catalyst>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Test::WWW::Selenium::Catalyst

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Test-WWW-Selenium-Catalyst>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Test-WWW-Selenium-Catalyst>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test-WWW-Selenium-Catalyst>

=item * Search CPAN

L<http://search.cpan.org/dist/Test-WWW-Selenium-Catalyst>

=back

=head1 ACKNOWLEDGEMENTS

Thanks for mst for getting on my case to actually write this thing :)

=head1 COPYRIGHT & LICENSE

Copyright 2006 Jonathan Rockway, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Test::WWW::Selenium::Catalyst

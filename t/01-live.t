#!/usr/bin/perl
# 01-live.t 
# Copyright (c) 2006 Jonathan Rockway <jrockway@cpan.org>

use Test::More tests => 79;
use FindBin;
use lib "$FindBin::Bin/lib";
use Test::WWW::Selenium::Catalyst 'TestApp';

diag("You need to have firefox-bin in your path for this to work!");

my $sel = Test::WWW::Selenium::Catalyst->start({browser => '*firefox'});

$sel->open_ok('/');
$sel->text_is("link=Click here", "Click here");
$sel->click_ok("link=Click here");
$sel->wait_for_page_to_load_ok("30000", 'wait');
for my $i (1..10){
    $sel->open_ok("/words/$i");
    $sel->is_text_present_ok(
	qq{Here you'll find all things "words" printed $i time(s)!});
    
    for my $j (1..$i){
	$sel->is_text_present_ok("$j: foo bar baz bat qux quux");
    }
}

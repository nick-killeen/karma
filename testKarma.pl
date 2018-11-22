# Karma/testKarma.pl
# Nicholas Killeen,
# 12th July 2018.
# Autotests for the Karma project.

use warnings;
use strict;

use Try::Tiny;
use Data::Dumper;

use Karma;


sub testKarma {
	# Testing various default behaviour with a simple indexGenerator.
	if (1) {
		my $k1 = Karma->new(
			allowDuplicateActIds => 0,
			indexGenerator       => sub {0},
			recycle              => "fair"
			);
		
		my $k1_save1 = $k1->save();
		for (0..1) {
			($k1->relax()     == 0) or die;
			($k1->length()    == 0) or die;
			(!defined $k1->peek() ) or die;
			(!defined $k1->prime()) or die;
			(!defined $k1->cycle()) or die;
			($k1->push(8, 3)  == 1) or die;
			($k1->push(8, 4)  == 0) or die;
			($k1->lifetime(8) == 3) or die;
			($k1->lifetime(9) == 0) or die;
			($k1->length()    == 1) or die;
			($k1->push(9, 1)  == 1) or die;
			($k1->lifetime(9) == 1) or die;
			$k1->load(string => $k1_save1) unless ($_);
		}
		
		my $k1_save2 = $k1->save();
		for (0..1) {
			($k1->length()    == 2) or die;
			($k1->relax()     == 0) or die;
			($k1->prime()     == 8) or die;
			($k1->relax()     == 1) or die;
			($k1->relax()     == 0) or die;
			($k1->peek()      == 8) or die;
			($k1->cycle()     == 8) or die;
			($k1->lifetime(8) == 2) or die;
			($k1->length()    == 2) or die;
			($k1->cycle()     == 9) or die;
			($k1->relax()     == 0) or die;			
			($k1->length()    == 1) or die;
			($k1->cycle()     == 8) or die;
			($k1->lifetime(8) == 1) or die;
			($k1->length()    == 1) or die;
			($k1->cycle()     == 8) or die;
			($k1->lifetime(8) == 0) or die;
			($k1->length()    == 0) or die;
			($k1->relax()     == 0) or die;
			(!defined $k1->cycle()) or die;
			$k1->load(string => $k1_save2) unless ($_);
		}
		
		my $k2 = Karma->new(
			allowDuplicateActIds => 0,
			indexGenerator       => sub {0},
			recycle              => "fair"
			);
		
		($k1->push(0, 2)  == 1) or die;
		($k1->push(1, 3)  == 1) or die;
		($k1->push(2, 4)  == 1) or die;
		($k1->peek()      == 0) or die;
		($k1->remove(1)   == 1) or die;
		($k1->relax()     == 1) or die;
		($k1->peek()      == 0) or die;
		($k1->remove(0)   == 1) or die;
		($k1->relax()     == 0) or die;
		
	}
	
	# Testing various default behaviour with a proper indexGenerator spoof.
	if (1) {
		my @indexes = ();
		my $k1 = Karma->new(
			allowDuplicateActIds => 0,
			indexGenerator       => sub {shift @indexes},
			recycle              => "fair"
		);

		(!defined $k1->peek() ) or die;
		($k1->push(0, 1)  == 1) or die;
		($k1->lifetime(0) == 1) or die;
		($k1->remove(0)   == 1) or die;
		($k1->push(1, 2)  == 1) or die;
		($k1->lifetime(1) == 2) or die;
		($k1->push(2, 2)  == 1) or die;
		($k1->push(3, 2)  == 1) or die;
		($k1->push(4, 2)  == 1) or die;
		($k1->push(5, 2)  == 1) or die;
		($k1->push(6, 2)  == 1) or die;
		($k1->push(7, 2)  == 1) or die;
		($k1->push(6, 1)  == 0) or die;
		($k1->remove(7)   == 1) or die;
		($k1->lifetime(7) == 0) or die;
		($k1->length()    == 6) or die;
		($k1->remove(7)   == 0) or die;
		($k1->length()    == 6) or die;
		push @indexes, 1;
		($k1->prime()     == 2) or die;
		($k1->peek()      == 2) or die;
		push @indexes, 0;
		($k1->prime()     == 1) or die;
		($k1->cycle()     == 1) or die;
		($k1->lifetime(1) == 1) or die;
		push @indexes, 2;
		($k1->cycle()     == 4) or die;
		push @indexes, 1;
		($k1->cycle()     == 3) or die;
		push @indexes, 0;
		($k1->cycle()     == 2) or die;
		push @indexes, 4;
		($k1->prime()     == 3) or die;
		
		my $k1_save1 = $k1->save();
		for (0..1) {
			push @indexes, 2;
			($k1->prime()     == 1) or die;
			($k1->length()    == 6) or die;
			($k1->cycle()     == 1) or die;
			($k1->lifetime(1) == 0) or die;
			($k1->length()    == 5) or die;
			push @indexes, 4;
			($k1->cycle()     == 2) or die;
			($k1->length()    == 4) or die;
			($k1->push(7, 1)  == 1) or die;		
			push @indexes, 4;
			($k1->cycle()     == 7) or die;
			($k1->length()    == 4) or die;
			push @indexes, 0;
			($k1->cycle()     == 5) or die;
			push @indexes, 3;
			($k1->cycle()     == 5) or die;
			($k1->remove(6)   == 1) or die;
			push @indexes, 1;
			($k1->prime()     == 3) or die;
			($k1->peek()      == 3) or die;
			($k1->peek()      == 3) or die;
			push @indexes, 0;
			($k1->prime()     == 4) or die;
			($k1->relax()     == 1) or die;
			($k1->relax()     == 0) or die;
			push @indexes, 0;
			($k1->lifetime(4) == 1) or die;
			($k1->prime()     == 4) or die;			
			($k1->lifetime(4) == 1) or die;
			($k1->cycle()     == 4) or die;
			($k1->lifetime(4) == 0) or die;
			($k1->length()    == 1) or die;	
			($k1->remove(3)   == 1) or die;
			($k1->length()    == 0) or die;	
			(!defined $k1->peek() ) or die;
			(!defined $k1->prime()) or die;
			(!defined $k1->cycle()) or die;
			($k1->push(1, 1)  == 1) or die;
			push @indexes, 0;
			($k1->cycle()     == 1) or die;
			($k1->length()    == 0) or die;	
			(!defined $k1->peek() ) or die;
			(!defined $k1->prime()) or die;
			(!defined $k1->cycle()) or die;
			($k1->push(9, 2)  == 1) or die;
			($k1->push(8, 2)  == 1) or die;
			push @indexes, 0;
			($k1->prime()     == 9) or die;
			($k1->peek()      == 9) or die;
			($k1->remove(9)   == 1) or die;
			($k1->relax()     == 0) or die;
			
			$k1->load(string => $k1_save1) unless ($_);
		}
	}
	
	# Test that indexGenerator gets sent the length of the cycle.
	if (1) {
		my @lengths = ();
		my $k1 = Karma->new(
			allowDuplicateActIds => 0,
			indexGenerator       => sub {push @lengths, $_[1]; 0},
			recycle              => "fair"
		);
		
		($k1->push(4, 1)  == 1) or die;
		($k1->push(5, 2)  == 1) or die;
		($k1->push(6, 2)  == 1) or die;
		($k1->push(7, 2)  == 1) or die;
		($k1->peek()      == 4) or die;
		(shift @lengths   == 4) or die;
		($k1->prime()     == 4) or die;
		(shift @lengths   == 4) or die;
		($k1->cycle()     == 4) or die;
		($k1->length()    == 3) or die;
		($k1->cycle()     == 5) or die;
		(shift @lengths   == 3) or die;
		my $k1_save1 = $k1->save();
		
		my $k2 = Karma->new(
			allowDuplicateActIds => 0,
			indexGenerator       => sub {$_[1] - 1},
			recycle              => "fair"
		);
		for (0..1) {
			$k2->load(string => $k1_save1);
			($k2->cycle()     == 5) or die;
			($k2->cycle()     == 7) or die;
			($k2->cycle()     == 7) or die;
			($k2->cycle()     == 6) or die;
			($k2->cycle()     == 6) or die;
			(!defined $k2->cycle()) or die;
		}
		
	}

	# Test recycle => "eternal".
	if (1) {
		my @indexes = ();
		my $k1 = Karma->new(
			allowDuplicateActIds => 0,
			indexGenerator       => sub {shift @indexes}, 
			recycle              => "eternal"
		);
		
		($k1->push(7, 2)  == 1) or die; 
		($k1->push(8, 1)  == 1) or die; 
		push @indexes, 0;
		($k1->cycle()     == 7) or die; 
		push @indexes, 1;
		($k1->cycle()     == 7) or die; 
		push @indexes, 1;
		($k1->cycle()     == 7) or die; 
		push @indexes, 0;
		($k1->cycle()     == 8) or die; 
		push @indexes, 0;
		($k1->cycle()     == 7) or die; 
		($k1->lifetime(7) == 2) or die;
		($k1->lifetime(8) == 1) or die;
		my $k1_save1 = $k1->save();
		
		my $k2 = Karma->new(
			allowDuplicateActIds => 0,
			indexGenerator       => sub {0},
			recycle              => "fair"
		);		
		$k2->load(string => $k1_save1);
		($k1->lifetime(7) == 2) or die;
		($k1->lifetime(8) == 1) or die;
		($k2->length()    == 2) or die;
		($k2->cycle()     == 8) or die; 
		($k2->length()    == 1) or die;
		($k2->cycle()     == 7) or die; 
		($k2->cycle()     == 7) or die; 
		($k2->length()    == 0) or die;
		(!defined $k2->cycle()) or die;
		
	}
	
	# Test recycle => "destruct".
	if (1) {
		my @indexes = ();
		my $k1 = Karma->new(
			allowDuplicateActIds => 0,
			indexGenerator       => sub {shift @indexes},
			recycle              => "destruct"
		);
		
		($k1->push(0, 1)  == 1) or die;
		($k1->push(1, 2)  == 1) or die;
		($k1->push(2, 3)  == 1) or die;
		($k1->push(3, 9)  == 1) or die;
		
		push @indexes, 2;
		($k1->lifetime(2) == 3) or die;
		($k1->cycle()     == 2) or die; 
		($k1->lifetime(2) == 0) or die;
		push @indexes, 0;
		($k1->cycle()     == 0) or die; 
		push @indexes, 1;
		($k1->cycle()     == 3) or die; 
		push @indexes, 0;
		($k1->cycle()     == 1) or die; 
		($k1->length()    == 0) or die;
		(!defined $k1->cycle()) or die;
	}
	
	# Test allowDuplicateActIds => 1.
	if (1) {
		my @indexes = ();
		my $k1 = Karma->new(
			allowDuplicateActIds => 1,
			indexGenerator       => sub {shift @indexes},
			recycle              => "fair",
		);
		($k1->push(1, 2)  == 1) or die;
		($k1->lifetime(1) == 2) or die;
		($k1->push(1, 3)  == 1) or die;
		($k1->lifetime(1) == 2) or die;
		($k1->push(2, 2)  == 1) or die;
		($k1->push(2, 2)  == 1) or die;
		($k1->push(1, 3)  == 1) or die;
		($k1->lifetime(1) == 2) or die;
		($k1->push(3, 2)  == 1) or die;
		push @indexes, 1;
		($k1->cycle()     == 1) or die;
		($k1->lifetime(1) == 3) or die;
		push @indexes, 1;
		($k1->cycle()     == 2) or die;
		($k1->lifetime(2) == 2) or die;
		push @indexes, 1;
		($k1->cycle()     == 2) or die;
		($k1->lifetime(2) == 1) or die;
		push @indexes, 5;
		($k1->cycle()     == 2) or die;
		($k1->lifetime(2) == 1) or die;
		push @indexes, 4;
		($k1->cycle()     == 2) or die;
		($k1->lifetime(2) == 0) or die;
		push @indexes, 3;
		($k1->cycle()     == 1) or die;
		($k1->lifetime(1) == 3) or die;
		($k1->remove(1)   == 1) or die;
		($k1->lifetime(1) == 1) or die;
		($k1->remove(1)   == 1) or die;
		($k1->lifetime(1) == 2) or die;
		($k1->remove(1)   == 1) or die;
		($k1->remove(1)   == 0) or die;
		($k1->length()    == 1) or die;
	}	
	
	# Test that Karma routines throw when fed invalid arguments, but slightly
	# strange though still correct arguments are processed correctly.
	if (1) {
		!(try {Karma->new(allowDuplicateActIds => " 1");   1;}) or die;
		!(try {Karma->new(allowDuplicateActIds => 2);      1;}) or die;
		!(try {Karma->new(allowDuplicateActIds => "true"); 1;}) or die;
		!(try {Karma->new(allowDuplicateActIds => "fair"); 1;}) or die;
		!(try {Karma->new(allowDuplicateActIds => "NaN");  1;}) or die;
		!(try {Karma->new(allowDuplicateActIds => "inf");  1;}) or die;
		!(try {Karma->new(recycle =>       "unfair");      1;}) or die;
		!(try {Karma->new(recycle =>              1);      1;}) or die;
		!(try {Karma->new(recycle =>          undef);      1;}) or die;
		!(try {Karma->new(recycle =>             "");      1;}) or die;
		!(try {Karma->new(recycle => "", allowDuplicateActIds => 1);      1;}) or die;
		!(try {Karma->new(recycle => "fair", allowDuplicateActIds => -1); 1;}) or die;
		
		my $k1 = Karma->new(
			allowDuplicateActIds => "0",
			indexGenerator       => sub {0}, 
			recycle              => "fair"
		);		
		
		!(try {$k1->lifetime(-1);       1;}) or die;
		!(try {$k1->push(1, 0);         1;}) or die;
		!(try {$k1->push(1, "1+1");     1;}) or die;
		!(try {$k1->push(1, 1.1);       1;}) or die;
		!(try {$k1->push(-1, 1);        1;}) or die;
		!(try {$k1->push(1, -1);        1;}) or die;
		!(try {$k1->push("invalid", 1); 1;}) or die;
		!(try {$k1->push("", "");       1;}) or die;
		!(try {$k1->push(undef, 1);     1;}) or die;
		
		# Make sure we don't interpret "010" as octal.
		($k1->push(900008, "010") == 1 ) or die;
		($k1->lifetime(900008)    == 10) or die;
		
		# Make sure that stringified numbers and numbers are treated equally.
		($k1->remove("900008") == 1) or die;
		($k1->push("0", "1")   == 1) or die;
		($k1->lifetime("0")    == 1) or die;
		($k1->remove(0)        == 1) or die;
	}
	
	# Test that if indexGenerator generates an out of bounds index, push() will
	# throw.
	if (1) {
		my @indexes = (1, undef, -1, "seven", 1.1, "NaN", "inf", "1-1");
		my $k1 = Karma->new(
			allowDuplicateActIds => 0,
			indexGenerator       => sub {shift @indexes},
			recycle              => "fair"
		);
		
		($k1->push(0, 1)          == 1) or die;
		
		!(try {$k1->peek();  1;}) or die;
		!(try {$k1->prime(); 1;}) or die;
		while (@indexes) {
			!(try {$k1->cycle(); 1;}) or die;
		}
	}
	
	print "All tests passed!";
}

testKarma @ARGV;





















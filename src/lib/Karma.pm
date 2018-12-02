# A collection of Acts is a probabilistic cycle.
#
#
# Acts are stored in a queue, in the order in which they have been added
# (with push()). When Acts are added, they are given corresponding "lifetimes".
#
# When an Act is "cycled" (cycle()), it has its lifetime reduced by 1, and is
# added back to the end of the queue so long as its lifetime is non-zero. As for
# which act gets cycled, this is chosen with a random index generator, biased
# towards the start of the queue. This bias makes it more likely that Acts which
# have not recently been cycled will be chosen next for cycling.
#
# It is possible to peek() at which act is next set to be cycled. Doing so
# will cause this specific act to be "primed". This may incur the observer
# effect: any Acts added between peeking and cycling can not possibly be cycled,
# whereas if nothing was primed, it would be possible to randomly cycle these
# Acts. 
#
#
# Additional note:
# The term "Act" is used interchangeably with "actId", but more generally, the
# elements of the cycle are simply non-negative integers.

use warnings;
use strict;

use Data::Dumper;

our $VERSION = '0.01';

package Karma {
	sub new {
		my ($class, %args) = @_;
		
		# Set default properties.
		my $self = {
			
			# Whether or not to prevent pushing Acts with duplicate IDs.
			# If turned on, lifetime(), remove(), and cycle() will be left-
			# biased, operating on the left-most matching actId in the cycle.
			allowDuplicateActIds => 0,
			
			# A function (G) to chose which Act should next be primed, 
			# converting
			# - $_[0] = uniform random number in [0, 1), denoted U;
			# - $_[1] = positive integer n, the length of the cycle;
			# into 
			# - G($_[0], $_[1]) = biased random integer in [0, n).
			# 
			# >> Examples:
			# - G(U, n) := 0 will emulate a standard queue.
			# - G(U, n) := n - 1 will emulate a stack.
			# - G(U, n) := floor(U * n) will prime all Acts with equal
			#   probabiltiy.
			# - G(U, n) := floor(U^2 * n) will preferentially prime Acts which
			#   have not recently been cycled.
			# 
			# >> Analysis of a simple transform family:
			# Letting T: [0, 1) -> [0, 1) be an invertible transform which
			# introduces bias into a uniform random number, we can create a
			# family of functions G of the form 
			#
			#                    G(U, n) := floor(T(U) * n)                  (1)
			#
			# for all possible T.
			#
			# Pretending that this data is continuous, we can state that the
			# probability G will prime an act in the top 100-p-percent of least-
			# recently cycled Acts as:
			#
			#                     P(G(U, n) <= p) = T^-1(p)                  (2)
			#
			# Properly accounting for the troublesome discretisation that is
			# being made, we have:
			#
			#            T^-1(p) <= P(G(U, n) <= p) <= T^-1(p + 1/n)         (3)
			#
			# Note that if p is carefully chosen to be one of 0, 1/n, 2/n, ...,
			# (n-1)/n, then P(G(U, n) <= p) will sit at its lower bound, as in
			# (2). 
			#
			# >> The default G(U, n):
			# By default, our index generator is set to be of the form (2) with
			# with T(x) := x^2. This is chosen as the default transformation due
			# to its simplicity and nice shape (dense around 0).
			#
			# With this G, the probability that we prime an index in the:
			# - top 10-percentile of least-recently used indexes is 31.62%;
			# - top 50-percentile ''                                70.71%;
			# - top 90-percentile ''                                94.87%.
			#
			# >> A thinner tailed G(U, n)
			# If after something with a thinner tail probability, consider using
			#
			#             T(x):= ((1/pi) * asin(2*x^a - 1) + 1/2)^b
			#
			# with a = 5, b = 0.8. The probability that we prime an index in
			# the:
			# - top 10-percentile of least-recently used indexes is 37.86%;
			# - top 50-percentile ''                                82.25%;
			# - top 90-percentile ''                                99.25%.
			#
			# >> Additional notes:
			# For n > 1, by restricting the range of G(U, n) to [0, n-1), we can
			# introduce the characteristic that the Act which has most recently
			# been cycled or pushed will, if possible, never be primed, e.g.
			# 
			#              G(U, n) := max(floor(U^2 * (n - 1)), 0)
			#
			# or in general, the range restricted G' of G is
			#
			#                  G'(U, n) := max(G(U, n - 1), 0)
			#
			indexGenerator => sub {
				int(($_[0] ** 2) * $_[1]); # floor(U^2 * n)
			},

			# When acts are cycled, how should they re-enter the pool?
			# - "fair": their lifetime is reduced by 1, and they are readded to
			#   the end of the queue (unless their new lifetime is 0.)
			# - "eternal": their lifetime is not changed, and they are readded
			#   to the end of the queue.
			# - "destruct": they are not readded, regardless of remaining
			#   lifetime.
			recycle => "fair",
		};
		
	
 		# Replace default properties with anything provided through %args.
		for (keys %args) {
			defined $self->{$_} or 
				die "Unknown initialiser '$_' provided to Karma->new()";
			Karma::_validator($_ => $args{$_});

			$self->{$_} = $args{$_};
		}
		
		
		# Initialise internals:
		$self->{cycle} = [];      # list of actIds, queue order
		$self->{lifetimes} = [];  # lifetime of actIds, indexes corresponding to
		                          # {cycle}.
		$self->{primed} = undef;  # currently primed actId
		
		return bless $self, $class;
	}

	# Cycle the currently primed Act; remove, decrease lifetime, and re-add. If
	# no acts are primed, prime one first.
	sub cycle {
		my ($self) = @_;
		
		return undef if ($self->length() == 0);
		
		# Retrieve primed.
		my $actIdToCycle = $self->peek();
		my $lifetime = $self->lifetime($actIdToCycle);
		
		# Remove.
		$self->remove($actIdToCycle);
		
		# Re-enter the cycle, depending on rules.
		if ($self->{recycle} eq "fair") {
			$self->push($actIdToCycle, $lifetime - 1) if ($lifetime > 1);
		} elsif ($self->{recycle} eq "eternal") {
			$self->push($actIdToCycle, $lifetime);
		} elsif ($self->{recycle} eq "destruct") {
			# don't push ...
		} 
		
		return $actIdToCycle;
	}
	
	# Number of elements in the cycle.
	sub length {
		my ($self) = @_;
		
		return scalar(@{$self->{cycle}});
	}
	
	# Check lifetime, by actId. If actId is not in the cycle, it is understood
	# to have lifetime 0.
	sub lifetime {
		my ($self, $actId) = @_;
		Karma::_validator(actId => $actId);
		
		for (0..$#{$self->{cycle}}) {
			if ($self->{cycle}->[$_] == $actId) {
				return $self->{lifetimes}->[$_];
			}
		}
		return 0;
	}
	
	# Load a cycle, previously saved through save(), from one of the following
	# sources:
	# - string => <string>
	# - fh     => <filehandle>
	# - path   => <file_path>
	# Will not check the integrity of the save.
	sub load {
		my ($self, %args) = @_;
		%args // die;

		if (keys %args != 1) {
			die "Args to load() should define exactly one of 'string', " .
				"'path', 'fh'.";
		}
		
		# Load saveState from the specified source.
		my $saveState;
		if (defined $args{string}) {
			$saveState = $args{string};
		} elsif (defined $args{fh}) {
			my @lines = <$args{fh}>;
			$saveState = join("", @lines);
		} elsif (defined $args{path}) {
			open my $fh, "<", $args{path} or
				die "Failed to open file '$args{path}'";
			my @lines = <$fh>;
			$saveState = join("", @lines);
			close $fh;
 		} else {
			die "Args to load() should define exactly one of 'string', " .
				"'path', 'fh'.";
		}

		# Read saveState into the object.
		my ($VAR1, $VAR2, $VAR3);
		eval($saveState);
		$self->{primed}    = $VAR1;
		$self->{cycle}     = $VAR2;
		$self->{lifetimes} = $VAR3;
		
		return 1;
	}
	
	# Get the currently primed Act, priming one if not already available.
	sub peek {
		my ($self) = @_;
		
		return undef if ($self->length() == 0);
		
		if (not defined($self->{primed})) {
			$self->prime();
		}
		return $self->{primed};
	}
	
	# Prime a "random" Act, clobbering any act which is already primed.
	# The random index of which Act to prime is provided by 'indexGenerator',
	# see new() for additional information.
	sub prime {
		my ($self) = @_;

		my $length = $self->length();
		return undef if ($length == 0);
		
		# Generate a random index.
		my $biasedIndex = $self->{indexGenerator}(rand, $length);

		# Die if the index is invalid or out of range.
		if (!defined $biasedIndex) {
			die "'indexGenerator' produced an invalid index of 'undef'";
		}
		unless ($biasedIndex =~ /^\d+$/) {
			die "Index generated by 'indexGenerator' not a positive integer";
		}
		unless ($biasedIndex < $self->length()) {
			die "Index generated by 'indexGenerator' exceeds maximal index";
		}
		
		# Store the actId corresponding to the random index.
		$self->{primed} = $self->{cycle}->[$biasedIndex];
		
		return $self->{primed};
	}
	
	# Pushes an actId to the cycle. Unless 'allowDuplicateActIds' is set to 1,
	# pushing duplicate actIds will result in a return code of 0.
	sub push {
		my ($self, $actId, $lifetime) = @_;
		Karma::_validator(actId => $actId, lifetime => $lifetime);
		
		# Fail the push if we are disallowing duplicates, and it already exists.
		return 0 if (!$self->{allowDuplicateActIds} and
			$self->lifetime($actId) > 0);
		
		push @{$self->{cycle}}, $actId;
		push @{$self->{lifetimes}}, $lifetime;
		
		return 1;
	}
	
	# Un-prime the currently primed Act. Returns 0 if nothing was primed.
	sub relax {
		my ($self) = @_;
		
		if (defined $self->{primed}) {
			$self->{primed} = undef;
			return 1;
		}
		
		return 0;
	}
	
	# Remove an actId from the cycle. Returns 0 if actId was not found in the
	# cycle.
	sub remove {
		my ($self, $actId) = @_;
		Karma::_validator(actId => $actId);
		
		# If the Act we are removing is the one that is primed, relax().
		if (defined $self->{primed} and $actId == $self->{primed}) {
			$self->relax();
		}
		
		# Search and remove if found.
		for (0..$#{$self->{cycle}}) {
			if ($self->{cycle}->[$_] == $actId) {
				splice @{$self->{cycle}}, $_, 1;
				splice @{$self->{lifetimes}}, $_, 1;
				return 1;
			}
		}
		
		# Hasn't been found.
		return 0;
	}
	
	# Save the contents of the cycle to a file. Will not save any initialiser
	# properties that were the provided as arguments to new().
	# Will save to either:
	# - fh   => <filehandle>
	# - path => <file_path>
	# - Providing no argument will return the save-state string directly to the
	#   caller.
	sub save {
		my ($self, %args) = @_;
		
		if (keys %args > 1) {
			die "Args to save() should be left blank, or define exactly one " .
				"of 'path', 'fh'";
		}
		
		# Create saveState.
		my $saveState = main::Dumper(
			$self->{primed},
			$self->{cycle},
			$self->{lifetimes}
		);	
		
		# Write saveState to the specified destination.
		if (%args) {
			if (defined $args{fh}) {
				$args{fh}->print($saveState);
			} elsif (defined $args{path}) {
				open my $fh, ">", $args{path} or
					die "Failed to open file '$args{path}'";
				print $fh $saveState;
				close $fh;
			} else {
				die "Args to save() should be left blank, or define exactly " .
					"one of 'path', 'fh'";
			}
			return undef;
		} else {
			return $saveState;
		}
 	}
	
	# Die when functions are given arguments that don't follow these validation
	# rules:
	sub _validator {
		my (%args) = @_;
		
		my %rules = (
			actId => sub {
				$_[0] =~ /^\d+$/;
			},
			
			lifetime => sub {
				$_[0] =~ /^\d+$/ and $_[0] > 0;
			},
			
			# We can only confirm the validity of the indexes as we generate
			# them, so their validity is given the benefit of the doubt at this
			# point.
			indexGenerator => sub {
				1;
			},
			
			allowDuplicateActIds => sub {
				$_[0] =~ /^\d+$/ && ($_[0] == 0 || $_[0] == 1);
			},
			
			recycle => sub {
				$_[0] eq "eternal" or $_[0] eq "fair" or $_[0] eq "destruct";
			},
		);
		
		for (keys %args) {
			defined $rules{$_} or
				die "No rule to check the validity of argument '$_' => '" .
				($args{$_} // "undef") . "' defined in validator";
			defined $args{$_} or
				die "Parameter '$_' cannot be set to 'undef'";
			$rules{$_}($args{$_}) or
				die "'$args{$_}' is not a valid value of parameter '$_'";
		}
		
		return 1;
	}
	
};

1;









__END__

=head1 NAME

Karma - What goes around comes around, probably.

=head1 SYNOPSIS

  See KWrap # TODO

=head1 DESCRIPTION

A collection of Acts is a probabilistic cycle.

=head1 SEE ALSO

<lt>https://github.com/nick-killeen/karma/<gt>

=head1 AUTHOR

Nicholas Killeen<lt>nicholas.killeen2@gmail.com<gt>

=head1 COPYRIGHT AND LICENSE

GNU General Public License v3.0, as at <lt>https://github.com/nick-killeen/karma/<gt>.

=cut

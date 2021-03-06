#! /usr/bin/env perl

use strict;
use utf8;
use warnings;

use Carp;
use Date::Parse;
use FindBin qw/$Bin/;
use LWP::UserAgent;
use Term::ANSIColor;
use XML::RSS::Parser;
use YAML::Tiny;

# setup the perl environment
our $VERSION = "1.4.0";

binmode STDOUT, ":encoding(utf8)";

# globals
my $yaml;

# bind interrupt handlers
local $SIG{USR1} = \load_config();

# initial config load
load_config();

# create a UA
my $ua = LWP::UserAgent->new();
$ua->agent("gabu/$VERSION");

# logging functions
sub colored_message
{
	my $color   = shift;
	my $message = shift;

	return color($color) . $message . color("reset") . "\n";
}

sub load_config
{
	my @files;

	if (defined $ENV{XDG_CONFIG_HOME}) {
		push @files, $ENV{XDG_CONFIG_HOME} . "/gabu.yaml";
	}

	push @files,
		(
		"$ENV{HOME}/.config/gabu.yaml",
		"/usr/local/etc/gabu.yaml",
		"/etc/gabu.yaml",
		$Bin . "/../etc/gabu.yaml"
		);

	foreach my $file (@files) {
		if (-f $file) {
			$yaml = YAML::Tiny->read($file);

			print colored_message("white", "Loaded config at $file");

			return;
		}
	}

	print colored_message("bold red", "Could not find a configuration file:");

	foreach my $file (@files) {
		print "\t$file\n";
	}

	croak;
}

while (1) {

	# read timers
	my %timers;
	my $timer_file = $yaml->[0]->{timers} // "/var/lib/gabu/timers";

	{
		open my $fh, "<", $timer_file or do {
			carp colored_message("red", "Could not open $timer_file: $!");
			last;
		};

		while (<$fh>) {
			chomp;

			my @megumin = split;

			$timers{ $megumin[0] } = $megumin[1];
		}

		close $fh;
	}

	# go through all feeds
	my @feeds = @{ $yaml->[0]->{feeds} };

	foreach my $feed (@feeds) {
		if ($yaml->[0]->{verbose}) {
			print colored_message("blue", $feed->{url});
		}

		# fetch the rss feed
		my $response = $ua->get($feed->{url});

		if (!$response->is_success) {
			carp(colored_message("red", $response->status_line));
		}

		# parse the feed
		my $parser = XML::RSS::Parser->new();
		my $rss    = $parser->parse_string($response->decoded_content());

		if (!$rss) {
			carp(colored_message("red", $parser->errstr));
			next;
		}

		my $new_timer = $timers{ $feed->{url} } // 0;

		foreach my $node ($rss->query("//item")) {

			# skip all items which are before our current timestamp
			my $current = str2time($node->query("pubDate")->text_content);

			if (defined($timers{ $feed->{url} })
				&& $current <= $timers{ $feed->{url} })
			{
				next;
			}

			# keep track of new timestamp
			if ($current > $new_timer) {
				$new_timer = $current;
			}

			# check current item against regexes
			chomp(my $title = $node->query("title")->text_content);

			if ($yaml->[0]->{verbose}) {
				print colored_message("bright_white", " $title");
			}

			my $found   = 0;
			my @regexes = @{ $feed->{regexes} };

			foreach my $regex (@regexes) {
				if ($title =~ m/$regex/gimsx) {
					if ($yaml->[0]->{verbose}) {
						print colored_message("green", "  $regex");
					}

					# mark this item as wanted
					$found = 1;
					last;
				}
			}

			if (!$found) {
				next;
			}

			# get the torrent
			chomp(my $link = $node->query("link")->text_content);
			my $torrent;

			# for magnets, get the link directly
			if ($link =~ /^magnet/xms) {
				$torrent = $link;
			}
			else {
				$torrent = $ua->get($link);

				if (!$torrent->is_success) {
					carp(colored_message("red", $torrent->status_line));
					next;
				}
			}

			# generate a safer filename
			(my $filename = $title) =~ s/[\s\/]+/_/msgx;
			my $file = "$yaml->[0]->{watchdir}/$filename.torrent";

			# save the torrent file
			open my $fh, ">", $file or do {
				carp colored_message(
					"red",
					"Could not open filehandle at $file: $!"
				);
				next;
			};

			if ($torrent =~ /^magnet/xms) {
				printf {$fh} "d10:magnet-uri%s:%se\n", length $torrent,
					$torrent;
			}
			else {
				print {$fh} $torrent->decoded_content();
			}

			close $fh;

			print colored_message("bold blue", "   $file");
		}

		# apply new timestamp to timers hash
		$timers{ $feed->{url} } = $new_timer;
	}

	# save new timers
	{
		open my $fh, ">", $timer_file or do {
			carp(colored_message("red", "Could not open $timer_file: $!"));
			last;
		};

		foreach my $timer (keys %timers) {
			print {$fh} "$timer\t$timers{$timer}\n";
		}

		close $fh;
	}

	# wait a bit for the next run
	if ($yaml->[0]->{timeout} == 0) {
		exit 0;
	}

	sleep($yaml->[0]->{timeout});
}


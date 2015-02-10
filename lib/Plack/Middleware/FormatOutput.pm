package Plack::Middleware::FormatOutput;

use 5.006;
use strict;
use warnings FATAL => 'all';

use parent qw( Plack::Middleware );

use HTTP::Exception '4XX';

use JSON::XS;
use YAML::Syck;

=head1 NAME

Plack::Middleware::FormatOutput - Format output struct by Accept header.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

	use Plack::Middleware::FormatOutput;

	builder {
		enable 'FormatOutput';
		mount "/api" => sub { return {'link' => 'content'} };
	};

=head1 DESCRIPTION

The Middleware formats output perl struct by "Accept" header param or by format param in URL.

You can get json when define:

=over 4

=item * Accept header application/json

or

=item * Add ?format=application/json to URL

=back

For complete RestAPI in Perl use: 

=over 4

=item * Plack::Middleware::RestAPI

=item * Plack::Middleware::ParseContent

=back

=head1 CONSTANTS

=head2 DEFAULT MIME TYPES

=over 4

=item * application/json

=item * text/yaml

=item * text/plain

=item * text/html - it uses HTML::Vis as default formater if installed

=back

=cut

### Set HTML::Vis
my $htmlvis = undef;

### Try load library
sub _try_load {
	my $mod = shift;
	eval("use $mod; 1") ? return 1 : return 0;
}

### Set default mime types
my $MIME_TYPES = {
	'application/json'   => sub { JSON::XS->new->utf8->allow_nonref->encode($_[0]) },
	'text/yaml'          => sub { 
		local $Data::Dumper::Indent=1; local $Data::Dumper::Quotekeys=0; local $Data::Dumper::Terse=1; local $Data::Dumper::Sortkeys=1;
		Dump($_[0]) 
	},
	'text/plain'         => sub { 
		local $Data::Dumper::Indent=1; local $Data::Dumper::Quotekeys=0; local $Data::Dumper::Terse=1; local $Data::Dumper::Sortkeys=1;
		Dump($_[0]) 
	},
	'text/html'   => sub {
		if ($htmlvis){
			return $htmlvis->html($_[0]);
		}else{
			return @_;
		}
	}
};

=head1 PARAMETERS

=head2 mime_type

Specify if and how returned content should be formated in browser.

For example:

	use Plack::Middleware::FormatOutput;
	use My::HTML

	builder {
		enable 'FormatOutput', mime_type => {
			'text/html' => sub{ My::HTML::Parse(@_) }
		};
		mount "/api" => sub { return {'link' => 'content'} };
	};

=head2 htmlvis (if HTML::Vis is installed)

Define parameters for HTML::Vis. 

For example:

	use Plack::Middleware::FormatOutput;

	builder {
		enable 'FormatOutput', htmlvis => {
			links => 'My::Links'
		};
		mount "/api" => sub { return {'link' => 'content'} };
	};

=cut

sub prepare_app {
	my $self = shift;

	### Add new mime types
	foreach my $par (keys %{$self->{mime_type}}){
		next unless ref $self->{mime_type}{$par} eq 'CODE';
		$MIME_TYPES->{$par} = $self->{mime_type}{$par};
	}

	### Add htmlvis
	if (_try_load('HTML::Vis')){
		my $params = $self->{htmlvis} if exists $self->{htmlvis};
		$htmlvis = HTML::Vis->new($params);
	}

}

sub call {
	my($self, $env) = @_;

	my $accept = _getAccept($env);

	# Run app
	my $ret = $self->app->($env);

	# Return if not content
	if (!defined $ret){
		return ['200', ['Content-Type' => $accept], []];
	}

	### Transform returned perl struct by accept
	my $res = $MIME_TYPES->{$accept}->($ret);
	
	return ['200', ['Content-Type' => $accept, 'Content-Length' => length($res) ], [ $res ]];
}

sub _getAccept {
	my ($env) = @_;

	# Get accept from url
	my $accept;
	# We parse this with reqular because we need this as quick as possible
	if ($env->{QUERY_STRING} =~/format=([\w\/\+]*)/){
		if (exists $MIME_TYPES->{$1}){
			$accept = $1;
		}
	};

	# Set accept by http header
	if (!$accept && $env->{HTTP_ACCEPT}){
		foreach (split(/,/, $env->{HTTP_ACCEPT})){
			next unless exists $MIME_TYPES->{$_};
			$accept = $_;
			last;
		}
	}

	HTTP::Exception::406->throw() unless defined $accept;

	return $accept;
}

=head1 TUTORIAL

L<http://psgirestapi.dovrtel.cz/>

=head1 AUTHOR

Vaclav Dovrtel, C<< <vaclav.dovrtel at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to github repository.

=head1 ACKNOWLEDGEMENTS

Inspired by L<https://github.com/towhans/hochschober>

=head1 REPOSITORY

L<https://github.com/vasekd/Plack-Middleware-FormatOutput>

=head1 LICENSE AND COPYRIGHT

Copyright 2015 Vaclav Dovrtel.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

=cut

1; # End of Plack::Middleware::FormatOutput

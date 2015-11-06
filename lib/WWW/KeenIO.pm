package WWW::KeenIO;

=head1 NAME

WWW::KeenIO - Perl API to Keen.IO analytics

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use 5.006;
use strict;
use warnings;

use Data::Dumper;
use REST::Client;
use JSON::XS;
use URI;
use Scalar::Util qw(blessed);

use Mouse;
#print Dumper(\%INC);

#** @attr public api_key $api_key API access key
#*
has api_key => ( isa => 'Str', is => 'rw');

#** @attr public CodeRef $read_key API key for writing data (if different from api_key 
#*
has write_key => ( isa => 'Maybe[Str]', is => 'rw');

#** @attr public Int $project_id ID of the project
#*
has project => ( isa => 'Str', is => 'rw');

#** @attr protected String $base_url Base REST URL
#*
has base_url => ( isa => 'Str', is => 'rw',
                  default => 'https://api.keen.io/3.0/projects/$project/events/$collection');

#** @attr protected CodeRef $ua Reference to the REST UA
#*
has ua => ( isa => 'Object', is => 'rw',
            lazy => 1,
            init_arg => undef,
            default => sub {
                return REST::Client->new();
            }
           );

#** @attr public String $error_message Error message regarding the last failed operation
#*
has error_message => ( isa => 'Str', is => 'rw', init_arg => undef, default => '');

sub _url {
    my ($self, $collection, $write) = @_;

    my $rest_params = {
            project => $self->project,
            collection => $collection
           };

    my $url = $self->base_url;
    $url =~ s^\$([\w\d\_]+)^$rest_params->{$1}^eg;
    my $uri = URI->new($url, 'http');
    my $query_params = {
        api_key => $write ? 
          $self->write_key // $self->api_key :
            $self->api_key
       };
    $uri->query_form($query_params);

    return $uri->as_string;
}

sub _process_response {
    my ($self, $response) = @_;

    if ($@) {
        $self->error_message("Error $@");
        return undef;
    } elsif (!blessed($response)) {
        $self->error_message("Unknown response $response from the REST client instead of object");
        return undef;
    } 
#    print "Got response:".Dumper($response->responseCode())."/".
#          Dumper($response->responseContent())."\n";
    my $code = $response->responseCode();
    if ($code ne '201' && $code ne '201') {
        $self->error_message("Received error code $code from the server instead of expected 200/201");
        return undef;
    }

    $self->error_message(q{});
    return $response->responseContent();
}

sub _transaction {
    my ($self, $method, $write, $collection, $record) = @_;

    my $response = eval {
        $self->ua->$method(
            $self->_url($collection, $write),
            encode_json($record),
            {
                'Content-Type' => 'application/json'
               }
           );
    };
    cluck($@) if $@;
    return $self->_process_response($response);
}



=head1 SYNOPSIS

    use WWW::KeenIO;
    use Text::CSV_XS;

    my $csv = Text::CSV_XS->new;
    my $k = WWW::KeenIO->new( {
          project    => '54d51b7f96773d3a427b5a76',
          read_key   => '...',
          write_key  => '...'
    ) or die 'Cannot create KeenIO object';
    # read name / in|out / date-time data from input, import them as keenIO events
    # e.g.
    while(<>) {
      chomp;
      my $status = $csv->parse($_);
      unless ($status) {
          warn qq{Cannot parse '$_':}.$csv->error_diag();
          next;
      }
      my @fields = $csv->fields();
      my $data = {
          keen => {
             timestamp => $fields[2]
          }
          name => $fields[0],
          type => $fields[1]
      };
      my $res = $api->put('in_out_log', $data);
      unless ($res->responseCode() eq '201') {
         warn "Unable to store the data in keenIO";
      }
    }


=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 put($collection_name, $data)

Insert an object into collection. $data is a hashref

=cut

sub put {
    my ($self, $collection, $record) = @_;
    return $self->_transaction('POST', 1, $collection, $record);
}

=head2 get($collection_name, $data)

=cut

sub get {
    my ($self, $collection, $record) = @_;
    return $self->_transaction('GET', 0, $collection, $record);
}

=head1 AUTHOR

Andrew Zhilenko, C<< <andrew at ti.cz> >>
(c) Putin Huylo LLC, 2015

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-keenio at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-KeenIO>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::KeenIO


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-KeenIO>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-KeenIO>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-KeenIO>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-KeenIO/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 Andrew Zhilenko.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

__PACKAGE__->meta->make_immutable;

1; # End of WWW::KeenIO

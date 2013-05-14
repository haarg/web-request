package Web::Request::Upload;
use Moo;
# ABSTRACT: class representing a file upload

use HTTP::Headers;

use Web::Request::Types qw(:all);
use MooX::Types::MooseLike::Base qw(:all);
use Carp;
use namespace::clean;

=head1 SYNOPSIS

  use Web::Request;

  my $app = sub {
      my ($env) = @_;
      my $req = Web::Request->new_from_env($env);
      my $upload = $req->uploads->{avatar};
  };

=head1 DESCRIPTION

This class represents a single uploaded file, generally from an C<< <input
type="file" /> >> element. You most likely don't want to create instances of
this class yourself; they will be created for you via the C<uploads> method on
L<Web::Request>.

=cut

has headers => (
    is      => 'ro',
    isa     => InstanceOf['HTTP::Headers'],
    coerce  => \&coerce_HTTPHeaders,
    handles => ['content_type'],
);

has tempname => (
    is  => 'ro',
    isa => Str,
);

has size => (
    is  => 'ro',
    isa => Int,
);

has filename => (
    is  => 'ro',
    isa => Str,
);

# XXX Path::Class, and just make this a delegation?
# would that work at all on win32?
has basename => (
    is  => 'ro',
    isa => Str,
    lazy => 1,
    default => sub {
        my $self = shift;

        require File::Spec::Unix;

        my $basename = $self->{filename};
        $basename =~ s{\\}{/}g;
        $basename = (File::Spec::Unix->splitpath($basename))[2];
        $basename =~ s{[^\w\.-]+}{_}g;

        return $basename;
    },
);

=method headers

Returns an L<HTTP::Headers> object containing the headers specific to this
upload.

=method content_type

Returns the MIME type of the uploaded file. Corresponds to the C<Content-Type>
header.

=method tempname

Returns the local on-disk filename where the uploaded file was saved.

=method size

Returns the size of the uploaded file.

=method filename

Returns the preferred filename of the uploaded file.

=method basename

Returns the filename portion of C<filename>, with all directory components
stripped.

=cut

1;

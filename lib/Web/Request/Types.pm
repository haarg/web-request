package Web::Request::Types;
use strict;
use warnings;

use MooX::Types::MooseLike;
use MooX::Types::MooseLike::Base qw(:all);
use Exporter qw(import);

our @EXPORT_OK;
our %EXPORT_TAGS = ('all' => \@EXPORT_OK);

MooX::Types::MooseLike::register_types([
    {
        name => 'PSGIBodyObject',
        subtype_of => HasMethods['getline', 'close'],
        test => sub { 1 },
    },
], __PACKAGE__);
MooX::Types::MooseLike::register_types([
    {
        name => 'StringLike',
        subtype_of => Object,
        test => sub {
            return unless overload::Method($_[0], '""');
            !is_PSGIBodyObject($_[0]);
        },
    },
], __PACKAGE__);
{
  local @EXPORT_OK;
  MooX::Types::MooseLike::register_types([
      {
          name => '_Stringable',
          subtype_of => AnyOf[Str, StringLike()],
          test => sub { 1 },
      }
  ], __PACKAGE__);
}
MooX::Types::MooseLike::register_types([
    {
        name => 'PSGIBody',
        subtype_of => AnyOf[
          ArrayRef[_Stringable()],
          FileHandle,
          PSGIBodyObject(),
        ],
        test => sub { 1 },
    },
], __PACKAGE__);
MooX::Types::MooseLike::register_types([
    {
        name => 'HTTPStatus',
        subtype_of => Int,
        test => sub { $_[0] =~ /^[1-5][0-9][0-9]$/ },
    }
], __PACKAGE__);
MooX::Types::MooseLike::register_types([
    {
        name => 'HTTPHeaders',
        subtype_of => InstanceOf['HTTP::Headers'],
        test => sub { 1 },
    }
], __PACKAGE__);

sub coerce_HTTPHeaders {
    my $in = shift;
    if (is_HTTPHeaders($in)) {
        return $in;
    }
    elsif (is_ArrayRef($in)) {
        return HTTP::Headers->new(@$in);
    }
    elsif (is_HashRef($in)) {
        return HTTP::Headers->new(%$in);
    }
    return $in;
}
push @EXPORT_OK, 'coerce_HTTPHeaders';

sub coerce_PSGIBody {
    my $in = shift;
    if (is_PSGIBody($in)) {
        return $in;
    }
    elsif (is__Stringable($in)) {
        return [ $in ];
    }
    return $in;
}
push @EXPORT_OK, 'coerce_PSGIBody';

1;

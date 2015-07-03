package Data::Crumbr::Default;

# ABSTRACT: Default renderer for Data::Crumbr

use Mo qw< default coerce >;

use 5.018;
use strict;
use warnings;
use Carp;
use English qw< -no_match_vars >;
use Scalar::Util qw< blessed >;

has hash_key_prefix   => (default => sub { '{' });
has hash_key_suffix   => (default => sub { '}' });
has array_key_prefix  => (default => sub { '[' });
has array_key_suffix  => (default => sub { ']' });
has keys_separator    => (default => sub { '' });
has value_separator   => (default => sub { ':' });
has array_key_encoder => (default => \&__json_encoder);
has hash_key_encoder  => (default => \&__json_encoder);
has value_encoder     => (default => \&__json_encoder);

has output            => (
   default => sub { __output() },
   coerce => \&__output,
);

sub __json_encoder {
   require JSON;
   my $encoder = JSON->new()->allow_nonref()->utf8();
   return sub { $encoder->encode($_[0]) };
}

sub __output {
   my ($output) = @_;
   $output //= [];
   my $reftype = ref $output;

   if (!$reftype) {    # filename, transform into filehandle
      my $fh = \*STDOUT;
      if ($output ne '-') {
         $fh = undef;
         open $fh, '>', $output
           or croak "open('$output'): $OS_ERROR";
      }
      binmode $fh, ':raw'
        or croak "binmode() on $output: $OS_ERROR";
      $reftype = ref($output = $fh);
   } ## end if (!$reftype)

   return sub {
      return unless @_;
      print {$output} $_[0], "\n";
   } if $reftype eq 'GLOB';

   return sub {
      return $output unless @_;
      push @$output, $_[0];
   } if $reftype eq 'ARRAY';

   return sub {
      return unless @_;
      $output->print($_[0]);
   } if blessed($output);

   return sub {
      return unless @_;
      return $output->($_[0]);
   } if $reftype eq 'CODE';

   croak "invalid output";
} ## end sub __output

sub leaf {
   my ($self, $stack) = @_;

   my $venc       = $self->value_encoder();
   my @components = $venc->($stack->[-1]{data});

   my @keys = map { $_->{encoded} } @$stack;
   pop @keys;    # last item of @$stack is the leaf, drop it
   unshift @components, join $self->keys_separator(), @keys
     if @keys;

   $self->output()->(join $self->value_separator(), @components);
} ## end sub leaf

{
   no strict 'refs';
   *scalar_leaf = \&leaf;
   *array_leaf  = \&leaf;
   *hash_leaf   = \&leaf;
}

sub array_keys_iterator {
   my ($self, $aref) = @_;
   my $i   = 0;
   my $sup = @$aref;
   return sub {
      return if $i >= $sup;
      return $i++;
   };
} ## end sub array_keys_iterator

sub hash_keys_iterator {
   my ($self, $href) = @_;
   my @keys = sort keys %$href;    # memory intensive...
   return sub { return shift @keys };
}

sub array_key {
   my ($self, $key) = @_;
   return join '', $self->array_key_prefix(),
     $self->array_key_encoder()->($key),
     $self->array_key_suffix();
} ## end sub array_key

sub hash_key {
   my ($self, $key) = @_;
   return join '', $self->hash_key_prefix(),
     $self->hash_key_encoder()->($key),
     $self->hash_key_suffix();
} ## end sub hash_key

sub result {
   my ($self) = @_;
   my $output = $self->output()->()
      or return;
   return join "\n", @$output;
}

sub reset {
   my ($self) = @_;
   my $output = $self->output()->()
      or return;
   @$output = ();
   return;
}

1;
__END__

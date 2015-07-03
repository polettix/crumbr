package Data::Crumbr;

# ABSTRACT: Render data structures for easy searching and parsing

# Inlined Mo
use Mo qw< default coerce >;

use 5.018;
use strict;
use warnings;
use Carp;
use English qw< -no_match_vars >;
use Exporter qw< import >;
use Scalar::Util qw< blessed >;

our @EXPORT      = qw< crumbr >;
our @EXPORT_OK   = @EXPORT;
our %EXPORT_TAGS = (all => [@EXPORT_OK]);

has encoder => (
   default => sub { __encoder() },
   coerce  => \&__encoder,
);

sub crumbr {
   my $wh = __PACKAGE__->new(@_);
   return sub { $wh->encode(@_) };
}

sub __encoder {
   my ($e) = @_;
   if (!blessed($e)) {
      my ($class, @parameters) = $e;
      if (ref($e) eq 'HASH') {
         $class = delete $e->{class};
         @parameters = %$e;
      }
      $class = '::Default' unless defined $class;
      $class = __PACKAGE__ . $class
        if substr($class, 0, 2) eq '::';
      (my $packname = "$class.pm") =~ s{::}{/}gmxs;
      require $packname;
      $e = $class->new(@parameters);
   } ## end if (!blessed($e))
   return $e;
} ## end sub get_encoder

sub encode {
   my ($self, $data) = @_;
   my $encoder = $self->encoder();
   $encoder->reset();

   my @stack = { data => $data, type => ref($data) };
   ITERATION:
   while (@stack) {
      my $frame = $stack[-1];
      if (! $frame->{type}) {
         $encoder->scalar_leaf(\@stack);
      }
      elsif ($frame->{type} eq 'ARRAY') {
         if (! scalar(@{$frame->{data}})) {
            $encoder->array_leaf(\@stack);
         }
         else {
            my $iterator = $frame->{iterator} //=
               $encoder->array_keys_iterator($frame->{data});
            if (defined(my $key = $iterator->())) {
               $frame->{encoded} = $encoder->array_key($key);
               my $child_data = $frame->{data}[$key];
               push @stack, {
                  data => $child_data,
                  type => ref($child_data),
               };
               next ITERATION;
            }
         }
      }
      elsif ($frame->{type} eq 'HASH') {
         if (! scalar(keys %{$frame->{data}})) {
            $encoder->hash_leaf(\@stack);
         }
         else {
            my $iterator = $frame->{iterator} //=
               $encoder->hash_keys_iterator($frame->{data});
            if (defined(my $key = $iterator->())) {
               $frame->{encoded} = $encoder->hash_key($key);
               my $child_data = $frame->{data}{$key};
               push @stack, {
                  data => $child_data,
                  type => ref($child_data),
               };
               next ITERATION;
            }
         }
      }
      else {
         croak "cannot handle frame of type $frame->{type}";
      }

      # only leaves or end-of-container arrive here
      pop @stack;
   }

   return $encoder->result();
}

1;
__END__

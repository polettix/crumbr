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

sub __load_class {
   my ($class) = @_;
   (my $packname = "$class.pm") =~ s{::}{/}gmxs;
   require $packname;
   return $class;
} ## end sub __load_class

sub crumbr {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   if (defined(my $name = delete $args{profile})) {
      my $class   = __PACKAGE__ . "::Default::$name";
      my $profile = __load_class($class)->profile();
      my $encoder = delete($args{encoder}) // {};
      %$encoder = (
         %$profile,
         %$encoder,    # allow some overriding
         class => '::Default',    # but not on this one
      );
      %args = (encoder => $encoder);
   } ## end if (defined(my $name =...))
   my $wh = __PACKAGE__->new(%args);
   return sub { $wh->encode(@_) };
} ## end sub crumbr

sub __encoder {
   my ($e) = @_;
   if (!blessed($e)) {
      my ($class, @parameters) = $e;
      if (ref($e) eq 'HASH') {
         $class      = delete $e->{class};
         @parameters = %$e;
      }
      $class = '::Default' unless defined $class;
      $class = __PACKAGE__ . $class
        if substr($class, 0, 2) eq '::';
      $e = __load_class($class)->new(@parameters);
   } ## end if (!blessed($e))
   return $e;
} ## end sub __encoder

sub encode {
   my ($self, $data) = @_;
   my $encoder = $self->encoder();
   $encoder->reset();

   my @stack = ({closers => ''}, {data => $data, type => ref($data)},);
 ITERATION:
   while (@stack > 1) {    # frame #0 is dummy
      my $frame = $stack[-1];
      if ($frame->{type} eq 'ARRAY') {
         if (!scalar(@{$frame->{data}})) {
            $encoder->array_leaf(\@stack);
         }
         else {
            my $iterator = $frame->{iterator} //=
              $encoder->array_keys_iterator($frame->{data});
            if (defined(my $key = $iterator->())) {
               $frame->{encoded} = $encoder->array_key($key);
               $frame->{closers} =
                 $encoder->array_close() . $stack[-2]{closers};
               my $child_data = $frame->{data}[$key];
               push @stack,
                 {
                  data => $child_data,
                  type => ref($child_data),
                 };
               next ITERATION;
            } ## end if (defined(my $key = ...))
         } ## end else [ if (!scalar(@{$frame->...}))]
      } ## end if ($frame->{type} eq ...)
      elsif ($frame->{type} eq 'HASH') {
         if (!scalar(keys %{$frame->{data}})) {
            $encoder->hash_leaf(\@stack);
         }
         else {
            my $iterator = $frame->{iterator} //=
              $encoder->hash_keys_iterator($frame->{data});
            if (defined(my $key = $iterator->())) {
               $frame->{encoded} = $encoder->hash_key($key);
               $frame->{closers} =
                 $encoder->hash_close() . $stack[-2]{closers};
               my $child_data = $frame->{data}{$key};
               push @stack,
                 {
                  data => $child_data,
                  type => ref($child_data),
                 };
               next ITERATION;
            } ## end if (defined(my $key = ...))
         } ## end else [ if (!scalar(keys %{$frame...}))]
      } ## end elsif ($frame->{type} eq ...)
      else {    # treat as leaf scalar
         $encoder->scalar_leaf(\@stack);
      }

      # only leaves or end-of-container arrive here
      pop @stack;
   } ## end ITERATION: while (@stack > 1)

   return $encoder->result();
} ## end sub encode

1;
__END__

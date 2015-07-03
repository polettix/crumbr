package Data::Crumbr::Util;

# ABSTRACT: utility functions for Data::Crumbr
use 5.018;
use strict;
use Carp;

sub json_leaf_encoder {
   require B;
   return \&_json_leaf_encode;
}

sub _json_leaf_encode {
   return 'null' unless defined $_[0];

   my $reftype = ref($_[0]);
   return '[]' if $reftype eq 'ARRAY';
   return '{}' if $reftype eq 'HASH';
   return (${$_[0]} ? 'true' : 'false')
     if $reftype eq 'SCALAR';
   croak "unsupported ref type $reftype" if $reftype;

   my $number_flags = B::SVp_IOK() | B::SVp_NOK();
   return $_[0]
     if (B::svref_2object(\$_[0])->FLAGS() & $number_flags)
     && 0 + $_[0] eq $_[0]
     && $_[0] * 0 == 0;

   state $slash_escaped = {
      0x22 => '"',
      0x5C => "\\",
      0x2F => '/',
      0x08 => 'b',
      0x0C => 'f',
      0x0A => 'n',
      0x0D => 'r',
      0x09 => 't',
   };
   my $string = join '', map {
         my $cp = ord($_);

           if (exists $slash_escaped->{$cp}) {
            "\\$slash_escaped->{$cp}";
         }
         elsif ($cp >= 32 && $cp < 128) {    # ASCII
            $_;
         }
         elsif ($cp < 0x10000) {    # controls & BML
            sprintf "\\u%4.4X", $cp;
         }
         else {                     # beyond BML
            my $hi = ($cp - 0x10000) / 0x400 + 0xD800;
            my $lo = ($cp - 0x10000) % 0x400 + 0xDC00;
            sprintf "\\u%4.4X\\u%4.4X", $hi, $lo;
         }
      } split //, $_[0];
   return qq<"> . $string . qq<">;
} ## end sub json_leaf_encoder

sub uri_encoder {
   require Encode;
   return \&_uri_encoder;
}

sub _uri_encoder {
   my $octets = Encode::encode('UTF-8', $_[0], Encode::FB_CROAK());
   state $is_unreserved = {
      map { $_ => 1 }
         ('a' .. 'z', 'A' .. 'Z', '0' .. '9', qw< - _ . ~ >)
   };
   return join '', map {
      $is_unreserved->{$_} ? $_ : sprintf('%%%2.2X', ord $_);
   } split //, $octets;
}


1;
__END__

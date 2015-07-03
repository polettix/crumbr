package Data::Crumbr::Default::JSON;

# ABSTRACT: "JSON" profile for Data::Crumbr::Default
use Data::Crumbr::Util;

sub profile {
   my $json_encoder = Data::Crumbr::Util::json_leaf_encoder();
   return {
      hash_open       => '{',
      hash_key_prefix => '',
      hash_key_suffix => ':',
      hash_close      => '}',

      array_open       => '[',
      array_key_prefix => '',
      array_key_suffix => '',
      array_close      => ']',

      keys_separator    => '',
      value_separator   => '',
      array_key_encoder => sub { },
      hash_key_encoder  => $json_encoder,
      value_encoder     => $json_encoder,
   };
} ## end sub profile

1;
__END__

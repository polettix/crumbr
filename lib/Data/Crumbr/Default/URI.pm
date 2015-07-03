package Data::Crumbr::Default::URI;

# ABSTRACT: "JSON" profile for Data::Crumbr::Default
use Data::Crumbr::Util;

sub profile {
   my $json_encoder = Data::Crumbr::Util::json_leaf_encoder();
   my $uri_encoder  = Data::Crumbr::Util::uri_encoder();
   return {
      hash_key_prefix   => '',
      hash_key_suffix   => '',
      array_key_prefix  => '',
      array_key_suffix  => '',
      keys_separator    => '/',
      value_separator   => ' ',
      array_key_encoder => $uri_encoder,
      hash_key_encoder  => $uri_encoder,
      value_encoder     => $json_encoder,
   };
} ## end sub profile

1;
__END__

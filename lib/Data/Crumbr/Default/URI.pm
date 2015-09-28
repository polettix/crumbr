package Data::Crumbr::Default::URI;

# ABSTRACT: "JSON" profile for Data::Crumbr::Default
use Data::Crumbr::Util;

sub profile {
   my $json_encoder = Data::Crumbr::Util::json_leaf_encoder();
   my $uri_encoder  = Data::Crumbr::Util::uri_encoder();
   return {
      array_open        => '',
      array_close       => '',
      array_key_prefix  => '',
      array_key_suffix  => '',

      hash_open         => '',
      hash_close        => '',
      hash_key_prefix   => '',
      hash_key_suffix   => '',

      keys_separator    => '/',
      value_separator   => ' ',

      array_key_encoder => $uri_encoder,
      hash_key_encoder  => $uri_encoder,
      value_encoder     => $json_encoder,
   };
} ## end sub profile

1;
__END__

=pod

=encoding utf-8

=head1 DESCRIPTION

Profile for URI encoder

=head1 INTERFACE

=over

=item B<< profile >>

   my $profile = Data::Crumbr::Default::URI->profile();

returns a default profile, i.e. encoder data to be used to instantiate a
Data::Crumbr::Default encoder. See L</Data::Crumbr> for details about
this profile.

=back

=cut

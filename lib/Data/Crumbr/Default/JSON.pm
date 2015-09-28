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

=pod

=encoding utf-8

=head1 DESCRIPTION

Profile for JSON encoder

=head1 INTERFACE

=over

=item B<< profile >>

   my $profile = Data::Crumbr::Default::JSON->profile();

returns a default profile, i.e. encoder data to be used to instantiate a
Data::Crumbr::Default encoder. See L</Data::Crumbr> for details about
this profile.

=back

=cut

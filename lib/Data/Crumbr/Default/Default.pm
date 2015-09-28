package Data::Crumbr::Default::Default;

# ABSTRACT: "Default" profile for Data::Crumbr::Default

# Default is default... nothing is set here!
sub profile { return {}; }

1;
__END__

=pod

=encoding utf-8

=head1 DESCRIPTION

Profile for default (exact) encoder

=head1 INTERFACE

=over

=item B<< profile >>

   my $profile = Data::Crumbr::Default::Default->profile();

returns a default profile, i.e. encoder data to be used to instantiate a
Data::Crumbr::Default encoder. See L</Data::Crumbr> for details about
this profile.

=back

=cut

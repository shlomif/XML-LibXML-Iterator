# $Id: Iterator.pm,v 1.1.1.1 2002/11/08 17:18:36 phish Exp $
#
package XML::LibXML::NodeList::Iterator;

use strict;
use XML::NodeFilter qw(:results);

use vars qw($VERSION);
$VERSION = "1.00";

use overload
  '++' => sub { $_[0]->next;     $_[0]; },
  '--' => sub { $_[0]->previous; $_[0] },
  '<>'  =>  sub {
      if ( wantarray ) {
          my @rv = ();
          while ( $_[0]->next ){ push @rv,$_;}
          return @rv;
      } else {
          return $_[0]->next
      };
  },
;

sub new {
    my $class = shift;
    my $list  = shift;
    my $self  = undef;
    if ( defined $list ) {
        $self = bless [
                       $list,
                       0,
                       [],
                      ], $class;
    }

    return $self;
}

sub set_filter {
    my $self = shift;
    $self->[2] = [ @_ ];
}

sub add_filter {
    my $self = shift;
    push @{$self->[2]}, @_;
}

# helper function.
sub accept_node {
    foreach ( @{$_[0][2]} ) {
        my $r = $_->accept_node($_[1]);
        return $r if $r;
    }
    # no filters or all decline ...
    return FILTER_ACCEPT;
}

sub first    { $_[0][1]=0;
               my $s = scalar(@{$_[0][0]});
               while ( $_[0][1] < $s ) {
                   last if $_[0]->accept_node($_[0][0][$_[0][1]]) == FILTER_ACCEPT;
                   $_[0][1]++;
               }
               return undef if $_[0][1] == $s;
               return $_[0][0][$_[0][1]]; }

sub last     {
    my $i = scalar(@{$_[0][0]})-1;
    while($i >= 0){
        if ( $_[0]->accept_node($_[0][0][$i] == FILTER_ACCEPT) ) {
            $_[0][1] = $i;
            last;
        }
        $i--;
    }

    if ( $i < 0 ) {
        # this costs a lot, but is more safe
        return $_[0]->first;
    }
    return $_[0][0][$i];
}

sub current  { return $_[0][0][$_[0][1]]; }
sub index    { return $_[0][1]; }

sub next     {
    if ( (scalar @{$_[0][0]}) <= ($_[0][1] + 1)) {
        return undef;
    }
    my $i = $_[0][1];
    while ( 1 ) {
        $i++;
        return undef if $i >= scalar @{$_[0][0]};
        if ( $_[0]->accept_node( $_[0][0]->[$i] ) == FILTER_ACCEPT ) {
            $_[0][1] = $i;
            last;
        }
    }
    return $_[0][0]->[$_[0][1]];
}

sub previous {
    if ( $_[0][1] <= 0 ) {
        return undef;
    }
    my $i = $_[0][1];
    while ( 1 ) {
        $i--;
        return undef if $i < 0;
        if ( $_[0]->accept_node( $_[0][0]->[$i] ) == FILTER_ACCEPT ) {
            $_[0][1] = $i;
            last;
        }
    }
    return $_[0][0][$_[0][1]];
}

sub iterate  {
    my $self = shift;
    my $funcref = shift;
    return unless defined $funcref && ref( $funcref ) eq 'CODE';
    $self->[1] = -1;
    my $rv;
    while ( $self->next ) {
        $rv = $funcref->( $self, $_ );
    }
    return $rv;
}

1;

=pod

=head1 NAME

XML::LibXML::NodeList::Iterator - Iteration Class for XML::LibXML XPath results

=head1 SYNOPSIS

  use XML::LibXML;
  use XML::LibXML::NodeList::Iterator;

  my $doc = XML::LibXML->new->parse_string( $somedata );
  my $nodelist = $doc->findnodes( $somexpathquery );

  my $iter= XML::LibXML::NodeList::Iterator->new( $nodelist );

  # more control on the flow
  while ( $iter->next ) {
      # do something
  }

  # operate on the entire tree
  $iter->iterate( \&operate );

=head1 DESCRIPTION

XML::LibXML::NodeList::Iterator is very similar to
XML::LibXML::Iterator, but it does not iterate on the tree structure
but on a XML::LibXML::NodeList object. Because XML::LibXML::NodeList
is basicly an array the functionality of
XML::LibXML::NodeList::Iterator is more restircted to stepwise
foreward and backward than XML::LibXML::Iterator is.

=head1 SEE ALSO

L<XML::LibXML::NodeList>, L<XML::NodeFilter>, L<XML::LibXML::Iterator>

=head1 AUTHOR

Christian Glahn, E<lt>christian.glahn@uibk.ac.atE<gt>

=head1 COPYRIGHT

(c) 2002, Christian Glahn. All rights reserved.

This package is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

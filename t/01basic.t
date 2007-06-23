use Test;

BEGIN { plan tests => 32; }

use XML::LibXML;
use XML::LibXML::Iterator;
use XML::LibXML::NodeList::Iterator;

my $doc = XML::LibXML->new->parse_string( <<EOF );
<test>
    text
    <foo/>
    <foo/>
    text
    <bar><kungfoo/></bar>
</test>
EOF


print "# TREE ITERATION\n";
my $iter = XML::LibXML::Iterator->new( $doc->documentElement );

do {
    ok(1); # warn $iter->current->nodeName;
}while ( $iter->next );

do {
    ok(1); # warn $iter->current->nodeName;
}while ( $iter->previous );


$iter->iterate( sub { ok(1) } );

$iter->first;
ok( $iter->current->nodeName, "test" );

my $n = $iter->last;
my $v;
eval {$v = XML::LibXML::LIBXML_VERSION(); };

if ( defined $v && $v > 20600 ) {
   ok( $iter->current->nodeName, "#text" );
}
else {
   ok( $iter->current->nodeName, "text" );
}


print "# LIST ITERATION\n";
my $nodelist = $doc->findnodes( '//foo' );
my $nliter = XML::LibXML::NodeList::Iterator->new( $nodelist );

while ( $nliter->next ) {
    ok(1);
}

$nliter->iterate( sub {ok(1)} );

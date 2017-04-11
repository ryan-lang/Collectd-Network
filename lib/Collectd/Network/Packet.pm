package Collectd::Network::Packet;

use Moo;
use Types::Standard -all;

has host => (
    is  => 'ro',
    isa => Str
);

has interval => (
    is  => 'ro',
    isa => Maybe [Int]
);

has interval_hires => (
    is  => 'ro',
    isa => Maybe [Num]
);

has time => (
    is  => 'ro',
    isa => Maybe [Int]
);

has time_hires => (
    is  => 'ro',
    isa => Maybe [Num]
);

has type => (
    is  => 'ro',
    isa => Maybe [Str]
);

has type_instance => (
    is  => 'ro',
    isa => Maybe [Str]
);

has plugin => (
    is  => 'ro',
    isa => Maybe [Str]
);

has plugin_instance => (
    is  => 'ro',
    isa => Maybe [Str]
);

has values => (
    is  => 'ro',
    isa => ArrayRef [HashRef]
);

1;

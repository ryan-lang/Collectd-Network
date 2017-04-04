package Collectd::Network::Packet;

use Moo;
use Types::Standard -all;

has host => (
    is  => 'ro',
    isa => Str
);

has interval => (
    is  => 'ro',
    isa => Int
);

has interval_hires => (
    is  => 'ro',
    isa => Num
);

has time => (
    is  => 'ro',
    isa => Int
);

has time_hires => (
    is  => 'ro',
    isa => Num
);

has type => (
    is  => 'ro',
    isa => Str
);

has type_instance => (
    is  => 'ro',
    isa => Str
);

has values => (
    is  => 'ro',
    isa => ArrayRef [HashRef]
);

1;

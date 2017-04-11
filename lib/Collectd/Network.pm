package Collectd::Network;

# ABSTRACT: Collectd network protocol implementation
our $VERSION = "0.02";

use strict;
use warnings;
use Moo;
use Kavorka;
use Carp;
use Data::Dump qw/dump/;
use Collectd::Network::Packet;

fun partTypes() {
    return {
        0   => 'host',
        1   => 'time',
        2   => 'plugin',
        3   => 'plugin_instance',
        4   => 'type',
        5   => 'type_instance',
        6   => 'values',
        7   => 'interval',
        8   => 'time_hires',
        9   => 'interval_hires',
        100 => 'message'
    };
}

fun partDecoders() {
    return {
        host            => \&_decodeString,
        time            => \&_decodeTime,
        plugin          => \&_decodeString,
        plugin_instance => \&_decodeString,
        type            => \&_decodeString,
        type_instance   => \&_decodeString,
        values          => \&_decodeData,
        interval        => \&_decodeInteger,
        time_hires      => \&_decodeTimeHires,
        interval_hires  => \&_decodeInteger,
        message         => \&_decodeString
    };
}

fun dataTypes() {
    return {
        0 => 'counter',
        1 => 'gauge',
        2 => 'derive',
        3 => 'absolute'
    };
}

fun dataDecoders() {
    return {
        counter  => \&_decodeCounter,
        gauge    => \&_decodeGauge,
        derive   => \&_decodeDerive,
        absolute => \&_decodeAbsolute
    };
}

method decodePacket ($data!) {
    my $packet = {};

    croak
        sprintf(
        "packet malformed - length %s is greater than maximum length 1452",
        length($data) )
        if length($data) > 1452;

    while ( length($data) > 0 ) {
        my ( $type, $length, $value ) = _parsePart($data);
        $$packet{ partTypes()->{$type} } = $value;
    }

    return Collectd::Network::Packet->new(%$packet);
}

fun _parsePart( $data !is alias ) {
	my $header_bits = substr( $data, 0, 4, "" );
	_validateLength( $header_bits, 4, "part header" );

    my ( $type, $length ) = unpack( 'nn', $header_bits );

    my $payload = substr( $data, 0, $length - 4, "" );
    _validateLength( $payload, $length - 4, "part payload" );

    my $decoder_name = partTypes()->{$type}
        || croak "cannot find part decoder for type '$type'";

    my $value = partDecoders()->{$decoder_name}->($payload);

    return ( $type, $length, $value );
}

fun _decodeString( $payload ! ) {
    return unpack( 'Z*', $payload );
}

fun _decodeInteger( $payload ! ) {
    return unpack( 'Q>', $payload );
}

fun _decodeTimeHires( $payload ! ) {
    my $int = _decodeInteger($payload);
    return $int >> 30;
}

fun _decodeData( $payload ! ) {
    my $bits = substr( $payload, 0, 2, "" );
    _validateLength( $bits, 2, "data value count header" );

    my ($value_count) = unpack( 'n', $bits );

    # parse the types
    my $types = [];
    while ( $value_count > 0 ) {
        push @$types, _decodeValueDataType($payload);
        $value_count--;
    }

    # parse the values
    my $values = [];
    foreach my $type (@$types) {
        push @$values, _decodeValueForType( $payload, $type );
    }

    return $values;
}

fun _decodeValueDataType( $payload !is alias ) {
    my $bits = substr( $payload, 0, 1, "" );
    _validateLength( $bits, 1, "data type header" );

    my ($data_type) = unpack( 'C', $bits );

    return $data_type;
}

fun _decodeValueForType( $payload !is alias, $data_type ! ) {
    my $decoder_name = dataTypes()->{$data_type}
        || croak "cannot find decoder for type '$data_type'";

    my $data = substr( $payload, 0, 8, "" );
    _validateLength( $data, 8, "data value payload" );

    my $value
        = dataDecoders()->{$decoder_name}->($data);

    return { data_type => dataTypes()->{$data_type}, value => $value };
}

fun _decodeCounter( $value ! ) {
    return unpack( 'Q>', $value );
}

fun _decodeGauge( $value ! ) {
    return unpack( 'd<', $value );
}

fun _decodeDerive( $value ! ) {
    return unpack( 'q>', $value );
}

fun _decodeAbsolute( $value ! ) {
    return unpack( 'Q>', $value );
}

fun _validateLength( $value !, $expected !, $decoding? ) {
    croak
        sprintf(
        "packet malformed - length %s does not equal expected length of %s%s",
        length($value), $expected, $decoding ? " when decoding $decoding" : "" )
        unless length($value) == $expected;
}

1;
__END__

=encoding utf-8
 
=head1 AUTHOR
 
Ryan Lang <rlang@me.com>
 
=cut

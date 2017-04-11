use Collectd::Network;
use Data::Dump qw/dump/;
use Test::More tests => 4;
use Test::Deep;
use Test::Exception;
use Try::Tiny;
use v5.14;
no if $] >= 5.018, warnings => "experimental";

my $svc = Collectd::Network->new();
my $bin = open( my $fh, '<', 't/bin/collectd.bin' );

my $n = 0;
while ( defined( my $row = <$fh> ) ) {
    chomp $row;

    my $packet;
    for ($n) {
        when (0) {
            $packet = $svc->decodePacket($row);
            cmp_deeply(
                $packet,
                Collectd::Network::Packet->new(
                    host            => "parkadmin.df",
                    interval_hires  => 10737418240,
                    time_hires      => 1491180309,
                    type            => "df_complex",
                    type_instance   => "reserved",
                    plugin          => 'df',
                    plugin_instance => 'root',
                    values => [ { data_type => "gauge", value => 0 } ]
                ),
                "decoded line $n correctly"
            );
        }
        when (1) {
            $packet = $svc->decodePacket($row);
            cmp_deeply(
                $packet,
                Collectd::Network::Packet->new(
                    host            => "parkadmin.df",
                    interval_hires  => 10737418240,
                    time_hires      => 1491180319,
                    type            => "percent",
                    type_instance   => "used",
                    plugin          => 'memory',
                    plugin_instance => '',
                    values          => [
                        { data_type => "gauge", value => 37.6926898956299 }
                    ]
                ),
                "decoded line $n correctly"
            );
        }
        when (2) {
            dies_ok {
                $packet = $svc->decodePacket($row);
            }
            "dies on incomplete packet on line $n";
        }
        when (3) {
            dies_ok {
                $packet = $svc->decodePacket($row);
            }
            "dies on incomplete packet on line $n";
        }
    }

    $n++;
}

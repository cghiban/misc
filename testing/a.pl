#!perl -w

use 5.14.0;
use strict;

use utf8;
#use charnames qw(:full :short);
use List::AllUtils qw/shuffle/;
use Data::Dumper;

my %symbols = (
    '♠' => 'Black spade suit',
    '♣' => 'Black club suit',
    '♥' => 'Black heart suit',
    '♦' => 'Black diamond suit'
);

my @colors = keys %symbols;

my $players = 3;
# 8*3 = 24
# 8*4 = 32
# 8*5 = 40

my @all_cards = map {$_ . ''} (2 .. 10, 'J', 'Q', 'K', 'A');
@all_cards = splice @all_cards, -2*$players;
my %val_cards = ();
for (my $i = 0; $i < @all_cards; $i++) {
    $val_cards{$all_cards[$i]} = $all_cards[0] + $i;
}

#for (sort {$val_cards{$a} <=> $val_cards{$b}} keys %val_cards) {
#    print " ", $_, " => ", $val_cards{$_}, "\n";
#}


my @suit = ();
my @rounds = ((1) x $players, 2, 3, 4, 5, 6, 7);
push @rounds, (8) x $players, reverse @rounds;

binmode STDOUT, ":utf8";
#print "@colors", $/;
#print "@all_cards\n";
#print "@rounds\n";


sub deal_hand {
    return splice @suit, 0, $players;
}
sub deal_cards {
    my ($cards_to_play) = shift;

    my @hands;# = ([]) x $players;
    for (1 .. $cards_to_play) {
        my @hcards = deal_hand;
        for (my $p = 0; $p < $players; $p++) {
            push @{$hands[$p]}, $hcards[$p];
            #print  " * pushed to player $p: ", $hcards[$p], $/;
        }
    }
    my $atu = splice @suit, 0, 1
        if @suit;

    return $atu, @hands;
}

sub rank_cards {
    my ($atu, @cards) = @_;

    my $a_color;
    if ($atu) {
        $a_color = $atu =~ s/[\d\w]//gr;
    }

    # if we don't have atu among our cards...
    unless ($a_color && grep {/$a_color/} @cards) {
        $a_color = $cards[0] =~ s/[\d\w]//gr;
    }
    #print $a_color, $/;

    my @ordered = ();
    #if ($atu) {
        @ordered = sort {
                $val_cards{substr($b, 0, -1)} <=> $val_cards{substr($a, 0, -1)}
            } grep {/$a_color/} @cards;
    #}
    push @ordered, grep {!/$a_color/} @cards;
    #push @ordered, sort {
    #            $val_cards{substr($b, 0, -1)} <=> $val_cards{substr($a, 0, -1)}
    #        } grep {!/$a_color/} @cards;

    return @ordered;
}


#my @ordered = rank_cards(undef, qw/9♥ 9♠ J♥ Q♠/);
#print "@ordered\n";
#__END__
#$DB::single = 1;
for (my $i = 0; $i < @rounds; $i++) {
    # re-init suit && shuffle
    @suit = map { my $c = $_; map {"$_$c"} @all_cards } @colors;
    @suit = shuffle @suit;
    print scalar(@suit), ": @suit\n";

    my ($atu, @hands) = deal_cards($rounds[$i]);
    print 'atu: ', $atu || "-", $/;
#print map {join " ", $_} @$_, "\n" for @hands;
#for my $ph (@hands) {
#    print " + \t", "@$ph", $/;
#}
#print "\n";

    for (my $ch = 0; $ch < $rounds[$i]; $ch++) {
        my @curr_hand = map { $_->[$ch] } @hands;
        #my @curr_hand =  @$curr_hand;
        print join ' ', @curr_hand;
        #print " => ";

        my @ordered = rank_cards($atu, @curr_hand);
        #print "@ordered";
        my $winner = 0;
        for (my $c = 0; $c < @curr_hand; $c++) {
            if ($ordered[0] eq $curr_hand[$c]) {
                $winner = $c;
                last;
            }
        }
        print " => player $winner / ", $curr_hand[$winner], $/;
    }
    print "=================================================\n";
    last if $rounds[$i] > 7;
}

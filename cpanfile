requires 'perl', '5.018004';

requires 'Moo';
requires 'Kavorka';
 
on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Compile';
};


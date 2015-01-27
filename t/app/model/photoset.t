use strict;
use warnings;
use Test::More;
use Test::Exception;
use utf8;

use FixMyStreet::App;
use Data::Dumper;
use DateTime;
use Path::Tiny 'path';

my $dt = DateTime->now;
my $c = FixMyStreet::App->new;
my $user = $c->model('DB::User')->find_or_create({
        name => 'Bob', email => 'bob@example.com',
});

sub make_report {
    my $photo_data = shift;
    return FixMyStreet::App->model('DB::Problem')->create({
        postcode           => 'BR1 3SB',
        bodies_str         => '',
        areas              => ",,",
        category           => 'Other',
        title              => 'test',
        detail             => 'test',
        used_map           => 't',
        name               => 'Anon',
        anonymous          => 't',
        state              => 'confirmed',
        confirmed          => $dt,
        lang               => 'en-gb',
        service            => '',
        cobrand            => 'default',
        cobrand_data       => '',
        send_questionnaire => 't',
        latitude           => '51.4129',
        longitude          => '0.007831',
        user => $user,
        photo => $photo_data,
    });
}


subtest 'Photoset with photo inline in DB' => sub {
    my $report = make_report( path('t/app/controller/sample.jpg')->slurp );
    my $photoset = $report->get_photoset($c);
    is $photoset->num_images, 1, 'Found just 1 image';
};

subtest 'Photoset with 1 referenced photo' => sub {
    my $report = make_report( '0123456789012345678901234567890123456789' );
    my $photoset = $report->get_photoset($c);
    is $photoset->num_images, 1, 'Found just 1 image';
};

subtest 'Photoset with 1 referenced photo' => sub {
    my $report = make_report( '0123456789012345678901234567890123456789,0123456789012345678901234567890123456789,0123456789012345678901234567890123456789' );
    my $photoset = $report->get_photoset($c);
    is $photoset->num_images, 3, 'Found 3 images';
};

done_testing();

#!/usr/bin/env perl
use Mojolicious::Lite -signatures;
use Mojo::Util qw(getopt);
use FindBin;
use lib "$FindBin::Bin/lib";
use TgaTools::Model::Tools;
use TgaTools::Model::ColorHelpers;
use TgaTools::Model::SGL;
use TgaTools::Model::Debug;

my $app_config = app->plugin(Config => {file => 'tga_tools.cfg'});
my $project_path = $app_config->{path};
my $in_img = $app_config->{in_img};
my $out_img= $app_config->{out_img};

# use command line to override defaults from config file
getopt 
    'p|path=s' => \$project_path,
    'in|in_image=s' => \$in_img,
    'out|out_img=s' => \$out_img;

my $img_config = app->plugin(Config => {file => $project_path."\\BG_CFG\\$in_img.cfg"});

say $app_config->{path};
say $project_path;

# Open the binary file for reading
my $filename   = $project_path."\\cd\\TEX\\$in_img.tga";
my $exportname = $project_path."\\".$out_img;


my ($file_size, $header) = TgaTools::Model::Tools::open_tga($filename);
my $unpacked_h = TgaTools::Model::Tools::unpack_header($header);
my ($color_map, $color_map_size) = TgaTools::Model::Tools::read_color_map($filename, $unpacked_h);


if ($app_config->{debug} == 1) {
    TgaTools::Model::Debug::print_header ($unpacked_h);
}

if ($app_config->{export_rgb_pal} == 1) {
    my ($color_map_entries_rgb) = TgaTools::Model::Tools::get_color_map_rgb24($color_map, $color_map_size);
    TgaTools::Model::SGL::rgb_palette ($color_map_entries_rgb, $project_path, $in_img, $img_config); # needed for rgb_palette
}

if ($app_config->{export_vdp2_pal} == 1) {
    my ($color_map_entries_vdp2) = TgaTools::Model::Tools::get_color_map_rgb15($color_map, $color_map_size);
    TgaTools::Model::SGL::vdp2_palette ($color_map_entries_vdp2, $project_path, $in_img); # doesn't work with RGB palette
}

if ($app_config->{export_image} == 1) {
    my ($img) = TgaTools::Model::Tools::read_tga_pixels($filename, $file_size, $unpacked_h, $app_config->{img_slice_height}, $app_config->{img_slice_width});
    TgaTools::Model::Debug::print_w_x_h ($unpacked_h);
    TgaTools::Model::Tools::save_tga($exportname, $unpacked_h, $color_map, $img);
}
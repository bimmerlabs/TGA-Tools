#!/usr/bin/env perl
use Mojolicious::Lite -signatures;
use FindBin;
use lib "$FindBin::Bin/lib";
use TgaTools::Model::Tools;
use TgaTools::Model::ColorHelpers;
use TgaTools::Model::SGL;
use TgaTools::Model::Debug;

my $app_config = app->plugin(Config => {file => 'tga_tools.cfg'});
my $img_config = app->plugin(Config => {file => $app_config->{path}."\\BG\\".$app_config->{in_img}.".cfg"});

# to export original height or width, enter 0.  
# otherwise, specify a max height/width (smaller than the original image)
my $img_slice_height = 0;
my $img_slice_width = 0;

# Open the binary file for reading
# my $filename = 'B:\SteamLibrary\steamapps\common\Sonic Mania\Data\Data\Stages\UFO1\8bpp\16x16Tiles.tga';
my $filename   = $app_config->{path}."\\cd\\TEX\\".$app_config->{in_img}.".tga";
my $exportname = $app_config->{path}."\\".$app_config->{out_img};


my ($file_size, $header) = TgaTools::Model::Tools::open_tga($filename);
my $unpacked_h = TgaTools::Model::Tools::unpack_header($header);
my ($color_map, $color_map_size) = TgaTools::Model::Tools::read_color_map($filename, $unpacked_h);


if ($app_config->{debug} == 1) {
    TgaTools::Model::Debug::print_header ($unpacked_h);
}

if ($app_config->{export_rgb_pal} == 1) {
    my ($color_map_entries_rgb) = TgaTools::Model::Tools::get_color_map_rgb24($color_map, $color_map_size);
    TgaTools::Model::SGL::rgb_palette ($color_map_entries_rgb, $app_config->{path}, $app_config->{in_img}, $img_config); # needed for rgb_palette
}

if ($app_config->{export_vdp2_pal} == 1) {
    my ($color_map_entries_vdp2) = TgaTools::Model::Tools::get_color_map_rgb15($color_map, $color_map_size);
    TgaTools::Model::SGL::vdp2_palette ($color_map_entries_vdp2, $app_config->{path}, $app_config->{in_img}); # doesn't work with RGB palette
}

if ($app_config->{export_image} == 1) {
    my ($img) = TgaTools::Model::Tools::read_tga_pixels($filename, $file_size, $unpacked_h, $img_slice_height, $img_slice_width);
    # # Print the array (optional)
    # for my $row (0 .. $unpacked_h->{'image_height'} -1) {
        # for my $col (0 .. $unpacked_h->{'image_width'} -1) {
            # printf "%02X", unpack('C', $img->[$row][$col]);
        # }
        # print "\n";
    # }

    # # Print the image data in reverse order
    # print "\nImage Data in Reverse Order:\n";
    # for (my $row = $unpacked_h->{'image_height'} -1; $row >= 0; $row--) {
        # for my $col (0 .. $unpacked_h->{'image_width'} -1) {
            # printf "0x%02X,", unpack('C', $img->[$row][$col]);
        # }
        # print "\n";
    # }
    TgaTools::Model::Debug::print_w_x_h ($unpacked_h);
    TgaTools::Model::Tools::save_tga($exportname, $unpacked_h, $color_map, $img);
}
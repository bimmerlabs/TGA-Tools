package TgaTools::Model::Debug;
use Mojo::Base -base, -signatures;

sub print_header ($unpacked_h) {
    printf "ID Length: %02X (1 byte)\n", $unpacked_h->{'id_length'};
    printf "Color Map Type: %02X (1 byte)\n", $unpacked_h->{'color_map_type'};
    printf "Image Type: %02X (1 byte)\n", $unpacked_h->{'image_type'};
    printf "First entry index: %04X (2 bytes)\n", $unpacked_h->{'color_map_first_entry_index'};
    printf "Color map length: %04X (2 bytes) = $unpacked_h->{'color_map_length'} (in decimal)\n", $unpacked_h->{'color_map_length'};
    printf "Color map entry size: %02X (1 byte)\n", $unpacked_h->{'color_map_entry_size'};
    printf "X-origin: %04X (2 bytes)\n", $unpacked_h->{'x_origin'};
    printf "Y-origin: %04X (2 bytes)\n", $unpacked_h->{'y_origin'};
    printf "Image width: %04X (2 bytes) = $unpacked_h->{'image_width'} (in decimal)\n", $unpacked_h->{'image_width'};
    printf "Image height: %04X (2 bytes) = $unpacked_h->{'image_height'} (in decimal)\n", $unpacked_h->{'image_height'};
    printf "Pixel depth: %02X (1 byte)\n", $unpacked_h->{'pixel_depth'};
    printf "Image descriptor: %02X (1 byte)\n", $unpacked_h->{'image_descriptor'};
}

sub print_w_x_h ($unpacked_h) {
    print "Image width * height: $unpacked_h->{'image_width'} * $unpacked_h->{'image_height'}\n";
}

1;
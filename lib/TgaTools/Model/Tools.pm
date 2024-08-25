package TgaTools::Model::Tools;
use Mojo::Base -base, -signatures;
use Fcntl qw(SEEK_SET SEEK_CUR SEEK_END);

my $header_length = 18;

sub open_tga ($filename) {
	open(my $fh, '<:raw', $filename) or die "Can't open $filename: $!";

	# Find the size of the file
	my $file_size = -s $fh;

	# Read the header (first 18 bytes)
	my $header;
	read($fh, $header, $header_length) or die "Cannot read header: $!";
	return ($file_size, $header);
	close($fh);
}

sub save_tga($new_filename, $unpacked_h, $color_map, $img) {
    # Open the new file for writing
    open(my $out_fh, '>:raw', $new_filename) or die "Can't open $new_filename: $!";

    # Write the header
    my $header = TgaTools::Model::Tools::pack_header($unpacked_h);
    print $out_fh $header;

    # Write the color map
    print $out_fh $color_map;

    # Write the image data
    for my $row (0 .. $unpacked_h->{'image_height'} -1) {
        for my $col (0 .. $unpacked_h->{'image_width'} -1) {
            print $out_fh $img->[$row][$col];
        }
    }

    # Close the output file handle
    close($out_fh);
    print "File exported to $new_filename\n";
}


sub unpack_header ($header) {
	my %header = (
	    id_length                => 0,
	    color_map_type           => 0,
	    image_type               => 0,
	    color_map_first_entry_index => 0,
	    color_map_length         => 0,
	    color_map_entry_size     => 0,
	    x_origin                 => 0,
	    y_origin                 => 0,
	    image_width              => 0,
	    image_height             => 0,
	    pixel_depth              => 0,
	    image_descriptor         => 0
	);

	(
	    $header{id_length},
	    $header{color_map_type},
	    $header{image_type},
	    $header{color_map_first_entry_index},
	    $header{color_map_length},
	    $header{color_map_entry_size},
	    $header{x_origin},
	    $header{y_origin},
	    $header{image_width},
	    $header{image_height},
	    $header{pixel_depth},
	    $header{image_descriptor}
	) = unpack('C C C v v C v v v v C C', $header);
	return (\%header);
}

sub pack_header ($unpacked_h) {
    return pack('C C C v v C v v v v C C',
        $unpacked_h->{'id_length'}, $unpacked_h->{'color_map_type'}, $unpacked_h->{'image_type'},
        $unpacked_h->{'color_map_first_entry_index'}, $unpacked_h->{'color_map_length'}, $unpacked_h->{'color_map_entry_size'},
        $unpacked_h->{'x_origin'}, $unpacked_h->{'y_origin'}, $unpacked_h->{'image_width'}, $unpacked_h->{'image_height'},
        $unpacked_h->{'pixel_depth'}, $unpacked_h->{'image_descriptor'}
    );
}

sub read_color_map ($filename, $unpacked_h) {
    # Calculate the color map size in bytes
    open(my $fh, '<:raw', $filename) or die "Can't open $filename: $!";
    my $color_map_size = $unpacked_h->{'color_map_length'} * $unpacked_h->{'color_map_entry_size'} / 8;
    my $color_map;
    # print "map size $color_map_size\n";
    seek($fh, $header_length, SEEK_SET) or die "Seek failed: $!";
    read($fh, $color_map, $color_map_size) or die "Cannot read color map: $!";
    return ($color_map, $color_map_size);
    close($fh);
}

# Convert the color map to a list of [R, G, B] arrays (24 bit)
sub get_color_map_rgb24 ($color_map, $color_map_size) {
    my @color_map_entries;
    for (my $i = 0; $i < $color_map_size; $i += 3) {
        my ($b, $g, $r) = unpack('C C C', substr($color_map, $i, 3));
        push @color_map_entries, [$r, $g, $b];
    }
    return (\@color_map_entries);
}

# Convert the color map to a list of 15-bit RGB arrays (15 bit)
sub get_color_map_rgb15 ($color_map, $color_map_size) {
    my @color_map_entries;
    for (my $i = 0; $i < $color_map_size; $i += 3) {
        my ($b, $g, $r) = unpack('C C C', substr($color_map, $i, 3));
        
        # Convert 24-bit RGB to 15-bit RGB
        my $r5 = ($r >> 3) & 0x1F;
        my $g5 = ($g >> 3) & 0x1F;
        my $b5 = ($b >> 3) & 0x1F;
        
        # Combine into a 15-bit value, setting the reserved bit to 1
        my $rgb15 = (1 << 15) | ($b5 << 10) | ($g5 << 5) | $r5;
        
        # Convert to little-endian
        my $le_rgb15 = pack('v', $rgb15);

        push @color_map_entries, $le_rgb15;
    }
    return (\@color_map_entries);
}

# Convert the color map to a list of 15-bit RGB arrays (15 bit)
sub read_tga_pixels ($filename, $file_size, $unpacked_h, $row_size = 0, $col_size = 0) {
    $row_size = $unpacked_h->{'image_height'} if $row_size == 0;
    $row_size--;
    $col_size = $unpacked_h->{'image_width'} if $col_size == 0;
    $col_size--;
    print "input row / col size $row_size $col_size\n";
    print "original row / col size $unpacked_h->{'image_height'} $unpacked_h->{'image_width'}\n";
    
    open(my $fh, '<:raw', $filename) or die "Can't open $filename: $!";
    # set up image structure
    my @img;
    for my $i (0 .. $row_size) {
        for my $j (0 .. $col_size) {
            $img[$i][$j] = 0;
        }
    }
    # Read the file from the end to the beginning
    my $row = $row_size;
    my $col = $col_size;
    for (my $pos = $file_size - 1; $pos >= 0; $pos--) {
        # Seek to the current byte position
        # printf "%X\n", $pos;
        seek($fh, $pos, SEEK_SET) or die "Seek failed: $!";
        
        # Read the byte
        my $pixel;
        read($fh, $pixel, 1) or die "Read failed: $!";
        
        # Store the byte value in the array
        $img[$row][$col] = $pixel;

        # Move to the next position in the array
        $col--;
        if ($col < 0) {
            $col = $col_size;
            $row--;
            last if $row < 0;  # Exit if the array is full
        }
    }

    # Close the file handle
    close($fh);
    
    # update image size
    $unpacked_h->{'image_width'} = scalar @{$img[0]};
    $unpacked_h->{'image_height'} = scalar @img;
    return (\@img);
}



1;
package TgaTools::Model::SGL;
use Mojo::Base -base, -signatures;

sub vdp2_palette ($color_map_entries, $path, $in_img) {
    my $filename = "$path\\$in_img.pal";
    open(my $out_fh, '>', $filename) or die "Can't open $filename: $!";
	# SGL / 15 bit
	print $out_fh "/**********************************************\n";
	print $out_fh " *	Copyright(C)SEGA 1996/SYSTEM R&D DEPT\n";
	print $out_fh " *	$in_img.pal\n";
	print $out_fh " *	START  = 0\n"; # color table (0-7)
	print $out_fh " *	TABLES = ".scalar $color_map_entries->@*."\n";
	print $out_fh " **********************************************/\n";
	print $out_fh "Uint16	pal_test[] = {\n";
	print $out_fh "/*0*/\n";
	for my $index (0..$#$color_map_entries) {
	    my $le_rgb15 = $color_map_entries->[$index];
	    my $rgb15 = unpack('v', $le_rgb15);
	    print  $out_fh "	" if (($index) % 8 == 0);
	    printf $out_fh "0x%04X,", $rgb15;
	    print  $out_fh "\n" if (($index + 1) % 8 == 0);
	}
	print $out_fh "};\n\n";
    close($out_fh);
    print "File exported to $filename\n";
}

sub rgb_palette ($color_map_entries, $path, $in_img, $config) {
    my $filename = "$path\\$in_img.h";
    open(my $out_fh, '>', $filename) or die "Can't open $filename: $!";
	    # number of palette entries per row
	    my $columns_per_row = 8;
	    
	    my $num_entries = $config->{palette_entries};
	    my $num_groups  = $config->{palette_groups} - 1;
	    # if $num_entries is not specified, use entire palette
	    $num_entries = scalar(@$color_map_entries) if $num_entries == 0;
	    $num_entries--;

	    print $out_fh "#include \"palette_config.h\"\n\n";
	    
	    print $out_fh "RgbPalette rgbPal = {\n";
	    print $out_fh "    { ";
	    for my $index (0..$num_entries) {
		my ($r, $g, $b) = @{$color_map_entries->[$index]};
		print $out_fh "{$r, $g, $b}";

		if ($index != $num_entries) {
		    print $out_fh ", ";
		}

		if (($index + 1) % $columns_per_row == 0 && $index != $num_entries) {
		    print $out_fh "\n      ";
		}
	    }
	    
	    print $out_fh " }\n";
	    print $out_fh "};\n\n";
	    
	    print $out_fh "RgbPalette originalPal = {\n";
	    print $out_fh "    { ";
	    for my $index (0..$num_entries) {
		my ($r, $g, $b) = @{$color_map_entries->[$index]};
		print $out_fh "{$r, $g, $b}";
		if ($index != $num_entries) {
		    print $out_fh ", ";
		}
		if (($index + 1) % $columns_per_row == 0 && $index != $num_entries) {
		    print $out_fh "\n      ";
		}
	    }
	    
	    print $out_fh " }\n";
	    print $out_fh "};\n\n";
	    
	    print $out_fh "HslPalette hslPal = {\n";
	    print $out_fh "    { ";
	    for my $index (0..$num_entries) {
		print $out_fh "{0, 0, 0}";
		if ($index != $num_entries) {
		    print $out_fh ", ";
		}
		if (($index + 1) % $columns_per_row == 0 && $index != $num_entries) {
		    print $out_fh "\n      ";
		}
	    }
	    
	    print $out_fh " }\n";
	    print $out_fh "};\n\n";

	    print $out_fh "PaletteGroupCollection p_collection = {\n";
	    print $out_fh "    {\n";
	    print $out_fh "        { 0,  0,  NUM_PALETTE_ENTRIES },\n";
	    if ($config->{palette_group} > 0) {
		    for my $group (0..$num_groups) {
			print $out_fh "        { ".$config->{palette_group}[$group][0].", "
						  .$config->{palette_group}[$group][1].", "
						  .$config->{palette_group}[$group][2]." },\n";
		    }
	    }
	    print $out_fh "    }\n";
	    print $out_fh "};\n\n";
	    
	    print $out_fh "static jo_palette bg_palette;\n\n";

	    print $out_fh "jo_palette	*my_bg_palette_handling(void)\n";
	    print $out_fh "{\n";
	    print $out_fh "    jo_create_palette(&bg_palette);\n";
	    print $out_fh "    return (&bg_palette);\n";
	    print $out_fh "}\n\n";

	    print $out_fh "void init_background(void) {\n";
	    print $out_fh "    jo_img_8bits    img;\n";
	    print $out_fh "    jo_set_tga_palette_handling(my_bg_palette_handling);\n";
	    print $out_fh "    img.data = JO_NULL;\n";
	    print $out_fh "    jo_tga_8bits_loader(&img, \"TEX\", \"".uc($in_img).".TGA\", 0);\n";
	    print $out_fh "    jo_vdp2_set_nbg1_8bits_image(&img, bg_palette.id, false);\n";
	    print $out_fh "    jo_free_img(&img);\n";
	    print $out_fh "}\n";

    close($out_fh);
    print "Background exported to $filename\n";
    
    # generate palette_config.h here
    $filename = "$path\\palette_config.h";
    open($out_fh, '>', $filename) or die "Can't open $filename: $!";
	    print $out_fh "// palette_config.h\n";
	    print $out_fh "#ifndef PALETTE_CONFIG_H\n";
	    print $out_fh "#define PALETTE_CONFIG_H\n\n";

	    print $out_fh "#define NUM_PALETTE_ENTRIES $num_entries\n";
	    print $out_fh "#define NUM_PALETTE_GROUPS ".($config->{palette_groups}+1)."\n\n";

	    print $out_fh "#endif // PALETTE_CONFIG_H\n";

    close($out_fh);
    print "Header exported to $filename\n";
    
    # generate palette_config.h here
    $filename = "$path\\background.h";
    open($out_fh, '>', $filename) or die "Can't open $filename: $!";
	    print $out_fh "// background.h\n";
	    print $out_fh "#ifndef BACKGROUND_H\n";
	    print $out_fh "#define BACKGROUND_H\n\n";

	    print $out_fh "#include \"".uc($in_img).".h\"\n\n";

	    print $out_fh "#endif // BACKGROUND_H\n";

    close($out_fh);
    print "Header exported to $filename\n";
}

1;
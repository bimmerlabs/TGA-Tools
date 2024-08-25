package TgaTools::Model::ColorHelpers;
use Mojo::Base -base, -signatures;
use List::Util 'min', 'max';

sub rgb_to_hsl ($rgb) {
    # Check if color is black
    return { h => 0, s => 0, l => 0 } if !$rgb->{r} && !$rgb->{g} && !$rgb->{b};

    # Calculate min and max values
    my $min = min($rgb->{r}, $rgb->{g}, $rgb->{b});
    my $max = max($rgb->{r}, $rgb->{g}, $rgb->{b});
    my $chroma = $max - $min;

    # If max equals min, it's a shade of gray
    return { h => 0, s => 0, l => $max } if $max == $min;

    # Calculate hue
    my $h;
    if ($rgb->{r} == $max) {
        $h = 60 * ($rgb->{g} - $rgb->{b}) / $chroma;
    } elsif ($rgb->{g} == $max) {
        $h = 60 * ($rgb->{b} - $rgb->{r}) / $chroma + 120;
    } else {
        $h = 60 * ($rgb->{r} - $rgb->{g}) / $chroma + 240;
    }
    $h += 360 if $h < 0; # Ensure hue is positive

    # Calculate saturation and luminance
    my $s = ($max == 0) ? 0 : 255 * $chroma / $max;
    my $l = $max;

    return { h => $h, s => $s, l => $l };
}

sub hsl_to_rgb ($hsl) {
    # If saturation is 0, it's a shade of gray
    return { r => $hsl->{l}, g => $hsl->{l}, b => $hsl->{l} } if $hsl->{s} == 0;

    # Calculate values
    my $s_adj = $hsl->{l} * $hsl->{s} / 255;
    my $p = $hsl->{l} - $s_adj;
    my $q = $hsl->{l} - ($s_adj * ($hsl->{h} % 60)) / 60;
    my $t = $hsl->{l} - ($s_adj * (60 - $hsl->{h} % 60)) / 60;

    # Calculate RGB based on hue
    my ($r, $g, $b);
    if ($hsl->{h} < 60) {
        ($r, $g, $b) = ($hsl->{l}, $t, $p);
    } elsif ($hsl->{h} < 120) {
        ($r, $g, $b) = ($q, $hsl->{l}, $p);
    } elsif ($hsl->{h} < 180) {
        ($r, $g, $b) = ($p, $hsl->{l}, $t);
    } elsif ($hsl->{h} < 240) {
        ($r, $g, $b) = ($p, $q, $hsl->{l});
    } elsif ($hsl->{h} < 300) {
        ($r, $g, $b) = ($t, $p, $hsl->{l});
    } else {
        ($r, $g, $b) = ($hsl->{l}, $p, $q);
    }

    return { r => $r, g => $g, b => $b };
}


1;
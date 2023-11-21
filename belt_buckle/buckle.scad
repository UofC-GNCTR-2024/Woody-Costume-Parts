include <BOSL2/std.scad>;
include <fillet.scad>;

$fn = 30;

// Fillet params
fillet_r = 4;
fillet_steps = 4;

// Plate parameters
plate_w = 77;
plate_l = 101;
plate_t = 2.5;
curve_r = 225;
rounding_d = 0.75;  // TODO: Set this

curve_fn = 500;  // TODO Set this
ellipse_fn = 100;

// Nub parameters
nub_h = 9;
nub_base_d = 5;
nub_ball_d = 4.5;
nub_arc = 10;
nub_angle = 5;

// Belt measurements
belt_w = 38;
belt_t = 3;  // TODO Check this?

// Rod Holder parameters
// This is how high the centre of the rod hole is
holder_h = 6;
holder_w = 10;
holder_t = 10;
hole_d = 3.5;  // TODO find welding rod diameter
// distance between belt and holder on either side
belt_holder_gap = 2;
holder_spacing = belt_w + 2*belt_holder_gap;

// Back text
line1 = "Toshi Taperek";
line2 = "UCalgary GNCTR 2023";
back_text_size = 2;
line_spacing = 2*back_text_size;
text_depth = 0.5;
include_signature = true;  // TODO: Enable (takes a lot of time)


module plate()
{
    minkowski() {
        // Plate
        rot([0, -90, -90])
        intersection() {
            difference() {
                // Front curve (outer)
                cylinder(
                    h=plate_w-rounding_d,
                    r=curve_r,
                    center=false,
                    $fn=curve_fn
                );
                // Back curve (inner)
                cylinder(
                    h=2*plate_w+1,
                    r=curve_r - (plate_t-rounding_d),
                    center=true,
                    $fn=curve_fn
                );
            }
            // Conical cutout
            up((plate_w-rounding_d)/2)
            yrot(90)
            resize([0, plate_l-rounding_d, 0])
            cylinder(
                h=curve_r,
                d1=0,
                d2=plate_w-rounding_d,
                center=false,
                $fn=ellipse_fn
            );
        }
        // Rounding sphere
        sphere(d=rounding_d);
    }
}

module nub()
{
    cylinder(
        h=nub_h,
        r1=nub_base_d/2,
        r2=0
    );
    up(nub_h - nub_ball_d/2)
    sphere(d=nub_ball_d);
}

module holder(capped)
{
    difference() {
        // Holder
        union() {
            cube([holder_w, holder_t, holder_h]);
            up(holder_h)
            ycyl(
                l=holder_t,
                d=holder_w,
                anchor=LEFT+FRONT
            );
        }
        // Hole
        translate([
            holder_w/2,
            capped ? holder_t : -1,
            holder_h
        ])
        ycyl(l=2*holder_t, d=hole_d, anchor=FRONT);
    }
}

module back_text()
{
    up(curve_r)
    yflip()
    cylindrical_extrude(
        ir=curve_r-plate_t,
        or=curve_r-plate_t+text_depth,
        orient=FWD,
        $fn=curve_fn/16  // TODO
    ) {
        // First line
        back(line_spacing/2)
        text(
            line1,
            size=back_text_size,
            font="DejaVu Sans:style=Bold",
            halign="center",
            valign="center"
        );
        // Second line
        fwd(line_spacing/2)
        text(
            line2,
            size=back_text_size,
            font="DejaVu Sans:style=Bold",
            halign="center",
            valign="center"
        );
    }
}

module buckle()
{
	myfillet(r=fillet_r, steps=fillet_steps) {
		difference() {
			// Plate
			zflip()
			down(curve_r + rounding_d/2)
			plate();
			if (include_signature) {
				// Debossed signature
				back(plate_w/2)
				back_text();
			}
		}

		// Features
		up(plate_t)
		// Top Holder
		back(plate_w/2 + holder_spacing/2)
		holder(false);
		
		// Bottom holder
		up(plate_t)
		back(plate_w/2 - holder_spacing/2 - holder_t)
		holder(true);
		
		// Nub
		up(plate_t)
        back(plate_w/2)
        // Nub position
        yrot(a=nub_arc, cp=[0, 0, curve_r])
        yrot(a=nub_angle)  // Extra angling
        nub();
	}
}


buckle();


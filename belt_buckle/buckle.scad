include <BOSL2/std.scad>;
include <fillet.scad>;
include <bend.scad>;

$fn = $preview ? 15 : 30;

// Fillet params
fillet_r = 4.25;
fillet_steps = $preview ? 4 : 6;

// Plate parameters
plate_w = 83;
plate_l = 110;
plate_t = 4;
curve_r = 225;

ellipse_fn = $preview ? 20 : 100;
bend_fn = $preview ? 8 : 25;
curve_fn = bend_fn/(plate_l/(2*PI*curve_r)) / 4;


// Nub parameters
nub_h = 9;
nub_base_d = 5;
nub_ball_d = 4.5;
nub_arc = 11.5;
nub_angle = 5;

// Belt measurements
belt_w = 38;
belt_t = 3;

// Bolt Holder parameters
// This is how high the centre of the bolt hole is
holder_h = 6;
holder_w = 9;
holder_t = 11;
holder_arc = 5.5;
hole_d = 3.5;
// distance between belt and holder on either side
belt_holder_gap = 2;
holder_spacing = belt_w + 2*belt_holder_gap;

// Back text
line1 = "Toshi Taperek";
line2 = "UCalgary GNCTR 2024";
back_text_size = 3;
line_spacing = 2*back_text_size;
text_depth = 0.5;
include_signature = true;

// Logo
y_padding = 10;
include_logo = true;

trim_w = 6;
trim_h = 2;
emboss_depth = 2;


module plate()
{
	zrot(90)
	down(trim_h)
	xrot(
		-360*plate_l/(2*PI*curve_r)/2,
		cp=[0, 0, curve_r]
	)
	cylindric_bend(
		[plate_w, plate_l, plate_t+trim_h],
		curve_r,
		$fn=bend_fn
	)
	up(plate_t+trim_h)
	zflip()
	{
		translate([plate_w/2, plate_l/2, 0])
		resize([plate_w, plate_l, plate_t])
		cyl(l=1, d=1, anchor=BOTTOM, $fn=ellipse_fn);
		
		/*
		color("red")
		translate([y_padding, plate_l/2, plate_t])
		xflip()
		resize([0, plate_w - 2*y_padding, 0], auto=true)
		zrot(90)
		left(88.25)
		linear_extrude(emboss_depth)
		import(
			"/home/toshi/gnctr/logo/logo_inside.svg"
		);*/
		
		translate([plate_w/2, plate_l/2, plate_t])
		resize([plate_w, plate_l, trim_h*2])
		torus(plate_w, trim_w/2, $fn=ellipse_fn);
	}
}


module nub()
{
    cylinder(
        h=nub_h,
        r1=nub_base_d/2,
        r2=0.5
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
            capped ? holder_t/4 : -1,
            holder_h
        ])
        ycyl(l=2*holder_t, d=hole_d, anchor=FRONT);
    }
}

module back_text()
{
	back(plate_w/2)
    up(curve_r)
    yflip()
    cylindrical_extrude(
        ir=curve_r-plate_t-1,
        or=curve_r-plate_t+text_depth,
        orient=FWD,
        $fn=curve_fn
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
	// Each feature to be filleted needs to be a separate child
	myfillet(r=fillet_r, steps=fillet_steps) {
		plate();
		
		// Top Holder
		up(plate_t)
		yrot(a=holder_arc, cp=[0, 0, curve_r])
		back(plate_w/2 + holder_spacing/2)
		holder(false);
		
		// Bottom holder
		up(plate_t)
		yrot(a=holder_arc, cp=[0, 0, curve_r])
		back(
			plate_w/2 - holder_spacing/2 - holder_t
		)
		holder(true);
		
		// Nub
		up(plate_t)
		back(plate_w/2)
		// Nub position
		yrot(a=-nub_arc, cp=[0, 0, curve_r])
		yrot(a=-nub_angle)  // Extra angling
		nub();
	}
}


module logo() {
	down(curve_r-plate_t)
	cylindrical_extrude(
		ir=curve_r-plate_t,
		or=curve_r-plate_t+emboss_depth,
		orient=BACK,
		$fn=curve_fn
	)
	back(10)
	//left(40.7)
	resize([0, plate_w - 2*y_padding, 0], auto=true)
	left(88.25)
	import("logo.svg");
}


module final()
{
	if (include_logo)
		logo();
	xflip()
	zflip()
	difference() {
		buckle();
		if (include_signature)
			back_text();
	}
}


final();

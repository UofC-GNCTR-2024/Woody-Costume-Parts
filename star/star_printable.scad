include <BOSL2/std.scad>;


difference() {
	union() {
		imp();

		linear_extrude(7) sherif_text_2d();
	}

	up(0.3)
	cuboid(
		[1000, 1000, 1000],
		anchor=TOP
	);


}


module sherif_text_2d() {
	intersection() {
		projection(cut=true) down(5) imp();

		circle(r=30);
	}

}

module imp() {
	import("star_orig.stl");
}

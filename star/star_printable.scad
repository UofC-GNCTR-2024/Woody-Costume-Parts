include <BOSL2/std.scad>;


difference() {
	import("star_orig.stl");

	up(0.3)
	cuboid(
		[1000, 1000, 1000],
		anchor=TOP
	);
}

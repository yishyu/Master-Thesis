shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = vec3((sin(TIME) + 1.0) / 2.0, (sin(1.3 * TIME) + 1.0) / 2.0, (sin(1.7 * TIME) + 1.0) / 2.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}

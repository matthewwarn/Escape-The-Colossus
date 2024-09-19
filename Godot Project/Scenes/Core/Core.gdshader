shader_type canvas_item;

void vertex() {
	
	float speed = 3.0;
	float height = 6.0;
	VERTEX.y +=  height *  sin(TIME * speed);
	
	
	
	
	// Called for every vertex the material is visible on.
}

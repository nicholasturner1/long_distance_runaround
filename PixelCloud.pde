class PixelCloud{

	//All mechanisms below result in a PImage for
	// display defined here
	PImage result;

	//The argb values for each pixel
	color[] pixel_array;
	//Whether or not a pixel is subject to
	// environmental forces
	boolean[] mobile;

	//Original dimensions of the image
	// (useful for defining location PVectors, etc.)
	int orig_width;
	int orig_height;

	//Particle information for each pixel
	PVector[] accelerations;
	PVector[] velocities;
	PVector[] locations;

	int mass = 15;

	PixelCloud(int num_pixels){
		//Constructor for debugging - only creates n pixels

		initResult();
		initMobile(num_pixels);

		orig_width = num_pixels;

		initDebugPixelArray(num_pixels);
		initLocations(num_pixels, int(width/2), int(height/2));
		initVelocities(num_pixels);
		initAccelerations(num_pixels);

		updateResultPixels();
	}

	PixelCloud(PImage img){
		//Constructor with default offset (0,0)

		img.loadPixels();
	
		orig_width = img.width;
		orig_height = img.height;

		pixel_array = img.pixels;

		initResult();
		initMobile(pixel_array.length);

		//Using default offset
		initLocations(pixel_array.length, 0, 0);
		initVelocities(pixel_array.length);
		initAccelerations(pixel_array.length);

		updateResultPixels();
	}

	PixelCloud(PImage img, int x_offset, int y_offset){
		//Constructor with custom offset 

		img.loadPixels();

		orig_width = img.width;
		orig_height = img.height;

		pixel_array = img.pixels;

		initResult();
		initMobile(pixel_array.length);

		initLocations(pixel_array.length, x_offset, y_offset);
		initVelocities(pixel_array.length);
		initAccelerations(pixel_array.length);

		updateResultPixels();
	}

	void initResult(){
		//Initializes Result PImage as a 'translucent black' background

		result = createImage(width, height, ARGB);

		result.loadPixels();

		int total_pixels = width*height;

		for (int i=0; i < total_pixels; i++){
			result.pixels[i] = color(0,0,0,0);
		}
	}

	void initMobile(int num_pixels){
		//Initializes mobile array so all pixels are initially fixed

		mobile = new boolean[num_pixels];
		for (int i=0; i < num_pixels; i++){
			mobile[i] = false;
		}
	}

	void initLocations(int num_pixels, int x_offset, int y_offset){
		//Initializes Location array to the original pixel locations
		// given a specific offset

		locations = new PVector[num_pixels];

		for (int i=0; i < num_pixels; i++){
			//generally, position within a PImage
			// is a 1d array where index = x + width*y
			//
			// this simply reverses that process
			int x_coord = (i % orig_width) + x_offset;
			int y_coord = (i / orig_width) + y_offset;

			locations[i] = new PVector(x_coord, y_coord);
		}
	}

	void initVelocities(int num_pixels){
		//Initializes velocities to 0

		velocities = new PVector[num_pixels];

		for(int i=0; i < num_pixels; i++){
			velocities[i] = new PVector(0,0);
		}
	}

	void initAccelerations(int num_pixels){
		//Initialized accelerations to 0

		accelerations = new PVector[num_pixels];

		for(int i=0; i < num_pixels; i++){
			accelerations[i] = new PVector(0,0);
		}
	}

	void initDebugPixelArray(int num_pixels){

		pixel_array = new color[num_pixels];
		for(int i=0; i < num_pixels; i++){
			pixel_array[i] = color(255,255,255,100);
		}
	}

	void updateResultPixels(){
		//Given updates to the pixel location, this function
		// updates the result PImage to reflect the changes

		result.loadPixels();

		int total_pixels = width*height;

		//First wipes out all old values
		//there are probably better ways to do this?
		// (though this seems tolerably fast)
		for (int i=0; i < total_pixels; i++){
			result.pixels[i] = color(0,0,0,0);
		}

		for (int i=0; i < pixel_array.length; i++){
			//converting location coords to result index

			//only displays a pixel if its within the image
			if(location_in_bounds(i)){
				
				int result_loc = floor(locations[i].x) + floor(locations[i].y)*width;

				//assigning color
				float r = red(pixel_array[i]);
				float g = green(pixel_array[i]);
				float b = blue(pixel_array[i]);
				result.pixels[result_loc] = color(r,g,b,255);
				
			}

		}
		result.updatePixels();
	}

	boolean location_in_bounds(int pixel_index){
		return (locations[pixel_index].x >= 0 &&
				locations[pixel_index].x <= width &&
				locations[pixel_index].y >= 0 &&
				locations[pixel_index].y <= height);
	}

	void makeRandomMobile(){
		//Selects a random pixel, and allows it to move by environmental
		// forces
		int selection = int(random(pixel_array.length));

		mobile[selection] = true;
	}

	void applyForce(PVector f){
		//applies a force to ALL of the mobile pixels uniformly

		PVector force = PVector.div(f,mass);
		for(int i=0; i < pixel_array.length; i++){
			if (mobile[i]){
				accelerations[i].add(force);
			}
		}
	}

	void applyAttractor(PVector att_location, float att_mass){
		//applies an attraction from a specific location to each
		// mobile pixel

		for(int i=0; i < pixel_array.length; i++){
			if(mobile[i]){
				PVector dir = PVector.sub(att_location, locations[i]);
				float distance = constrain(dir.mag(),1,5);
				dir.normalize();

				dir.mult((att_mass) / (distance * distance));
				accelerations[i].add(dir);
			}
		}
	}

	void applyWhirlwind(Whirlwind w){

		for(int i=0; i < pixel_array.length; i++){
			if(mobile[i] ){//&& within_radius(w,i)){

			}
		}
	}

	void update(){

		// println("Acceleration:");
		// println(accelerations[0].y);
		// println("Velocity:");
		// println(velocities[0].y);
		// println("Location:");
		// println(locations[0].y);
		// println(location_in_bounds(0));
		for(int i=0; i < pixel_array.length; i++){
			if (mobile[i] && location_in_bounds(i)){
				velocities[i].add(accelerations[i]);
				locations[i].add(velocities[i]);
			}

			accelerations[i].mult(0);
		}
		updateResultPixels();

	}

	void draw(){
		image(result,0,0);
	}
}
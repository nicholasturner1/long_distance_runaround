//GLOBAL VARIABLES
//Pixel Cloud Instances
PixelCloud pc;
PixelCloud pc2;

//Force Objects
PVector att_loc;
PVector wind;

//How many pixels start moving per frame
int mobile_per_frame;

void setup(){

	size(1000,500,P2D);

	mobile_per_frame = 10;

	//Loading Image Clouds
	PImage img = loadImage("eagle.jpg");
	img.resize(250,250);

	pc = new PixelCloud(img, 500, 0);
	pc2 = new PixelCloud(img);

	//Init Forces
	wind = new PVector(0,1);
	att_loc = new PVector(width/2, height/2);

}

void draw(){
	background(0);

	for (int i=0; i < mobile_per_frame; i++){
		pc.makeRandomMobile();
		pc2.makeRandomMobile();
	}
	//Rotating wind vector
	// (not sure if this is the right strategy here)
	// float rotation_angle = random(0.05,0.10);
	// wind.rotate(rotation_angle);

	//Applying forces
	pc.applyForce(wind);
	pc2.applyForce(wind);
	pc.applyAttractor(att_loc, 2);
	pc2.applyAttractor(att_loc, 0.5);

	//Calling updates
	pc.update();
	pc2.update();
	pc.draw();
	pc2.draw();
}
//Good idea in principle but theres a lot of jitter. Could try to smooth angle changes, but it's going to be too much work;

close("clippedStack");
selectWindow("tempDuplicate")
//get info from original image 
nS = nSlices;

//create clippedStack
w = 350;
h = 350
newImage("clippedStack", "8-bit black", w, h, 1, 1, nS);
setLocation(600,150);

//wLabel = w - 50;
//hLabel = h - 50;
//run("Label...", "format=00:00 starting=0.00 interval=0.05 x=&wLabel y=&hLabel font=18 text=min range=1-2400 use use_text");

rhoA = newArray(nS);
for (z_index=0; z_index<nS; z_index++) {
	selectWindow("Dup");
	setSlice(z_index+1);
	eyeX = (getResult("X", z_index+(nS*1)) + getResult("X", z_index+(nS*2)))/2;
	rhoX = (eyeX + getResult("X", z_index+(nS*0)))/2;
	eyeY = (getResult("Y", z_index+(nS*1)) + getResult("Y", z_index+(nS*2)))/2;
	rhoY = (eyeY + getResult("Y", z_index+(nS*0)))/2;
	
	
//	if (z_index < nS-5) {
//		rhoA[z_index] = ( getResult("Angle", z_index) + getResult("Angle", z_index+1) +  getResult("Angle", z_index+2) + getResult("Angle", z_index+3) + getResult("Angle", z_index+4) ) / 5;
//	}
//	else {
//		rhoA[z_index] = getResult("Angle", z_index+(nS*0));
//	}
//	if (eyeY > rhoY) {
//		rhoA[z_index] = -rhoA[z_index];
//	}
//	print("eyeX = " + eyeX +"; eyeY = " + eyeX);
//	print("rhoX = " + rhoX +"; rhoY = " + rhoY);
//	radA = rhoA[z_index] * PI/180;
////	radA = 0;
//	
//	ulX = (-w/2) * cos(radA) - (-h/2) * sin(radA) + rhoX;
//	ulY = (-w/2) * sin(radA) + (-h/2) * cos(radA) + rhoY;
//
//	urX = (w/2) * cos(radA) - (-h/2) * sin(radA) + rhoX;
//	urY = (w/2) * sin(radA) + (-h/2) * cos(radA) + rhoY;
//
//	brX = (w/2) * cos(radA) - (h/2) * sin(radA) + rhoX;
//	brY = (w/2) * sin(radA) + (h/2) * cos(radA) + rhoY;
//
//	blX = (-w/2) * cos(radA) - (h/2) * sin(radA) + rhoX;
//	blY = (-w/2) * sin(radA) + (h/2) * cos(radA) + rhoY;
//	
//	makePolygon(ulX, ulY, urX, urY, brX, brY, blX, blY);

	makeOval(rhoX-w/2, rhoY-h/2, 350, 350);

	run("Copy");			//copy plot window content
	selectImage("clippedStack");
	setSlice(z_index+1);
	run("Paste");
	
}

//selectImage("clippedStack");
//run("Select None");
//for (z_index=0; z_index<nS; z_index++) {
//	setSlice(z_index+1);
//	radA = 180-rhoA[z_index];
//	run("Rotate... ", "angle=&radA grid=1 interpolation=Bilinear fill");
//}
	
	

	
close("eyeTrack");
close("eyeTrackR");
close("eyeTrackL");
close("eyePhi");
close("aniPlot");
close("Dup");
//get info from original image 
fName = replace(getTitle, ".tif", "");
fPath = getDirectory("image");
nS = nSlices;
getDimensions(w, h, channels, slices, frames);
run("Select None");
run("Duplicate...", "title=Dup duplicate");
close(fName + ".tif");
wLabel = w -150;
hLabel = h - 50;
run("Label...", "format=00:00 starting=0.00 interval=0.05 x=&wLabel y=&hLabel font=24 text=min range=1-2400 use use_text");

drawContour = false;

//Load results
tPath = fPath + "OKR_" + fName + ".txt";
run("Clear Results");
if (!File.exists(tPath)) {exit("Run OKREllipseFitting first");}
run("Results... ", "open=&tPath");

//create stack for right Eye
newImage("eyeTrackR", "8-bit black", w, h, 1, 1, nS);
run("Line Width...", "line=2");
run("Green");

for (z_index=0; z_index<nS; z_index++) {
	setSlice(z_index+1);
	eyeR_x = getResult("rX",z_index); //get latest centroid fit
	eyeR_y = getResult("rY",z_index); //get latest centroid fit
	eyeR_r1 = getResult("rMajor",z_index); //get latest centroid fit
	eyeR_r2 = getResult("rMinor",z_index); //get latest centroid fit

	if (drawContour){
		// draw ellipse contour
		eyeR_angle = 180-getResult("rAngle",z_index);
		run("Specify...", "width=&eyeR_r1 height=&eyeR_r2 x=&eyeR_x y=&eyeR_y oval centered");
		run("Rotate...", "angle=&eyeR_angle");
		run("Draw", "slice");
	}
	else {
		//draw ellipse axis
		eyeR_angle = getResult("rAngle",z_index) * PI/180;
		makeLine(eyeR_x+cos(eyeR_angle)*eyeR_r1/2, eyeR_y-(sin(eyeR_angle)*eyeR_r1/2), eyeR_x-(cos(eyeR_angle)*eyeR_r1/2), eyeR_y+(sin(eyeR_angle)*eyeR_r1/2));
		run("Fill", "slice");
		makeLine(eyeR_x+cos(eyeR_angle+PI/2)*eyeR_r2/2, eyeR_y-(sin(eyeR_angle+PI/2)*eyeR_r2/2), eyeR_x-(cos(eyeR_angle+PI/2)*eyeR_r2/2), eyeR_y+(sin(eyeR_angle+PI/2)*eyeR_r2/2));
		run("Fill", "slice");
	}
	
}

//create stack for left Eye
newImage("eyeTrackL", "8-bit black", w, h, 1, 1, nS);
run("Line Width...", "line=2");
run("Magenta");

for (z_index=0; z_index<nS; z_index++) {
	setSlice(z_index+1);
	eyeL_x = getResult("lX",z_index);
	eyeL_y = getResult("lY",z_index);
	eyeL_r1 = getResult("lMajor",z_index);
	eyeL_r2 = getResult("lMinor",z_index);
	
	if (drawContour){
		// draw ellipse contour
		eyeL_angle = 180-getResult("lAngle",z_index);
		run("Specify...", "width=&eyeL_r1 height=&eyeL_r2 x=&eyeL_x y=&eyeL_y oval centered");
		run("Rotate...", "angle=&eyeL_angle");
		run("Draw", "slice");
	}
	else {
		//draw ellipse axis
		eyeL_angle = getResult("lAngle",z_index) * PI/180;
		makeLine(eyeL_x+cos(eyeL_angle)*eyeL_r1/2, eyeL_y-(sin(eyeL_angle)*eyeL_r1/2), eyeL_x-(cos(eyeL_angle)*eyeL_r1/2), eyeL_y+(sin(eyeL_angle)*eyeL_r1/2));
		run("Fill", "slice");
		makeLine(eyeL_x+cos(eyeL_angle+PI/2)*eyeL_r2/2, eyeL_y-(sin(eyeL_angle+PI/2)*eyeL_r2/2), eyeL_x-(cos(eyeL_angle+PI/2)*eyeL_r2/2), eyeL_y+(sin(eyeL_angle+PI/2)*eyeL_r2/2));
		run("Fill", "slice");
	}
}

run("Merge Channels...", "c2=eyeTrackR c4=Dup c6=eyeTrackL create");
run("RGB Color", "frames");
rename("eyeTrack");


// re-recover angles
eyeR_angle = newArray(nS); 
eyeL_angle = newArray(nS);
tAxis = newArray(nS);
for (i=0; i<nS; i++) {
	eyeR_angle[i] = getResult("rAngle",i);
	eyeL_angle[i] = getResult("lAngle",i);
	tAxis[i] = getResult("tAxis", i);
}
// this seems to work if original movie is 1024 x 544
run("Plots...", "width=930 height=280 font=22 draw draw_ticks minimum=0 maximum=0 interpolate");
// set up stack window for animated plot
newImage("aniPlot", "RGB black", w, w/3, 1, 1, nS);

for (i=0; i<nS; i++) {
	Plot.create("eyePhi", "time (s)", "eye angle (deg)")
	Plot.setLineWidth(1);
	Plot.setColor("#609f60");
	Plot.add("line",tAxis,eyeR_angle);
	Plot.setColor("#9f609f");
	Plot.add("line",tAxis,eyeL_angle);
	Plot.setLimits(0,tAxis[nS-1]+0.01,-50.0,50.0);
	Plot.setLineWidth(4);
	Plot.setColor("green");
	Plot.add("line",Array.trim(tAxis,i+1),Array.trim(eyeR_angle,i+1));
	Plot.setColor("magenta");
	Plot.add("line",Array.trim(tAxis,i+1),Array.trim(eyeL_angle,i+1));
	Plot.show();
	selectImage("eyePhi");
//	run("Size...", "width=&plW height=&plH depth=1 average interpolation=Bilinear");

	
	

	run("Copy");			//copy plot window content
	run("Close");			//close the plot window
	selectImage("aniPlot");
	setSlice(i+1);
	run("Paste");
}


run("Combine...", "stack1=eyeTrack stack2=aniPlot combine");
rename("eyeTrack");
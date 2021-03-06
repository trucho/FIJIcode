// Use this to change slices to frames but check frame interval first. Also removes weird scaling from uEye camera
//run("Properties...", "channels=1 slices=1 frames=2400 unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1.0000 frame=[50.00 msec]");

//getDimensions(w, h, channels, slices, frames);
//w = w -150;
//h = h - 50;
//run("Label...", "format=00:00 starting=0.00 interval=0.05 x=&w y=&h font=24 text=min range=1-2400 use use_text");

run("Clear Results");
close("Dup");
close("eyePhi");
//#@ Integer (label="Tolerance", style="slider", min=0, max =100, value=17) userTol
userTol=17; //wandTolerance
ifi = 50/1000; //interframe interval
fName = replace(getTitle, ".tif", "")
fPath = getDirectory("image");
nS = nSlices;

tPath = fPath + "OKR_" + fName + ".txt";
// Check if analysis is already done and give option to quit
Proceed = true;
if (File.exists(tPath)) {Proceed = getBoolean("Analysis already done. Proceed and OVERWRITE?");}
if (!Proceed) {exit("USER cancelled! Good bye!");}


run("Select None");
run("Clear Results");
run("Set Measurements...", "stack area centroid fit redirect=None decimal=3");
setTool("wand");
run("Wand Tool...", "tolerance=&userTol mode=Legacy");

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// USER input
waitForUser("Click on Swim Bladder");
run("Measure");
waitForUser("Click on LEFT eye");
run("Measure");
//get initial conditions
eyeR_x_ini = getResult("X",0);
eyeR_y_ini = getResult("Y",0);
eyeR_area_cutoff = getResult("Area",0)*1.2;

eyeL_x_ini = getResult("X",1);
eyeL_y_ini = getResult("Y",1);
eyeL_area_cutoff = getResult("Area",1)*1.2;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//// Hard-coded
//eyeR_x_ini = 667;
//eyeR_y_ini = 250;
//eyeR_area_cutoff = 2356*1.2;
//
//eyeL_x_ini = 667;
//eyeL_y_ini = 311;
//eyeL_area_cutoff = 2272*1.2;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////




interrupt = false;
interruptBuffer = 5;
interruptCounter = interruptBuffer;

run("Select None");
run("Clear Results");
run("Set Measurements...", "stack area centroid fit redirect=None decimal=3");
setTool("wand");
run("Wand Tool...", "tolerance=&userTol mode=Legacy");

//create new stack to draw fits and check quality
run("Duplicate...", "title=Dup duplicate");
setForegroundColor(255, 255, 255);
setTool("wand");

// create variables to store in csv
// Right eye
eyeR_time = newArray(nS);
eyeR_x = newArray(nS);
eyeR_y = newArray(nS);
eyeR_major = newArray(nS);
eyeR_minor = newArray(nS);
eyeR_angle = newArray(nS);
eyeR_area = newArray(nS);
// Left eye
eyeL_time = newArray(nS);
eyeL_x = newArray(nS);
eyeL_y = newArray(nS);
eyeL_major = newArray(nS);
eyeL_minor = newArray(nS);
eyeL_angle = newArray(nS);
eyeL_area = newArray(nS);

//set up iteratively updated variables for wand command
eyeR_x_now = eyeR_x_ini;
eyeR_y_now = eyeR_y_ini;

eyeL_x_now = eyeL_x_ini;
eyeL_y_now = eyeL_y_ini;

//analyse all frames
//Right Eye
for (i=0; i<nS; i++) {
	setSlice(i+1); //slice index starts at 1
	doWand(eyeR_x_now, eyeR_y_now, userTol, "Legacy");
	run("Fit Ellipse");
	run("Measure");
	eyeR_time[i] = i*ifi; //time axis
	eyeR_x[i] = getResult("X"); //get latest centroid X
	eyeR_y[i] = getResult("Y"); //get latest centroid Y
	eyeR_major[i] = getResult("Major"); //get latest major axis
	eyeR_minor[i] = getResult("Minor"); //get latest minor axis
	eyeR_angle[i] = getResult("Angle"); //get latest angle
	eyeR_area[i] = getResult("Area"); //get latest area

	//check if fit was lost
	if (eyeR_area[i] > eyeR_area_cutoff || abs(eyeR_x[i]-eyeR_x_now) > 20 || abs(eyeR_y[i]-eyeR_y_now) > 20) {
		// if fit was lost track for a little bit
		interrupt = true;
 		interruptCounter = interruptCounter-1;
 		// then stop checking
 		if (interruptBuffer < 0) {
 			interrupt = false;
 		}
	}
 	else {
		interruptCounter = interruptBuffer;
		interrupt = false;
	}
	
	
	if (interrupt) {
		print (interruptBuffer);
 		Table.deleteRows(i, i);
 		waitForUser("Click on RIGHT eye");
 		run("Fit Ellipse");
 		run("Measure");
 		eyeR_time[i] = i*ifi; //time axis
 		eyeR_x[i] = getResult("X"); //get latest centroid X
 		eyeR_y[i] = getResult("Y"); //get latest centroid Y
 		eyeR_major[i] = getResult("Major"); //get latest major axis
 		eyeR_minor[i] = getResult("Minor"); //get latest minor axis
 		eyeR_angle[i] = getResult("Angle"); //get latest angle
 		eyeR_area[i] = getResult("Area"); //get latest area
 	}
 	
	// fix angles
	if (eyeR_angle[i]>90) {
 		eyeR_angle[i] = eyeR_angle[i]-180;
 	}
 	// update values
 	eyeR_x_now = getResult("X"); //get latest centroid X
	eyeR_y_now = getResult("Y"); //get latest centroid Y
	// draw ellipse
	run("Draw", "slice");
}



setTool("rectangle");
run("Select None");


//Create plot of eye angles
Plot.create("eyePhi", "time (s)", "eye angle (deg)")
Plot.setLineWidth(2);
Plot.setColor("green");
Plot.add("line",eyeR_time,eyeR_angle);
Plot.setColor("magenta");
Plot.add("line",eyeL_time,eyeL_angle);
Plot.setLimits(0,eyeL_time[nS-1],-50.0,50.0);
Plot.addLegend("R eye\nL eye", "Top-Right Bottom-To-Top Transparent");







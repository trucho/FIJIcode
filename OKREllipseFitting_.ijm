// Use this to change slices to frames but check frame interval first. Also removes weird scaling from uEye camera
//run("Properties...", "channels=1 slices=1 frames=2400 unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1.0000 frame=[50.00 msec]");

//getDimensions(w, h, channels, slices, frames);
//w = w -150;
//h = h - 50;
//run("Label...", "format=00:00 starting=0.00 interval=0.05 x=&w y=&h font=24 text=min range=1-2400 use use_text");

//Macro to track zebrafish larval eyes by iteratively fitting ellipses
// created Mar 20 2020 (angueyra@nih.gov)
// update Mar 27 2020: 
//			introduced interruption for manual correction is significant displacement in area, position or eye overlap
// update Mar 30 2020
//			introduced tracking of swim bladder to derive body axis to make relative eye angle measurements rather than arbitrary

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SetUp
run("Clear Results");
close("Dup");
close("eyePhi");
//#@ Integer (label="Tolerance", style="slider", min=0, max =100, value=17) userTol
userTol=17; //wandTolerance
sbTol = 28; //wandTolerance for swim bladder
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
//get initial conditions

//USER input
waitForUser("Click on LEFT eye");
run("Measure");
eyeL_x_ini = getResult("X");
eyeL_y_ini = getResult("Y");
eyeL_area_cutoff = getResult("Area",0)*1.2;
eyeL_dxWand=(cos(getResult("X"))*getResult("Major")/2)*0.5;
eyeL_dyWand=-(sin(getResult("X"))*getResult("Major")/2)*0.5;

waitForUser("Click on RIGHT eye");
run("Measure");
eyeR_x_ini = getResult("X");
eyeR_y_ini = getResult("Y");
eyeR_area_cutoff = getResult("Area")*1.2;
eyeR_dxWand=(cos(getResult("X"))*getResult("Major")/2)/2;
eyeR_dyWand=-(sin(getResult("X"))*getResult("Major")/2)/2;

waitForUser("Click on SWIM BLADDER");
run("Find Maxima...", "prominence=10 light output=[Point Selection]");
getSelectionCoordinates(sb_x_ini, sb_y_ini);
sb_x_ini = sb_x_ini[0];
sb_y_ini = sb_y_ini[0];
doWand(sb_x_ini, sb_y_ini, sbTol, "Legacy");
run("Fit Ellipse");
run("Measure");
sb_area_cutoff = getResult("Area")*1.2;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//// Hard-coded
//eyeL_x_ini = 667;
//eyeL_y_ini = 250;
//eyeL_area_cutoff = 2356*1.2;
//
//eyeR_x_ini = 667;
//eyeR_y_ini = 311;
//eyeR_area_cutoff = 2272*1.2;
//
//sb_x_ini = 667;
//sb_y_ini = 311;
//sb_area_cutoff = 2272*1.2;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Start frame-by-frame-analysis
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
// Left eye
eyeL_time = newArray(nS);
eyeL_x = newArray(nS);
eyeL_y = newArray(nS);
eyeL_major = newArray(nS);
eyeL_minor = newArray(nS);
eyeL_angle = newArray(nS);
eyeL_area = newArray(nS);
// Right eye
eyeR_time = newArray(nS);
eyeR_x = newArray(nS);
eyeR_y = newArray(nS);
eyeR_major = newArray(nS);
eyeR_minor = newArray(nS);
eyeR_angle = newArray(nS);
eyeR_area = newArray(nS);
// Swim Bladder
sb_time = newArray(nS);
sb_x = newArray(nS);
sb_y = newArray(nS);
sb_major = newArray(nS);
sb_minor = newArray(nS);
sb_angle = newArray(nS);
sb_area = newArray(nS);

//set up iteratively updated variables for wand command
eyeL_x_now = eyeL_x_ini;
eyeL_y_now = eyeL_y_ini;

eyeR_x_now = eyeR_x_ini;
eyeR_y_now = eyeR_y_ini;

sb_x_now = sb_x_ini;
sb_y_now = sb_y_ini;

//analyse all frames

//Swim Bladder
for (i=0; i<nS; i++) {
	setSlice(i+1); //slice index starts at 1
	//plot point of selection (derived from previous frame)
	makeOval(sb_x_now, sb_y_now, 5, 5);
	run("Draw", "slice");

	doWand(sb_x_now, sb_y_now, sbTol, "Legacy");
	run("Fit Ellipse");
	run("Measure");
	sb_time[i] = i*ifi; //time axis
	sb_x[i] = getResult("X"); //get latest centroid X
	sb_y[i] = getResult("Y"); //get latest centroid Y
	sb_major[i] = getResult("Major"); //get latest major axis
	sb_minor[i] = getResult("Minor"); //get latest minor axis
	sb_angle[i] = getResult("Angle"); //get latest angle
	sb_area[i] = getResult("Area"); //get latest area

	//check if fit was lost
	if (sb_area[i] > sb_area_cutoff || sb_area[i] < sb_area_cutoff*0.67) {
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
 		waitForUser("Click on SWIM BLADDER");
 		run("Fit Ellipse");
 		run("Measure");
 		sb_time[i] = i*ifi; //time axis
 		sb_x[i] = getResult("X"); //get latest centroid X
 		sb_y[i] = getResult("Y"); //get latest centroid Y
 		sb_major[i] = getResult("Major"); //get latest major axis
 		sb_minor[i] = getResult("Minor"); //get latest minor axis
 		sb_angle[i] = getResult("Angle"); //get latest angle
 		sb_area[i] = getResult("Area"); //get latest area
 	}
 	
	// fix angles
	if (sb_angle[i]>90) {
 		sb_angle[i] = sb_angle[i]-180;
 	}
	// draw ellipse
	run("Draw", "slice");

	// update values
 	run("Find Maxima...", "prominence=10 light output=[Point Selection]");
	getSelectionCoordinates(sb_x_now, sb_y_now);
	sb_x_now = sb_x_now[0];
	sb_y_now = sb_y_now[0];
}


//Left Eye
for (i=0; i<nS; i++) {
	setSlice(i+1); //slice index starts at 1
	//displacing point towards periphery on the major pole of the eye
	doWand(eyeL_x_now+eyeL_dxWand, eyeL_y_now+eyeL_dyWand, userTol, "Legacy");
	run("Fit Ellipse");
	run("Measure");
	eyeL_time[i] = i*ifi; //time axis
	eyeL_x[i] = getResult("X"); //get latest centroid X
	eyeL_y[i] = getResult("Y"); //get latest centroid Y
	eyeL_major[i] = getResult("Major"); //get latest major axis
	eyeL_minor[i] = getResult("Minor"); //get latest minor axis
	eyeL_angle[i] = getResult("Angle"); //get latest angle
	eyeL_area[i] = getResult("Area"); //get latest area

	//check if fit was lost
	if (eyeL_area[i] > eyeL_area_cutoff || abs(eyeL_x[i]-eyeL_x_now) > 20 || abs(eyeL_y[i]-eyeL_y_now) > 20) {
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
 		waitForUser("Click on LEFT eye");
 		run("Fit Ellipse");
 		run("Measure");
 		eyeL_time[i] = i*ifi; //time axis
 		eyeL_x[i] = getResult("X"); //get latest centroid X
 		eyeL_y[i] = getResult("Y"); //get latest centroid Y
 		eyeL_major[i] = getResult("Major"); //get latest major axis
 		eyeL_minor[i] = getResult("Minor"); //get latest minor axis
 		eyeL_angle[i] = getResult("Angle"); //get latest angle
 		eyeL_area[i] = getResult("Area"); //get latest area
 	}
 	
	// fix angles
	if (eyeL_angle[i]>90) {
 		eyeL_angle[i] = eyeL_angle[i]-180;
 	}
 	// update values
 	eyeL_x_now = getResult("X"); //get latest centroid X
	eyeL_y_now = getResult("Y"); //get latest centroid Y
	eyeL_dxWand=(cos(getResult("X"))*getResult("Major")/2)/2;
	eyeL_dyWand=-(sin(getResult("X"))*getResult("Major")/2)/2;
	// draw ellipse
	run("Draw", "slice");
}


//Right Eye
for (i=0; i<nS; i++) {
	setSlice(i+1); //slice index starts at 1
	//displacing point towards periphery on the major pole of the eye
	doWand(eyeR_x_now+eyeR_dxWand, eyeR_y_now+eyeR_dyWand, userTol, "Legacy");
	run("Fit Ellipse");
	run("Measure");
	eyeR_time[i] = i*ifi; //time axis
	eyeR_x[i] = getResult("X"); //get latest centroid X
	eyeR_y[i] = getResult("Y"); //get latest centroid Y
	eyeR_major[i] = getResult("Major"); //get latest major axis
	eyeR_minor[i] = getResult("Minor"); //get latest minor axis
	eyeR_angle[i] = getResult("Angle"); //get latest angle
	eyeR_area[i] = getResult("Area"); //get latest area

	// could be better to do Right and Left in same loop to check this every time.
	eyeDistance = sqrt(pow( abs(eyeR_x[i]-eyeL_x[i]) , 2) + pow( abs(eyeR_y[i]-eyeL_y[i]) ,2));
	
	//check if fit was lost
	if (eyeR_area[i] > eyeR_area_cutoff || abs(eyeR_x[i]-eyeR_x_now) > 20 || abs(eyeR_y[i]-eyeR_y_now) > 20 || eyeDistance < eyeR_major[i]/2) {
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
	eyeR_dxWand=(cos(getResult("X"))*getResult("Major")/2)/2;
	eyeR_dyWand=-(sin(getResult("X"))*getResult("Major")/2)/2;
	// draw ellipse
	run("Draw", "slice");
}

setTool("rectangle");
run("Select None");

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
sb_ref_angle = sb_angle[0];
sb_angle_plot = newArray(nS);
eyeL_angle_plot = newArray(nS);
eyeR_angle_plot = newArray(nS);
// transform to relative measurement
for (i=0; i<nS; i++) {
	eyeL_angle_plot[i] = eyeL_angle[i]-sb_angle[i];
	eyeR_angle_plot[i] = eyeR_angle[i]-sb_angle[i];
	sb_angle_plot[i] = sb_angle[i] - sb_ref_angle;
}

//Create plot of eye angles
Plot.create("eyePhi", "time (s)", "eye angle (deg)")
Plot.setLineWidth(2);
Plot.setColor("gray");
Plot.add("line",eyeL_time,sb_angle_plot);
Plot.setColor("green");
Plot.add("line",eyeL_time,eyeL_angle_plot);
Plot.setColor("magenta");
Plot.add("line",eyeR_time,eyeR_angle_plot);
Plot.setLimits(0,eyeL_time[nS-1],-50.0,50.0);
Plot.addLegend("Swim Bladder\nL eye\nR eye", "Top-Right Bottom-To-Top Transparent");

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Finally, save results as tsv
OKRtable = File.open(fPath + "OKR_" + fName + ".txt");
// use d2s() function (double to string) to specify decimal places 
print(OKRtable, 
"tAxis" + "\t" + 
"lX" + "\t" + "lY" + "\t" + 
"lMajor" + "\t" + "lMinor" + "\t" + "lAngle" + "\t" + "lArea" + "\t" + 
"rX" + "\t" + "rY" + "\t" + 
"rMajor" + "\t" + "rMinor" + "\t" + "rAngle" + "\t" + "rArea" + "\t" +
"sbX" + "\t" + "sbY" + "\t" + 
"sbMajor" + "\t" + "sbMinor" + "\t" + "sbAngle" + "\t" + "sbArea");
for (i=0;i<nS;i++) {
	print(OKRtable, 
	d2s(eyeL_time[i],3) + "\t" + 
	d2s(eyeL_x[i],3) + "\t" + d2s(eyeL_y[i],3) + "\t" + 
	d2s(eyeL_major[i],3) + "\t" + d2s(eyeL_minor[i],3) + "\t" + 
	d2s(eyeL_angle[i],3) + "\t" + d2s(eyeL_area[i],1) + "\t" + 
	d2s(eyeR_x[i],3) + "\t" + d2s(eyeR_y[i],3) + "\t" + 
	d2s(eyeR_major[i],3) + "\t" + d2s(eyeR_minor[i],3) + "\t" + 
	d2s(eyeR_angle[i],3) + "\t" + d2s(eyeR_area[i],1) + "\t" + 
	d2s(sb_x[i],3) + "\t" + d2s(sb_y[i],3) + "\t" + 
	d2s(sb_major[i],3) + "\t" + d2s(sb_minor[i],3) + "\t" + 
	d2s(sb_angle[i],3) + "\t" + d2s(sb_area[i],1));
}
File.close(OKRtable)


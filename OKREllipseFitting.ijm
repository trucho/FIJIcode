// Use this to change slices to frames but check frame interval first. Also removes weird scaling from uEye camera
//run("Properties...", "channels=1 slices=1 frames=2400 unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1.0000 frame=[50.00 msec]");

//getDimensions(w, h, channels, slices, frames);
//w = w -150;
//h = h - 50;
//run("Label...", "format=00:00 starting=0.00 interval=0.05 x=&w y=&h font=24 text=min range=1-2400 use use_text");

//#@ Integer (label="Tolerance", style="slider", min=0, max =100, value=21) userTol
userTol=21;

ifi = 50/1000; //interframe interval

run("Clear Results");
close("Dup");
close("eyePhi");
run("Set Measurements...", "stack area centroid fit redirect=None decimal=3");

setTool("wand");
run("Wand Tool...", "tolerance=&userTol mode=Legacy");

waitForUser("Click on RIGHT eye")
run("Measure");
waitForUser("Click on LEFT eye")
run("Measure");

fName = replace(getTitle, ".tif", "")
fPath = getDirectory("image");

//get initial conditions
eyeR_x_ini = getResult("X",0);
eyeR_y_ini = getResult("Y",0);
eyeR_area_cutoff = getResult("Area",0)*1.2;

eyeL_x_ini = getResult("X",1);
eyeL_y_ini = getResult("Y",1);
eyeL_area_cutoff = getResult("Area",1)*1.2;

nS = nSlices;

run("Select None");
run("Clear Results");

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
 run("Draw", "slice");
 eyeR_x_now = getResult("X"); //get latest centroid X
 eyeR_y_now = getResult("Y"); //get latest centroid Y
 eyeR_time[i] = i*ifi; //time axis
 eyeR_x[i] = getResult("X"); //get latest centroid X
 eyeR_y[i] = getResult("Y"); //get latest centroid Y
 eyeR_major[i] = getResult("Major"); //get latest major axis
 eyeR_minor[i] = getResult("Minor"); //get latest minor axis
 eyeR_angle[i] = getResult("Angle"); //get latest angle
 eyeR_area[i] = getResult("Area"); //get latest area
 //check if fit was lost
 if (eyeR_area[i] > eyeR_area_cutoff) {
 	eyeR_angle[i] = 0;
 }
 else {
 	// fix angles
 	if (eyeR_angle[i]>90) {
 		eyeR_angle[i] = eyeR_angle[i]-180;
 	}
 }
}

//Left Eye
for (i=0; i<nS; i++) {
 setSlice(i+1); //slice index starts at 1
 doWand(eyeL_x_now, eyeL_y_now, userTol, "Legacy");
 run("Fit Ellipse");
 run("Measure");
 run("Draw", "slice");
 eyeL_x_now = getResult("X"); //get latest centroid X
 eyeL_y_now = getResult("Y"); //get latest centroid Y
 eyeL_time[i] = i*ifi; //time axis
 eyeL_x[i] = getResult("X"); //get latest centroid X
 eyeL_y[i] = getResult("Y"); //get latest centroid Y
 eyeL_major[i] = getResult("Major"); //get latest major axis
 eyeL_minor[i] = getResult("Minor"); //get latest minor axis
 eyeL_angle[i] = getResult("Angle"); //get latest angle
 eyeL_area[i] = getResult("Area"); //get latest area
 //check if fit was lost
 if (eyeL_area[i] > eyeL_area_cutoff) {
 	eyeL_angle[i] = 0;
 }
 else {
 	// fix angles
 	if (eyeL_angle[i]>90) {
 		eyeL_angle[i] = eyeL_angle[i]-180;
 	}
 }
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

// Finally, save results as tsv
OKRtable = File.open(fPath + fName + ".txt");
// use d2s() function (double to string) to specify decimal places 
print(OKRtable, "tAxis" + "\t" + "rX" + "\t" + "rY" + "\t" + "rMajor" + "\t" + "rMinor" + "\t" + "rAngle" + "\t" + "rArea" + "\t" + "lX" + "\t" + "lY" + "\t" + "lMajor" + "\t" + "lMinor" + "\t" + "lAngle" + "\t" + "lArea");
for (i=0;i<nS;i++) {
	print(OKRtable, d2s(eyeR_time[i],3) + "\t" + d2s(eyeR_x[i],3) + "\t" + d2s(eyeR_y[i],3) + "\t" + d2s(eyeR_major[i],3) + "\t" + d2s(eyeR_minor[i],3) + "\t" + d2s(eyeR_angle[i],3) + "\t" + d2s(eyeR_area[i],1) + "\t" + d2s(eyeL_x[i],3) + "\t" + d2s(eyeL_y[i],3) + "\t" + d2s(eyeL_major[i],3) + "\t" + d2s(eyeL_minor[i],3) + "\t" + d2s(eyeL_angle[i],3) + "\t" + d2s(eyeL_area[i],1));
}
File.close(OKRtable)





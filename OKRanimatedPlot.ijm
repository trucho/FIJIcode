close("eyePhi");
close("aniPlot");

getDimensions(plW, ogH, ogC, ogS, nS); //get dimensions from original movie
plH = plW/3; //plot height

// recover angles
eyeR_angle = newArray(nS); 
eyeL_angle = newArray(nS); 
for (i=0; i<nS; i++) {
	eyeR_angle[i] = getResult("rAngle",i);
	eyeL_angle[i] = getResult("lAngle",i);
}
run("Plots...", "width=940 height=280 font=14 draw draw_ticks minimum=0 maximum=0 interpolate");
// set up stack window for animated plot
newImage("aniPlot", "RGB black", plW, plH, 1, 1, nS/10);

for (i=1; i<=nS/10; i++) {
//	i=
	Plot.create("eyePhi", "frame", "eye angle (deg)")
	Plot.setLineWidth(1);
	Plot.setColor("gray");
	Plot.add("line",eyeR_angle);
	Plot.setColor("gray");
	Plot.add("line",eyeL_angle);
	//Plot.setLimits(0,2400,-50.0,50.0);
	Plot.show();
	selectImage("eyePhi");
//	run("Size...", "width=&plW height=&plH depth=1 average interpolation=Bilinear");


	trimLim = i * 8;
	Plot.setColor("green");
	Plot.add("circles",Array.trim(eyeR_angle,trimLim));
	Plot.setColor("magenta");
	Plot.add("circles",Array.trim(eyeL_angle,trimLim));

	run("Copy");			//copy plot window content
	run("Close");			//close the plot window
	selectImage("aniPlot");
	setSlice(i);
	run("Paste");
}
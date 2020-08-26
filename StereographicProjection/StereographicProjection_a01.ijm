close("intensityPlot");

selectWindow("singleOrtho.tif");

stereoX = 750;
stereoY = 875;
stereoR = 1530; //1530

//Create plot
run("Plots...", "width=780 height=500 font=22 draw draw_ticks minimum=0 maximum=0 interpolate");
Plot.create("intensityPlot", "angle", "intensity")
Plot.setLineWidth(3);
//Plot.setColor("cyan");

nr = 200;
for (dr = 0; dr < nr; dr++) {
	currR = stereoR+dr;
	makeOval(stereoX-currR/2, stereoY-currR/2, currR,currR);
	getSelectionCoordinates(circleX, circleY);
	nPoints = circleX.length;
	circle_reX = newArray(nPoints);
	circle_reY = newArray(nPoints);
	circleR = newArray(nPoints);
	circleT = newArray(nPoints);
	for (i = 0; i < nPoints; i++) {
		circle_reX[i] = circleX[i] - stereoX;
		circle_reY[i] = circleY[i] - stereoY;
		circleR[i] = sqrt(circle_reX[i]*circle_reX[i]+circle_reY[i]*circle_reY[i]);
		circleT[i] = 180+ (atan2(circle_reY[i],circle_reX[i])*180/PI);
	}
	
	Array.sort(circleT,circleX,circleY);

	angleArray = newArray(nPoints);
	pixelArray = newArray(nPoints);
	for (i = 0; i < nPoints; i++) {
		angleArray[i] = i;
		pixelArray[i] = getPixel(circleX[i], circleY[i]);
	}
	Plot.setColor(rgbtohex(255*dr/nr,255*(nr-dr)/nr,255*dr/nr));
	Plot.add("line",circleT,pixelArray);
}
Plot.setLimits(30,150,NaN,NaN);
Plot.show();

function rgbtohex(r,g,b) {
    hex= "#" + ""+pad(toHex(r)) + ""+pad(toHex(g)) + ""+pad(toHex(b));
    return hex;
}
function pad(n) {
    n = toString(n);
    if(lengthOf(n)==1) n = "0"+n;
    return n;
}
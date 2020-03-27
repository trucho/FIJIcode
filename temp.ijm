//makeOval(280, 485, 64, 41);


//makeLine(eyeR_x+cos(eyeR_angle)*eyeR_r1/2, eyeR_y-(sin(eyeR_angle)*eyeR_r1/2), eyeR_x-(cos(eyeR_angle)*eyeR_r1/2), eyeR_y+(sin(eyeR_angle)*eyeR_r1/2));
x=(cos(6)*64/2)/2;
y=-(sin(6)*64/2)/2;

doWand(250+x, 438+y, 21, "Legacy");

//
//
//
////Create plot of eye angles
//Plot.create("eyePhi", "time (s)", "eye angle (deg)")
//Plot.setLineWidth(2);
//Plot.setColor("green");
//Plot.add("line",eyeR_time,eyeR_angle);
//Plot.setColor("magenta");
//Plot.add("line",eyeL_time,eyeL_angle);
//Plot.setLimits(0,eyeL_time[nS-1],-50.0,50.0);
//Plot.addLegend("R eye\nL eye", "Top-Right Bottom-To-Top Transparent");
//
//// Finally, save results as tsv
//OKRtable = File.open(fPath + "OKR_" + fName + ".txt");
//// use d2s() function (double to string) to specify decimal places 
//print(OKRtable, "tAxis" + "\t" + "rX" + "\t" + "rY" + "\t" + "rMajor" + "\t" + "rMinor" + "\t" + "rAngle" + "\t" + "rArea" + "\t" + "lX" + "\t" + "lY" + "\t" + "lMajor" + "\t" + "lMinor" + "\t" + "lAngle" + "\t" + "lArea");
//for (i=0;i<nS;i++) {
//	print(OKRtable, d2s(eyeR_time[i],3) + "\t" + d2s(eyeR_x[i],3) + "\t" + d2s(eyeR_y[i],3) + "\t" + d2s(eyeR_major[i],3) + "\t" + d2s(eyeR_minor[i],3) + "\t" + d2s(eyeR_angle[i],3) + "\t" + d2s(eyeR_area[i],1) + "\t" + d2s(eyeL_x[i],3) + "\t" + d2s(eyeL_y[i],3) + "\t" + d2s(eyeL_major[i],3) + "\t" + d2s(eyeL_minor[i],3) + "\t" + d2s(eyeL_angle[i],3) + "\t" + d2s(eyeL_area[i],1));
//}
//File.close(OKRtable)





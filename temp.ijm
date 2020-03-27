//nS = nSlices;
//run("Properties...", "channels=1 slices=1 frames=&nS unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1.0000 frame=[50.00 msec]");


//print(getMetadata("Frame Interval"));

//call("ImpProps.getProperty", "Frame Interval")

//fPath = getDirectory("image");
//fName = replace(getTitle, ".tif", "")
//print(fName);

z_index=9;
eyeL_x = getResult("lX",z_index);
eyeL_y = getResult("lY",z_index);
eyeL_r1 = getResult("lMajor",z_index);
eyeL_r2 = getResult("lMinor",z_index);
eyeL_angle = 180-getResult("lAngle",z_index);
eyeL_angle = getResult("lAngle",z_index) * PI/180;

makeLine(eyeL_x+cos(eyeL_angle)*eyeL_r1/2, eyeL_y-(sin(eyeL_angle)*eyeL_r1/2), eyeL_x-(cos(eyeL_angle)*eyeL_r1/2), eyeL_y+(sin(eyeL_angle)*eyeL_r1/2));

eyeL_angle = eyeL_angle + PI/2;
makeLine(eyeL_x+cos(eyeL_angle)*eyeL_r2/2, eyeL_y-(sin(eyeL_angle)*eyeL_r2/2), eyeL_x-(cos(eyeL_angle)*eyeL_r2/2), eyeL_y+(sin(eyeL_angle)*eyeL_r2/2));


// Takes a Z-stack created in SciScan and averages the frames taken at each Z-plane.
// For now you enter the frames.per.plane value yourself; getting it from the .ini file is possible but will require image to be in the same folder as .ini file
// Optionally subtracts 2^15 for convenience if you ask it to do so

  
  numFramesPerSlice=10;

  middleValue = pow(2,15);
  
  Dialog.create("Z-stack pre-processing");
  Dialog.addNumber("# frames.per.plane (per .ini file):", numFramesPerSlice);
  Dialog.addCheckbox("Subtract " + middleValue, false);
  Dialog.show();
  
  numFramesPerSlice = Dialog.getNumber();
  subtractMiddle = Dialog.getCheckbox();


  //print(numFramesPerSlice);
  //print(subtractMiddle);

  Stack.getDimensions(width, height, channels, slices, frames);
  print(slices + ", " + frames);

  nPlanes = slices / numFramesPerSlice;

  print(nPlanes + ", " + slices + ", " + numFramesPerSlice);

  windowName = getTitle();

//  print(windowName);

  run("Stack to Hyperstack...", "order=xyzct channels=" + nPlanes + " slices=" + numFramesPerSlice + " frames=1 display=Color");
  run("Z Project...", "projection=[Average Intensity]");
  run("Re-order Hyperstack ...", "channels=[Slices (z)] slices=[Channels (c)] frames=[Frames (t)]");

  selectWindow(windowName);
  close();

  selectWindow("AVG_" + windowName);

  if(subtractMiddle) {
  	run("Subtract...", "value="+ middleValue +" stack");
  }

  setSlice(floor(nPlanes/2));
  run("Enhance Contrast", "saturated=0.35");
  setSlice(1);

  
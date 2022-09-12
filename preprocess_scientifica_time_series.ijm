// The processes written below are based on processing the files created during a time series of Z-stacks created using SciScan 1.3 from Scientifica
// It's expecting a file/directory structure like so (which is created when recording Z-stacks in SciScan):
//
//  TopDirectory (usually the date code)
//	-> StackFolder with TimeStamp 1
//		-> time-stamp 1, experiment-name-tagged .ini file
//		-> time-stamp 1, experiment-name-tagged .xml file
//		-> time-stamp 1, experiment-name-tagged _ch_1.tif file
//		-> time-stamp 1, experiment-name-tagged _ch_2.tif file
//		-> time-stamp 1, experiment-name-tagged _ch_3.tif file
//	-> StackFolder with TimeStamp 2
//		-> time-stamp 2, experiment-name-tagged files as above
//	-> StackFolder with TimeStamp 3...
//		-> time-stamp 3, experiment-name-tagged files as above
//	...etc...
//
//
//	It assumes that each stack was taken with some number of frames per Z-plane that you would like to have averaged and re-combined as a Z-stack
//  Also, that you would like to repeat this for each stack in the series and concatenate them all into a Z-stack time-series
//
//  There is some basic code to exclude stacks, for example, that have "afterStack" in the title, because that's a flag I use in expt. names to denote a stack taken
//  after the fact, which usually serves some other purpose and shouldn't be analyzed
//
//	Still working on the details, but if it works, I'll also output a table of timestamps for each Z-stack acquisition (helpful for plotting, analysis)



print("\\Clear");
print("\\Update:Beginning preprocessing...");  //Clear log window

nFramesPerSlice = 10;
numImages = 0;
maxSlices = 1;

Table.create("Time point parameters");
Table.reset("Time point parameters");

topDirectory = getDirectory("Choose input directory");
print("Looking for time series stacks in " + topDirectory + "...");

subDirList = getFileList(topDirectory);



for(i=subDirList.length; i>0; i--) {


	// Remeove items from the list that aren't actually folders
	subDir = topDirectory + subDirList[i-1];
	if(!File.isDirectory(subDir)) {
		subDirList = Array.deleteIndex(subDirList, i-1);
		continue;
	}

	// Like I say in the comments above, ignore folders with "afterStack" in the name
	indx = indexOf(subDirList[i-1], "afterStack");
	if(indx>0) {
		subDirList = Array.deleteIndex(subDirList, i-1);
		continue;
	}

	// Another exception, I've started using _NOUSE to tag folders w/images that shouldn't be included in analysis
	indx = indexOf(subDirList[i-1], "_NOUSE");
	if(indx>0) {
		subDirList = Array.deleteIndex(subDirList, i-1);
		continue;
	}


}

print("Done processing, " + subDirList.length + " time points identified.");






for (i=0; i<subDirList.length; i++) {




	// Identify files (keep in mind this does jack squat to prepare you for missing files. More complete processing will require relevant checking for this)
	subDir = topDirectory + subDirList[i];
	fileList = getFileList(subDir);

	for (j=0; j<fileList.length; j++) {
		fullFileName = subDir + fileList[j];

		// Is it the .ini file?
		indx = indexOf(fullFileName, ".ini");
		if(indx>0) {
			iniFile = subDir + fileList[j];
			continue;
		}

		// Is it the .xml file?
		indx = indexOf(fullFileName, ".xml");
		if(indx>0) {
			xmlFile = subDir + fileList[j];
			continue;
		}

		// Is it the _ch_1.tif image file?
		indx = indexOf(fullFileName, "_ch_1.tif");
		if(indx>0) {
			ch1File = subDir + fileList[j];
			continue;
		}

		// _ch_2?
		indx = indexOf(fullFileName, "_ch_2.tif");
		if(indx>0) {
			ch2File = subDir + fileList[j];
			continue;
		}

		// _ch_3?
		indx = indexOf(fullFileName, "_ch_3.tif");
		if(indx>0) {
			ch3File = subDir + fileList[j];
			continue;
		}
	}




	// Get metadata info as needed
	iniStr = File.openAsString(iniFile);
	xmlStr = File.openAsString(xmlFile);

	nPlanes = getIniValue(iniStr, "no.of.planes");
	nFramesPerSlice = getIniValue(iniStr, "frames.per.plane");
	micronsPerPixel = 1e6 * getIniValue(iniStr, "x.pixel.sz"); //Assuming isotropic pixel size, can check y.pixel.sz if unsure
	micronsPerSlice = getIniValue(iniStr, "z.spacing");

	timeStampData = getTimeStampsFromXML(xmlStr);

	timeMinutes = timeStampData[2];  // "getTimeStampsFromXML" calculates minutes since midnight and returns it as 3rd array value
	
//	print(nPlanes + " planes, " + nFramesPerSlice + " frames/plane, " + micronsPerPixel + " um/px, " + micronsPerSlice + " um Z-spacing. Starting timestamp: " + timeStampData[0] + ", elapsed seconds = " + timeStampData[1] + ".");



	//Interested in determining the highest # of slices in the time series (for later use). So, let's compare & store if larger
	if(nPlanes > maxSlices) {
		maxSlices = nPlanes;
	}


	//Want to have an array of time values relative to the first time point, so if this is the first stack, store it as t0
	if(i==0) {
		firstTimeMinutes = timeMinutes;
	}

	//Calculate difference from this timestamp and the first timestamp in minutes
	if(timeMinutes < firstTimeMinutes) {
		//If this happens, that means the acquisition probably spanned midnight, so add 24h worth of minutes to correct for this
		deltaMinutes = 24*60 + timeMinutes - firstTimeMinutes;
	} else {
		deltaMinutes = timeMinutes - firstTimeMinutes;  
	}



	// Add metadata to table
	Table.set("Frame index", i, i);
	Table.set("Timestamp", i, timeStampData[0]);
	Table.set("Stack duration", i, timeStampData[1]);
	Table.set("Elapsed minutes", i, deltaMinutes);
	Table.set("Slices", i, nPlanes);
	Table.set("#/Slice", i, nFramesPerSlice);
	Table.set("XY size (um)", i, micronsPerPixel);
	Table.set("Z spacing (um)", i, micronsPerSlice);
	
	


	
	// Open image file
	windowName = "" + i;
	
	open(ch2File);
	rename(windowName);


	// print("order=xyzct channels=" + nPlanes + " slices=" + nFramesPerSlice + " frames=1 display=Color");

	// Pre-process, shape, average, etc.
	run("Stack to Hyperstack...", "order=xyzct channels=" + nPlanes + " slices=" + nFramesPerSlice + " frames=1 display=Color");
	run("Z Project...", "projection=[Average Intensity]");
	run("Re-order Hyperstack ...", "channels=[Slices (z)] slices=[Channels (c)] frames=[Frames (t)]");

	selectWindow(windowName);
	close();

	selectWindow("AVG_" + windowName);
	rename(windowName);

	
}




//Now, I need to make sure each stack has the same # slices for combining them in time
selectWindow(windowName);
Stack.getDimensions(width, height, channels, slices, frames);

for (i=0; i<subDirList.length; i++) {

	windowName = "" + i;
	selectWindow(windowName);
	Stack.getDimensions(width, height, channels, slices, frames);

	nSlicesToAdd = maxSlices - slices;

	if(nSlicesToAdd>0) {
		newImage("blank_frame", "16-bit black", width, height, nSlicesToAdd);
		run("Concatenate...", "  title=" + windowName + " open image1=" + windowName + " image2=blank_frame image3=[-- None --]");
	}

	selectWindow(windowName);
	run("Re-order Hyperstack ...", "channels=[Slices (z)] slices=[Channels (c)] frames=[Frames (t)]");

}


// Now, combine all time points and rearrange so that channel and Z dimensions are exchanged
run("Concatenate...", "all_open");
run("Re-order Hyperstack ...", "channels=[Slices (z)] slices=[Channels (c)] frames=[Frames (t)]");

selectWindow("Untitled");
rename("Time series");

//run("8-bit");

run("Set Scale...", "distance=1 known=" + micronsPerPixel + " unit=micron");
run("Properties...", "pixel_width=" + micronsPerPixel + " pixel_height=" + micronsPerPixel + " voxel_depth=" + micronsPerSlice);

return;






//
//
//if(false) {
//	subDir = topDirectory + fileList[i];
//
//	if(File.isDirectory(subDir)) {
//		subFileList = getFileList(subDir);
//
//		for (j=0; j<subFileList.length; j++) {
//
//			indx1 = indexOf(subFileList[j], "XYTZ_ch_2.tif");
//			indx2 = indexOf(subFileList[j], "afterStack");
//
//			if(indx1>0 && indx2<0) {
//
//				//print("Processing " + subFileList[j] + "...");	
//				
//
//				fullFileName = subDir + subFileList[j];
//
//				open(fullFileName);
//
//				metaData = getMetadata("Info");
//
//				print(metaData);
//
//				selectWindow(subFileList[j]);
//
//				newName = ""+numImages;
//				
//				rename(newName);
//
//				Stack.getDimensions(width, height, channels, slices, frames);
//
//				nZplanes = slices / nFramesPerSlice;
//
//				if(nZplanes > maxSlices) {
//					maxSlices = nZplanes;
//				}
//
//
//				run("Stack to Hyperstack...", "order=xyzct channels=" + nZplanes + " slices=" + nFramesPerSlice + " frames=1 display=Color");
//				run("Z Project...", "projection=[Average Intensity]");
//
//				run("Re-order Hyperstack ...", "channels=[Slices (z)] slices=[Channels (c)] frames=[Frames (t)]");
//
//				newAvgName = "AVG_" + newName;
//
//				selectWindow(newName);
//				close();
//
//				selectWindow(newAvgName);
//				rename(newName);
//
//				numImages = numImages+1;
//
//				
//			}
//		}
//
//		//print("--");
//	}
//
//	
//}
//
//for(n=0; n<numImages; n++) {
//	winName = ""+n;
//	selectWindow(winName);
//	Stack.getDimensions(width, height, channels, slices, frames);
//
//	for(i=slices; i<maxSlices; i++) {
//		newImage("blank_frame", "16-bit black", width, height, 1);
//		run("Concatenate...", "  title=" + winName + " open image1=blank_frame image2=" + winName + " image3=[-- None --]");
//	}
//
//	run("Re-order Hyperstack ...", "channels=[Slices (z)] slices=[Channels (c)] frames=[Frames (t)]");
//}


//print(maxSlices);
//
//run("Concatenate...", "all_open keep open");
//run("Re-order Hyperstack ...", "channels=[Slices (z)] slices=[Channels (c)] frames=[Frames (t)]");
//
//selectWindow("Untitled");
//rename("Time series");

//run("8-bit");
//run("Histogram", "stack");

//I find "descriptor-based series registration" (under Plugins->Registration) followed by "Correct 3D drift" to work well





// Function defs-----------------------------------------------


function getTimeStampsFromXML(xmlStr) {

	//Get timestamp from XML file
	startToken = "<OME:AcquisitionDate>";
	stopToken = "</OME:AcquisitionDate>";
	
	indx1 = indexOf(xmlStr, startToken);
	indx2 = indexOf(xmlStr, stopToken);

	subStr = substring(xmlStr, indx1+lengthOf(startToken), indx2);
	timeStamp = replace(subStr, "T", " "); //They put a "T" between date & time. They just did, I don't know.

	
	indx = indexOf(timeStamp, " ");
	timeStr = substring(timeStamp, indx+1);

	hrsStr = substring(timeStr, 0, 2);
	minStr = substring(timeStr, 3, 5);
	secStr = substring(timeStr, 6, 8);

	timeMinutes = 60*parseInt(hrsStr) + parseInt(minStr) + 1/60.0*parseInt(secStr);

	//Get elapsed time of recording from "ImagePhysicalDimensions"
	startToken = "<ImagePhysicalDimensions PhysicalSizeT=\"";
	stopToken = "\" PhysicalSizeTUnit";
	
	indx1 = indexOf(xmlStr, startToken);
	indx2 = indexOf(xmlStr, stopToken);

	subStr = substring(xmlStr, indx1+lengthOf(startToken), indx2);
	elapsedSeconds = parseFloat(subStr);

	return newArray(timeStamp, elapsedSeconds, timeMinutes);

}



function getIniValue(parameterString, parameterName) {

		indx1 = indexOf(parameterString, parameterName);

		if(indx1<0) { 
			errStr = "Parameter " + parameterName + " not found...";
			print(errStr);
			return NaN; 
		}

		subStr1 = substring(parameterString, indx1);

		indx2 = indexOf(subStr1, "\n");

		subStr2 = substring(subStr1, lengthOf(parameterName) + 3, indx2);

//		outputStr = "Found it: " + subStr2;
//		print(outputStr);

		return parseFloat(subStr2);

}


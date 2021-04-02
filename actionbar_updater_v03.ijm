/*
 * ActionBar Updater-Makro, by Rainer M. Engel, 2012
 * ActionBar is a plugin for ImageJ created by Jerome Mutterer
 * http://imagejdocu.tudor.lu/doku.php?id=plugin:utilities:action_bar:start
 */

ijDir	= getDirectory("imagej");

// CONFIG HERE ################################################################
ActBar	= ijDir+"plugins"+File.separator+"ActionBar"+File.separator+"test.txt";	// YOUR ActionBar
verbose	= true;									// print to log
dialog	= false;								// show dialog before updating
//#############################################################################


if (verbose) {
	print("\\Clear");
	print("start updating ActionBar..");
	print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -");
}

ActScr	= File.openAsString(ActBar);
//print(ActScr);

SRClines= split(ActScr,"\n");
if (verbose) {
	print("-> found "+lengthOf(SRClines)+" lines in ActionBar-Script");
}


// filter path-containing lines from script -----------------------------------
paths	= newArray();	// create Array to store paths in
ranks	= newArray();	// create Array to store ranks in
vers	= newArray();	// create Array to store versions in
exts	= newArray();	// create Array to store extentions (format) in
for (i=0; i<SRClines.length; i++){

	if (matches(SRClines[i], "//.*")){
		//print("found a uncommented line");
	}

	else {
		if (matches(SRClines[i], ".*_v[0-9]{2}.ijm.*") || matches(SRClines[i], ".*_v[0-9]{2}.txt.*")){
			//print("found something: "+SRClines[i]);
			path = getPath(SRClines[i]);
			//print(path);
			ScrVer= getVerIncr(path);
			//print(ScrVer);
			fileT = getExt(path);
			//print(fileT);
			paths = Array.concat(paths,path);
			ranks = Array.concat(ranks,i);
			vers = Array.concat(vers,ScrVer);
			exts = Array.concat(exts,fileT);
			//print("   - line: "+i+" | version: "+ScrVer+" | path: "+path);
		}
	}
}
if (verbose) {
	print("-> found "+lengthOf(paths)+" linked makros inside of ActionBar-Script");
}
//------------------------------------------------------------------------------


// check existence of makros ---------------------------------------------------
makroC	= newArray();	// create Array to count found makros
for (i=0; i<paths.length; i++){
	if (File.exists(paths[i])) {
		makroC = Array.concat(makroC,paths[i]);
	}
}
if (verbose) {
	print("-> found "+lengthOf(makroC)+" makros at their defined paths");
}
//------------------------------------------------------------------------------


// check for updated makros ----------------------------------------------------
UpdateV	= 0;
UpdateP	= newArray();	// Updated paths to new versions
UpdateC = 0;
for (i=0; i<paths.length; i++){
	pathA 	= substring(paths[i], 0, (lengthOf(paths[i]))-6);
	//print(pathA);
	ScrVer 	= vers[i];
	//print(ScrVer);
	max	= 99;
	do {
		ScrVer	= (ScrVer)+1;
		VsPad	= IJ.pad(ScrVer, 2);
		testPath= pathA+VsPad+exts[i];
		//print(testPath);
		if (File.exists(testPath)) {
			//print("found: "+ScrVer);
			UpdateV = ScrVer;
		}
	} while (ScrVer < max);

	if (UpdateV != 0) {	// Update paths
		//print("Update found");
		VsPad	= IJ.pad(UpdateV, 2);
		NewPath	= pathA+VsPad+exts[i];
		UpdateP = Array.concat(UpdateP,NewPath);
		UpdateC = UpdateC+1;
		//print(NewPath);
	} else {		// copy old/known paths
		VsPad	= IJ.pad(vers[i], 2);
		OldPath	= pathA+VsPad+exts[i];
		UpdateP = Array.concat(UpdateP,OldPath);
		//print(OldPath);
	}
	UpdateV	= 0;
}
if (verbose) {
	print("-> found "+UpdateC+" update(s) in makros");
}
//------------------------------------------------------------------------------


// dialog ----------------------------------------------------------------------
if (dialog == true && UpdateC != 0) {
	wfu	= getBoolean("ActionBar-Updater found "+UpdateC+" Update(s).\nPerform update?");
	if (wfu == 0) {
		exit()
	}
}
//------------------------------------------------------------------------------


// Assemble updated action-bar file (if there are updates) ---------------------
if (UpdateC == 0) {
	if (verbose) {
		print("-> No need to make any updates.. stopping here!");
		print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -");
	}

} else {
	outLog	= File.delete(ActBar);
	outLog	= File.open(ActBar);
	c	= 0;
	for (i=0; i<SRClines.length; i++){

		if (i == (ranks[c])) {
			newLine = "runMacro(\""+UpdateP[c]+"\")";
			print(outLog, newLine);
			if (c < lengthOf(ranks)-1) {
				c = c+1;
			}
		} else {
			print(outLog, SRClines[i]);
		}
	}
	if (verbose) {
		print("-> ActionBar-file has been updated!");
		print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -");
	}

}
//------------------------------------------------------------------------------




// FUNCTIONS ..................................................................
function getPath(path) {	// get string of path only
	dotIndex = lastIndexOf(path, "\")");
	if (dotIndex!=-1)
	path = substring(path, 0, dotIndex);
	first = indexOf(path, "(\"");
	if (first!=-1)
	path = substring(path, first+2, lengthOf(path));
	return path;
}

function getVerIncr(version) {	// get version from path
	dotIndex = lastIndexOf(version, ".");
	if (dotIndex!=-1)
	version = substring(version, 0, dotIndex);
	first = indexOf(path, "_v");
	if (first!=-1)
	version = substring(version, first+2, lengthOf(version));
	version = IJ.pad(version, 0);
	return version;
}

function getExt(extention) {	// get filetype from path
	dotIndex = lastIndexOf(extention, ".");
	if (dotIndex!=-1)
	extention = substring(extention, dotIndex, lengthOf(extention));
	return extention;
}

//.............................................................................

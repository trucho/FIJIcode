fname = getTitle();
fpath = "/Volumes/zfSSD/LiImaging/A1R/zf/20200807_CRtbx2b/exports/";
fullpath = fpath + fname;

//reds = newArray(256); 
//greens = newArray(256); 
//blues = newArray(256);
//for (i=0; i<256; i++){
//	reds[i] = i;
//	greens[i] = i*173/255;
//	blues[i] = 0;
//}
//
//
//Stack.setChannel(1);
//run("Green");
//Stack.setChannel(2);
//run("Magenta");
//Stack.setChannel(3);
//setLut(reds, greens, blues);
Stack.setActiveChannels("110");
saveAs("PNG", fullpath);
close();
//close();
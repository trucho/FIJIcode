macro "DeInterleaveStack {F7]" { 
	toptitle=getTitle();
	run("Deinterleave", "how=2 keep");
	selectWindow(toptitle);
} 
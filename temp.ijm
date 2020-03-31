run("Find Maxima...", "prominence=10 light output=[Point Selection]");
getSelectionCoordinates(sb_x_now, sb_y_now);
makeOval(sb_x_now[0], sb_y_now[0], 10, 10);
run("Draw", "slice");

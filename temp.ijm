s_x = 512;
s_y = 250;
s_r1 = 300;
s_r2 = 150;
s_angle = 30 * PI/180;

makeLine(s_x+cos(s_angle)*s_r1/2, s_y-(sin(s_angle)*s_r1/2),
		s_x-(cos(s_angle)*s_r1/2), s_y+(sin(s_angle)*s_r1/2));
run("Fill", "slice");
makeLine(s_x+cos(s_angle+PI/2)*s_r2/2, s_y-(sin(s_angle+PI/2)*s_r2/2),
		s_x-(cos(s_angle+PI/2)*s_r2/2), s_y+(sin(s_angle+PI/2)*s_r2/2));
run("Fill", "slice");

dFraction = 0.75;
dx=(cos(s_angle)*s_r1/2)*dFraction;
dy=-(sin(s_angle)*s_r1/2)*dFraction;

makeOval(s_x+dx, s_y+dy, 5, 5);
run("Draw", "slice");
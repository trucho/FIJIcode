// Use this to change slices to frames but check frame interval first. Also removes weird scaling from uEye camera
nS = nSlices;
run("Properties...", "channels=1 slices=1 frames=&nS unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1.0000 frame=[50.00 msec]");
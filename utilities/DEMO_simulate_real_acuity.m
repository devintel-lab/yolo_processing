% NOTE: This function required a separate toolbox which only runs on Linux machines (not Windows...)

% Image from a first-person camera, for which we want to simulate acuity.
img_path = 'acuity_example.jpg';

% Center of gaze point for blurring the image. Values are pixels in the format: [row_coordinate, column_corrdinate]
gaze = [100 200];

% Horizontal field of view of the camera that captured the frame, multiplied by two.
% For example, the head camera for the toy room videos (exp. 12) has a 70 degree horizontal field of view, so the parameter would be 2x70 = 140;
% Practically, changing this value will affect how drastically the images gets blurrier.
hor_FOV = 140;

acuity_image = simulate_real_acuity(img_path, gaze, hor_FOV);
imshow(acuity_image);

% You can optionally draw a circle around the center of gaze to better locate it:
figure;

acuity_image_circle = simulate_real_acuity(img_path, gaze, hor_FOV, true);
imshow(acuity_image_circle);

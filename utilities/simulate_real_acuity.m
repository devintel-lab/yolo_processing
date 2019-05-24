function [rgb] = simulate_real_acuity(img, gaze, map_arc, draw_circle)

	if nargin < 4
		draw_circle = false;
	end

	if nargin < 3
		map_arc = 60;
	end
	if nargin < 2
		gaze = [240 320]; % [row col]
	end

	addpath(genpath('acuity_toolbox/svistoolbox-1.0.5/'));

	img = imread(img);

	rows=size(img,1);
	cols=size(img,2);

	% Break into separate color planes
	red=squeeze(img(:,:,1));
	green=squeeze(img(:,:,2));
	blue=squeeze(img(:,:,3));

	% Initialize the library
	svisinit

	% Create a resmap
	% fprintf('Creating resolution map...\n');
	% 'maparc'  Horizontal visual angle represented by the map.  Default
	%           is 60 degrees.  The map usually covers twice the visual
	%           angle of the image to which it is applied.  For example,
	%           if the image covers 20 degrees of visual angle, the map
	%           would need to be about 40 degrees.
	%
	%           Note also that the viewing distance of the observer may be
	%           calculated from the maparc and rows parameters.
	%
	% 'halfres' Half resolution of the map.  This parameter specifies the
	%           eccentricity at which resolution drops to half the
	%           resolution in the center of the fovea.  For humans, the
	%           half resolution is 2.3 degrees.  2.3 is also the default
	%           value for this parameter.
	resmap = svisresmap(rows*2,cols*2,'halfres', 2.3, 'maparc', map_arc);

	% Create 3 codecs for r, g, and b
	% fprintf('Creating codecs...\n');
	% C=SVISCODEC(SRC) creates a codec that will encode source image SRC.
	c1=sviscodec(red);
	c2=sviscodec(green);
	c3=sviscodec(blue);

	% The masks get created when you set the map
	% fprintf('Creating blending masks...\n');
	% SVISSETRESMAP(C,R) sets codec C's resolution map to image R.
	svissetresmap(c1,resmap)
	svissetresmap(c2,resmap)
	svissetresmap(c3,resmap)

	% Encode gaze
	i1 = svisencode(c1, gaze(1), gaze(2));
	i2 = svisencode(c2, gaze(1), gaze(2));
	i3 = svisencode(c3, gaze(1), gaze(2));

	% Put them back together
	rgb = cat(3, i1, i2, i3);

	% draw circle to indicate gaze point
	if draw_circle
		rgb = insertShape(rgb, 'circle', [gaze(2) gaze(1) 20], 'LineWidth', 3);
	end

end
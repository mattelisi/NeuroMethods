% this script illustrates how to create phase-scrambled images 
% Here we create phase-scrambled images of a building and a face,
% at various levels of scrambling. These images could be used as stimuli 
% in an experiment.
% Matteo Lisi, 2022
clear all

% import images in matlab
found_im = mat2gray(double(imread('founders_bw.JPG')));
matteo_im = mat2gray(double(imread('matteo_bw.JPG')));
kyle_im = mat2gray(double(imread('kyle_bw.JPG')));
house_im = mat2gray(double(imread('house_bw.JPG')));

% approximately equalize the histogram of gray levels of both images
% using histogram matching with target a composition of all images
combined_im = [matteo_im, found_im; kyle_im, house_im ];
found_im = imhistmatch(found_im, combined_im);
matteo_im = imhistmatch(matteo_im, combined_im);
house_im = imhistmatch(house_im, combined_im);
kyle_im = imhistmatch(kyle_im, combined_im);

% filter 
found_im = imgaussfilt(found_im, 2);
matteo_im = imgaussfilt(matteo_im, 2);
house_im = imgaussfilt(house_im, 2);
kyle_im = imgaussfilt(kyle_im, 2);

% visualize images
imshow([matteo_im, kyle_im; found_im, house_im ]);

% as a sanity check, we verify that average grayscale levels of the images 
% is similar (so that they cannot be distinguished based on brightness alone)
mean(matteo_im(:))
mean(kyle_im(:))

% apply phase scrambling
found_1 = imscramble(found_im,0.4, 'cutoff');
found_2 = imscramble(found_im,0.6, 'cutoff');
found_3 = imscramble(found_im,0.9, 'cutoff');

matteo_1 = imscramble(matteo_im,0.4, 'cutoff');
matteo_2 = imscramble(matteo_im,0.6, 'cutoff');
matteo_3 = imscramble(matteo_im,0.9, 'cutoff');

house_1 = imscramble(house_im,0.4, 'cutoff');
house_2 = imscramble(house_im,0.6, 'cutoff');
house_3 = imscramble(house_im,0.9, 'cutoff');

kyle_1 = imscramble(kyle_im,0.4, 'cutoff');
kyle_2 = imscramble(kyle_im,0.6, 'cutoff');
kyle_3 = imscramble(kyle_im,0.9, 'cutoff');


% visualize output in one single image
image_all = [matteo_im, matteo_1, matteo_2, matteo_3; 
             kyle_im, kyle_1, kyle_2, kyle_3; 
             found_im, found_1, found_2,  found_3;
             house_im, house_1, house_2, house_3 ];
imshow(image_all)
imwrite(image_all,'combined.JPG');


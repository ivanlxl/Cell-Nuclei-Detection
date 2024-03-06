% Load the image
original_img = imread('StackNinja3.bmp');

%Apply contrast enhancement to brighten the image
brighten_img = imlocalbrighten(original_img);

% Separate the the colur channels and calculate the corrected green channel
greenChannel = brighten_img(:,:,2);
redChannel = brighten_img(:,:,1);
blueChannel = brighten_img(:,:,3);
greenPic = (greenChannel - (redChannel+blueChannel)/2);

%Apply Median Filtering
filtered_img = medfilt2(greenPic, [5 5]);

% Binarise the image using adaptive method
T = adaptthresh(filtered_img, 0.3); %Set adaptive threshold with sensitivity 0.3
binary_img = imbinarize(filtered_img, T);

%Watershed
dist_trans = bwdist(~binary_img); %Calculate Euclidean Distance
dist_trans = imhmin(dist_trans, 3); % suppress minima with height smaller than 3
dist_trans = -dist_trans; 
watershed_img = watershed(dist_trans); 
watershed_img(~binary_img) = 0;
rgb = label2rgb(watershed_img);


%Convert white background to black, and all non white pixels to white
gray_img = rgb2gray(rgb);
white_mask = gray_img >= 250;
gray_img(white_mask) = 0;
gray_img(~white_mask) = 255;


%Apply Opening
se = strel('disk', 2);
opened_img = imopen(gray_img, se);

% Label the connected components in the binary mask
labeled_component_mask = bwlabel(opened_img);

% Find the number of connected components (white cells) in the image
numObjs = max(labeled_component_mask(:));

% Generate a random RGB color for each component 
colors = rand(numObjs,3);

% Create a new RGB image where each object is colored with a random color
final_img = label2rgb(labeled_component_mask, colors);

%change background to black
white_mask = final_img >= 250;
final_img(white_mask) = 0;

figure();
imshow(final_img); title("Final Image") 
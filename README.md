
# GlioMap:  MATLAB-based GUI for MRI Brain Tumor Segmentation and Feature Extraction

GlioMap is an open-source MATLAB-based software designed for segmenting brain tumors and feature extraction in brain MRI images. The software provides an interactive graphical user interface (GUI) that facilitates pre-processing, skull stripping, semi automate segmentation, morphological features calculation, radiomic features calculation, and result visualization. It is intended for researchers, clinicians, and students in the medical imaging and radiology fields. 




## Software features 

This interface is built based on MATLAB for segmenting 2D MRI brain images. GlioMap interface provides slice by slice brain MRI image visualization, image normalization techniques, bias field correction techniques, contrast adjustment facilities, skull stripping facilities, segmentation facilities, and both radiomic and morphological features extraction facilities.

GlioMap interface includes the following main modulars:
1.	Load modular: load the MRI image. 
2.	Skull strip modular: Facilitate for remove skull area from images
3.	Preprocessing modular: provide normalization, bias field correction.
4.	Slice navigator: facilitates going through the slice sequence and video play of the sequence.
5.	Contrast and brightness changer: facilitates changing contrast and brightness of the image for better visualization.
6.	Select slice modular: facilitates selecting tumor slices in the sequence.
7.	Thresholding tools: facilitate thresholding MRI image.
8.	Draw and erase tools:  facilitate drawing or erasing threshold areas.
9.	ROI manager: provide tools for drawing, adjusting, and erasing ROI areas for segmentation.
10.	 Masking modular: facilitates generating mask images and applying a mask to another image. 
11.	Feature calculation modular: facilitates for calculation of radiomic and morphological features of the entire MRI image or a selected area 
12.	Output modular: provide save options to save segmented image, skull stripped images, mask images, and calculated features.

##  System Requirements

MATLAB software

NFTI tool box


##  Installation Instructions

1.	Download all source code files and logo.png file ( Git clone or download ZIP ).
2.	Create new folder and save all code flies and logo .png file and NFTI tool box also add to this folder.
3.	Open MATLAB software and set NFTI tool box path.
Example:

a.	Unzip NFTI tool box in to folder 

b.	In MATLAB run:  
      addpath('C:\MATLAB\toolboxes\nifti_toolbox'); 

  If folder in subfolder:  addpath(genpath  ('C:\MATLAB\toolboxes\nifti_toolbox')); 

c.	Test the tool box:   
  nii = load_nii('sample.nii');

imshow(nii.img(:,:,50), []);

4.    run Gliomap.m  file

## User Guide
For the user Guide see the [User_guide](user_guide) file
## License

This project is licensed under the MIT License.  
See the [LICENSE](LICENSE) file for details.

## Author Info

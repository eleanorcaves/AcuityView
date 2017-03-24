# AcuityView
This code provides a simple method for representing a visual scene (i.e. modifying an image) as it may be seen by an animal with less acute vision. For more information please refer to, and when using please cite, the original publication: XXXXXXXX
•	Authors: Eleanor Caves and Sönke Johnsen
•	E-mail: eleanor.caves@gmail.com
•	Date: March 21, 2017
•	Version: 0.1
•	Copyright (C) 2017 Eleanor Caves and Sönke Johnsen

1. Downloading and opening R and RStudio
•	AcuityView is a code that runs using R, which is a free software environment for statistical computing and graphics. R is available for free download at https://www.r-project.org/. Please follow the instructions provided on the R website for downloading the program.
•	We highly recommend using RStudio, which provides a graphical user interface for many R commands, and which is available for free download at https://www.rstudio.com/. Please follow the instructions provided on the R website for downloading the program. To operate R Studio, you must also download R. 

2. Opening AcuityView 
•	The AcuityView code is available as a .R file in the supplementary information of the original publication (LINK HERE). 
•	To use AcuityView, download the .R file and place it on your desktop (or whichever file path represents the working directory in your R Studio). 
•	Open R Studio, and select Session → Set working directory → choose directory. Set your working directory to wherever you have placed the AcuityView.R file, for example your desktop. Then use file→ open to open AcuityView.R in R Studio.

3. Preparing Your Image File
•	File Size: 
o	AcuityView has several requirements for the image file in order for it to be correctly processed. First, the image must be square and must have pixel dimensions that are a power of two (meaning that the pixel size of each side must be 2n, where n is any positive integer). This has to do with the mathematics behind Fourier transforms; see main text for further details. For example, pixel sizes of 512x512, 1024x1024, 2048x2048 , etc. will work. If you have started with an image that is non-square, you can resize it easily using the software ImageJ, which is a free image-editing software available for download at https://imagej.nih.gov/ij/download.html. 
•	File Format: 
o	AcuityView requires that image files be either .bmp, .jpeg , or .png. ImageJ software (above) can also export images to these formats. AcuityView version 0.1 requires that files must be three-channel images; if you wish to examine only one channel, we recommend running AcuityView on a three-channel image and then using a software like ImageJ to extract the color channel of interest .

4. Installing Package Dependencies
•	AcuityView is dependent upon several other packages, listed at the top of the AcuityView.R script file under “depends.” They are the packages imager, fftwtools, pracma, plotrix, tools, and grid. 
•	To use AcuityView, you must first install these packages. You can do this either by typing into the command line install.packages(“packagename”) or by navigating to Tools→Install packages in R Studio. 
•	After installing a package, you must call its library for it to be usable. To do so, type library(“packagename”) in the command line. Calling the required libraries is also built in to the first few lines of code in AcuityView.

Once the necessary packages and their libraries are ready, you can use AcuityView. First, type into the command line, source(“AcuityView.R”). This will load the AcuityView file. If an error appears, you likely have not correctly placed the AcuityView.R file in your working directory. If no errors appear, AcuityView is now ready to run.  

5. Running the AcuityView Program
•	To run AcuityView, you type one line of code, in which you will specify the following:
o	photo: using NULL will cause a prompt to appear whereby you can navigate to your image; alternatively, you can enter the file name for your photo, but the photo must be located in your working directory.
o	distance: distance is the distance from the viewer to the object of interest in the image; distance can be in any units as long as it is the same units as realWidth.
o	realWidth: realWidth is the real width of the entire image; realWidth can be in any units as long as it is the same units as distance.
o	eyeResolutionX: the resolution of the viewer, in units of degrees.
o	eyeResolutionY: NULL will be the standard choice here; very rarely, eyes have different acuities in the X and Y directions, in which case you may specify a different Y acuity than X acuity using this option.
o	plot: T will produce a plot of your final image, in addition to saving the final image to your working directly; F will not plot the image, though the image will still be saved to your working directory.
o	output: enter the file name for your output file, which will be placed in your working directory; use the format “filename.filetype”. Output filetype can be .bmp, .png, or .jpeg. 

Example line of command code:
AcuityView(photo = NULL, distance = 0.5, realWidth = 3, eyeResolutionX = 0.2, eyeResolutionY = NULL, plot = T, output="Acuity_image.jpeg")

# AcuityView

AcuityView User Guide
AcuityView is a package that provides a simple method for representing a visual scene as it may be seen by an animal with less acute vision. For more information please refer to, and when using please cite, the original publication in Methods in Ecology and Evolution
•	Authors: Eleanor Caves and Sönke Johnsen
•	E-mail: eleanor.caves@gmail.com
•	Date: Packaged May 8, 2017
•	Version: 0.1
•	Copyright (C) 2017 Eleanor Caves and Sönke Johnsen

1. Downloading and opening R and RStudio
•	AcuityView is a package that runs using R, which is a free software environment for statistical computing and graphics. R is available for free download at https://www.r-project.org/. Please follow the instructions provided on the R website for downloading the program.
•	We highly recommend using RStudio, which provides a graphical user interface for many R commands, and which is available for free download at https://www.rstudio.com/. Please follow the instructions provided on the R website for downloading the program. To operate R Studio, you must also download R. 

2. Installing AcuityView 
•	The AcuityView package is available for download from the R CRAN.  
•	To install AcuityView, you can use the “install.packages” command in R, after which you must also run the library(AcuityView) command.
•	An example photo is automatically supplied in the AcuityView download; the same example photo is used at the end of this guide. 

3. Preparing Your Image File
•	Image Size: 
o	AcuityView has several requirements for the image file in order for it to be correctly processed. First, the image must be square and must have pixel dimensions that are a power of two (meaning that the pixel size of each side must be 2n, where n is any positive integer). For example, pixel sizes of 512x512, 1024x1024, 2048x2048, etc. will work. If you have started with an image that is non-square, you can resize it easily using the software ImageJ, which is a free image-editing software available for download at https://imagej.nih.gov/ij/download.html. 
•	File Format: 
o	AcuityView requires that image files be either .bmp, .jpeg, or .png. ImageJ software (above) can also export images to these formats. AcuityView version 0.1 requires that files must be three-channel images; if you wish to examine only one channel, we recommend running AcuityView on a three-channel image and then using a software like ImageJ to extract the color channel of interest.
o	You may use any file format; no specific format (i.e. RAW) is required. The image you use should, however, be sharp and in focus.

4. Running the AcuityView Program
•	After installing the AcuityView package and library, the function can be run using one line of code. The parameters necessary are:
o	photo: using NULL will cause a prompt to appear whereby you can navigate to your image; alternatively, you can enter the file name for your photo, but the photo must be located in your working directory.
o	distance: distance is the distance from the viewer to the object of interest in the image; distance can be in any units as long as it is the same units as realWidth.
o	realWidth: realWidth is the real width of the entire image, calibrated using the  object of interest; realWidth can be in any units as long as it is the same units as distance.
o	eyeResolutionX: the minimum resolvable angle of the viewer, in units of degrees (*note that acuity is often reported in the literature in cycles/degree, which is the inverse of degrees)
o	eyeResolutionY: NULL will be the standard choice here; very rarely, eyes have different acuities in the X and Y directions, in which case you may specify a different Y acuity than X acuity using this option.
o	plot: T will produce a plot of your final image, in addition to saving the final image to your working directory; F will not plot the image, though the image will still be saved to your working directory.
o	output: enter the file name for your output file, which will be placed in your working directory; use the format “filename.filetype”. Output filetype can be .bmp, .png, or .jpeg. 

A note for Linux users:
You may need to install the fftw library in order for the dependent R package "fftwtools" to install and perform correctly. The FFTW website and install information can be found here: http://www.fftw.org/. This library can easily be installed on Ubuntu with: apt-get install fftw3-dev

Example line of command code:
AcuityView(photo = NULL, distance = 0.5, realWidth = 3, eyeResolutionX = 0.2, eyeResolutionY = NULL, plot = T, output="Acuity_image.jpeg")


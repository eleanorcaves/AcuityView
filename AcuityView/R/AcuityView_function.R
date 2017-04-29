#'AcuityView
#'
#'This function provides a simple method for displaying a visual scene as it may appear to an animal with lower acuity.
#'@param photo The photo you wish to alter; if NULL then a pop up window allows you to navigate to your photo, otherwise include the file path here
#'@param distance The distance from the viewer to the object of interest in the image; can be in any units so long as it is in the same units as RealWidth
#'@param realWidth The real width of the entire image; can be in any units as long as it is in the same units as distance 
#'@param eyeResolutionX The resolution of the viewer in degrees
#'@param eyeResolutionY The resolution of the viewer in the Y direction, if different than ResolutionX; defaults to NULL, as it is uncommon for this to differ from eyeResolutionX
#'@param plot Whether to plot the final image; defaults to T, but if F, the final image will still be saved to your working directory
#'@param output The name of the output file, must be in the format of output="image_name.filetype"; acceptable filetypes are .bmp, .png, or .jpeg
#'@examples AcuityView(photo = NULL, distance = 2, realWidth = 2, eyeResolutionX = 0.2, eyeResolutionY = NULL, plot = T, output="Test.jpeg")
#'@return Returns an image in the specified format
#'@section Image Format Requirements: Image must be in 3-channel format, either PNG, JPEG or BMP. Note: some PNG files have an alpha channel that makes them 4-channel images; this will not work with the code. The image must be 3-channel.
#'@section Image size: Image must be square with each side a power of 2 pixels. Example: 512x512, 1024 x 1024, 2048 x 2048 pixels
#'AcuityView()


# Main function
AcuityView = function(photo = NULL, distance = 2, realWidth = 2, eyeResolutionX = 0.2, eyeResolutionY = NULL, plot = T, output="test.jpg"){
 #Install the required libraries 
  library("imager")
  library("fftwtools")
  library("pracma")
  library("plotrix")
  library("tools")
  library("grid") 
  
   # Load the image.  The image must be a 3-channel image.
    if (is.null(photo)) {
        photo = file.choose()
        if (!is.element(file_ext(photo), c("png", "bmp", "jpeg", "jpg"))) stop("Input file must be png, bmp, or jpeg format!")
        image <- load.image(photo)
    } else {
        if (!is.element(file_ext(photo), c("png", "bmp", "jpeg", "jpg"))) stop("Input file must be png, bmp, or jpeg format!")
        image <- load.image(photo)
    }
    if (missing(image)) stop("Failed to load the image file")
    
    # Check that a correct output format is provided
    if (!is.character(output)) stop("Output file must be a character string!")
    if (!is.element(file_ext(output), c("png", "bmp", "jpeg", "jpg"))) stop("Output file must be png, bmp, or jpeg format!")

    # Get image dimensions
    dimensions <- dim(image)
    
    # Check to make sure dimensions are a power of two or give error
    if (!is.element(dimensions[1], 2^c(1:100)) || !is.element(dimensions[2], 2^c(1:100))) {
        stop("Image dimensions must be a power of 2!!!")
    }
    
    # Plot the image if required
    if (plot) {
      Devices = dev.list()
      for (i in Devices) dev.off(i)
        dev.new(width = 7, height = 4)
        par(mfrow = c(1, 2), mar = c(1, 0.1, 2, 0.1))
        plot(image, axes = FALSE, ylab = "", xlab = "", main = "Before")
    }
    
    #  If the X and Y resolutions differ, check here
    if (is.null(eyeResolutionY)) eyeResolutionY <- eyeResolutionX
    
    # Calculate the image width in degrees
    widthInDegrees <- rad2deg(2 * atan(realWidth / distance / 2))
    
    # Extract image width in pixels
    widthInPixels <- dimensions[2]
    
    # Calculate the center of the image
    center <- round(widthInPixels / 2) + 1
    pixelsPerDegree <- widthInPixels / widthInDegrees
    
    
    # Create a blur matrix, with the same dimensions as the image
    # Each element is based on the resolution of the eye, distance to the viewer, and size of the image
    # See main text for more details
    blur <- matrix(NA, nrow = widthInPixels, ncol = widthInPixels)
    for (i in 1:widthInPixels){
        for (j in 1:widthInPixels) {
            x <- i - center
            y <- j - center
            freq <- round(sqrt(x^2 + y^2)) / widthInPixels * pixelsPerDegree
            mySin <- y / sqrt(x^2 + y^2)
            myCos <- x / sqrt(x^2 + y^2)
            eyeResolution <- eyeResolutionX * eyeResolutionY /sqrt((eyeResolutionY * myCos)^2 +(eyeResolutionX * mySin)^2)
            blur[i,j] <- exp(-3.56 * (eyeResolution * freq)^2)
        }
    }
    # Define the center pixel to have a value of 1
    blur[center, center] = 1
    blur<<-blur
    
    # Convert the original 3 color channels into linear RGB space
    # as opposed to sRGB space, which is how color images are usually encoded.
    # Each color channel must be linearized separately.
    splitimage <- imsplit(image,"c")
    channel <- splitimage[[1]][,]
    
    # Convert the data from matrix into array form
    array <- array(NA, dim = c(widthInPixels^2, length(splitimage)))
    for (i in 1:length(splitimage)){
        matrix <- as.matrix(splitimage[[i]])
        vector <- as.vector(rescale(matrix, newrange = c(0, 1)))
        array[,i] <- vector
    }
    
    # Convert red, green, and blue to linearized values
    # Begin by creating an empty array for your linearized values
    linearized_values <- array(NA, dim = c(widthInPixels, widthInPixels, 3))
    dim_array <- dim(array)
    
    # Define the variable "a" for use in converting values to linearized color space
    a <- 0.055
     
    # To find the equations for converting to linearized space, 
    # see main text or: https://en.wikipedia.org/wiki/SRGB
    # Specifically, the section entitled "The reverse transformation."
    
    # Linearize the red color channel
    redlinear <- array(NA, dim = c(dim_array[1], 1))
    for (i in 1:dim_array[1]){
        if (array[i,1] <= 0.04045){
            redlinear[i] <- (array[i,1] / 12.92)
        } else {
            redlinear[i] <- ((array[i,1] + a) /(1 + a))^2.4
        }}
    dim(redlinear) <- dim(splitimage[[1]])
    linearized_values[,,1] <- redlinear
    red_linearized_values<<-linearized_values[,,1]

    # Linearize the green color channel
    greenlinear <- array(NA, dim = c(dim_array[1], 1))
    for (i in 1:dim_array[1]){
        if (array[i,2] <= 0.04045){
            greenlinear[i] <- (array[i,2] / 12.92)
        } else {
            greenlinear[i] <- ((array[i,2] + a)/(1 + a))^2.4
        }
    }
    dim(greenlinear) <- dim(splitimage[[2]])
    linearized_values[,,2] <- greenlinear
    green_linearized_values<<-linearized_values[,,2]
    
    # Linearize the blue color channel
    bluelinear <- array(NA, dim = c(dim_array[1], 1))
    for (i in 1:dim_array[1]){
        if (array[i,3] <= 0.04045){
            bluelinear[i] <- (array[i,3]/12.92)
        } else {
            bluelinear[i] <- ((array[i,3] + a) / (1 + a))^2.4
        }
    }
    dim(bluelinear) <- dim(splitimage[[3]])
    linearized_values[,,3] <- bluelinear
    blue_linearized_values<<-linearized_values[,,3]

    
    # Perform the 2-D Fourier Transform, blur matrix multiplication
    # and inverse fourier transform on the linearized color values:
    final <- array(NA, dim = c(widthInPixels, widthInPixels, length(splitimage)))
    for (i in 1:length(splitimage)){
        matrix <- linearized_values[,,i]
        fft <- (1/widthInPixels) * fft_matrix_shift(fftw2d(matrix, inverse = 0))
        transform <- fft * blur
        ifft <- (1/widthInPixels) * fftw2d(transform, inverse = 1)
        final[,,i] <- Mod(ifft)
    }
    
     final_red<<-final[,,1]
     final_green<<-final[,,2]
     final_blue<<-final[,,3]
    
    # Now, for display purposes, we need to transform the colors from
    # linearized color space back into sRGB space
    sRGB_values <- array(NA, dim = c(widthInPixels, widthInPixels, 3))
    
    # Each dimension from the three-dimensional "final" array is a color
    # channel that has been linearized, fourier transformed, blurred, and
    # inverse fourier transformed. Create a vector from each of these
    # so that you can do the calculations that retransform things back into
    # sRGB space
    red2 <- as.vector(final[,,1])
    green2 <- as.vector(final[,,2])
    blue2 <- as.vector(final[,,3])
    
    # To see the equations for the transformation to sRGB space,
    # see main text or: https://en.wikipedia.org/wiki/SRGB
    # Speficially the section entitled "The forward transformation."
    # Calculate sRGB values for the red channel
    redsRGB <- array(NA, dim = c(dim_array[1]))
    for (i in 1:dim_array[1]){
        if (red2[i] < 0.0031308){
            redsRGB[i] <- (red2[i] * 12.92)
        } else {
            redsRGB[i] <- (((1 + a) * red2[i]^(1 / 2.4)) - a)
        }
    }
    dim(redsRGB) <- dim(splitimage[[1]])
    sRGB_values[,,1] <- redsRGB
    red_sRGB<<-sRGB_values[,,1]
    
    # Calculate sRGB values for the green channel
    greensRGB <- array(NA, dim = c(dim_array[1]))
    for (i in 1:dim_array[1]){
        if (green2[i] < 0.0031308){
            greensRGB[i] <- (green2[i] * 12.92)
        } else {
            greensRGB[i] <- (((1 + a) * green2[i]^(1 / 2.4)) - a)
        }
    }
    dim(greensRGB) <- dim(splitimage[[1]])
    sRGB_values[,,2] <- greensRGB
    green_sRGB<<-sRGB_values[,,2]
    
    # Calculate sRGB values for the blue channel
    bluesRGB <- array(NA, dim = c(dim_array[1]))  
    for (i in 1:dim_array[1]){
        if (blue2[i] < 0.0031308){
            bluesRGB[i] <- (blue2[i] * 12.92)
        } else {
            bluesRGB[i] <- (((1 + a) * blue2[i]^(1 / 2.4)) - a)
        }
    }
    dim(bluesRGB) <- dim(splitimage[[1]])
    sRGB_values[,,3] <- bluesRGB
    blue_sRGB<<-sRGB_values[,,3]
    
    # Rescale the sRGB values so that the maximum is equal to 1,
    # for the purposes of displaying the image
    # Note: depending on the particular original image, the maximum
    # values may not be above 1; scaling is only necessary if the
    # maximum value is >1, hence the if/else statement
    if (max(sRGB_values[,,1]) > 1){
      rsc <- rescale(sRGB_values[,,1], newrange = c(min(sRGB_values[,,1]), 1))
    } else {
      rsc <- sRGB_values[,,1]
    }
    
    if (max(sRGB_values[,,2]) > 1){
      gsc <- rescale(sRGB_values[,,2], newrange = c(min(sRGB_values[,,2]), 1))
    } else {
      gsc <- sRGB_values[,,2]
    }
    
    if (max(sRGB_values[,,3]) > 1){
      bsc <- rescale(sRGB_values[,,3], newrange = c(min(sRGB_values[,,3]), 1))
    } else {
      bsc <- sRGB_values[,,3]
    }
    
    # Put the rescaled sRGB values into an array to plot as a raster,
    # which displays them as an image
    # This array should have the same dimensions as the original image
    rgbmatrix <- array(NA, dim = c(widthInPixels, widthInPixels, length(splitimage)))
    
    
    # Because of the fourier transform, the matrix needs to be transposed
    # or the final image will end up sideways
    rgbmatrix[,,1] <- t(rsc)
    rgbmatrix[,,2] <- t(gsc)
    rgbmatrix[,,3] <- t(bsc)
    
    rgbmatrix_red<<-rgbmatrix[,,1]
    rgbmatrix_green<<-rgbmatrix[,,2]
    rgbmatrix_blue<<-rgbmatrix[,,3]
    
    # Save output file in the provided format
    if (file_ext(output) == "png") {
        png(filename = output, width = dimensions[2], height = dimensions[2], units = "px")
        grid.raster(rgbmatrix, interpolate = FALSE)
        dev.off()
    }
    if (file_ext(output) == "bmp") {
        png(filename = output, width = dimensions[2], height = dimensions[2], units = "px")
        grid.raster(rgbmatrix, interpolate = FALSE)
        dev.off()
    }
    if (file_ext(output) == "jpeg") {
        png(filename = output, width = dimensions[2], height = dimensions[2], units = "px")
        grid.raster(rgbmatrix, interpolate = FALSE)
        dev.off()
    }
    if (file_ext(output) == "jpg") {
        png(filename = output, width = dimensions[2], height = dimensions[2], units = "px")
        grid.raster(rgbmatrix, interpolate = FALSE)
        dev.off()
}
    
    # Now, display the final image (represented in rgbmatrix) in a separate box
    if (plot) {
        #grid.raster(rgbmatrix, interpolate = FALSE)
        plot(c(0, ncol(rgbmatrix)), c(0, nrow(rgbmatrix)), type = "n", axes = F, xlab = "", ylab = "", main = "After")
        rasterImage(rgbmatrix, 1, 1, ncol(rgbmatrix), nrow(rgbmatrix), interpolate = FALSE)
        message(paste0('To save the side-by-side image, use a command like this before closing the device:\ndev.copy(jpeg,file="sidebyside.jpg")'))
    }
    
    message(paste0("The results are complete.  The output file has been saved to ", output))
    
} # End of function


#'FFTMatrixShift
#'
#'This function rearranges the output of the FFT by moving the zero frequency component to the center
#'fft_matrix_shift()

fft_matrix_shift <- function(input_matrix, dim = -1) {
    rows <- dim(input_matrix)[1]
    cols <- dim(input_matrix)[2]
    
    # You need a check here for if dim != -1 or is NULL
    if (dim == -1) {
        input_matrix <- swap_up_down(input_matrix)
        return(swap_left_right(input_matrix))
    }
}

swap_up_down <- function(input_matrix) {
    rows <- dim(input_matrix)[1]
    cols <- dim(input_matrix)[2]
    rows_half <- ceiling(rows / 2)
    return(rbind(input_matrix[((rows_half + 1):rows), (1:cols)], input_matrix[(1:rows_half), (1:cols)]))
}

swap_left_right <- function(input_matrix) {
    rows <- dim(input_matrix)[1]
    cols <- dim(input_matrix)[2]
    cols_half <- ceiling(cols / 2)
    return(cbind(input_matrix[1:rows, ((cols_half+1):cols)], input_matrix[1:rows, 1:cols_half]))
}


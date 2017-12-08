#############################################
	GROUP RE3: WILDCAT DESIGN
#############################################	
# DESCRIPTION
This code takes inputs for a small unmanned airship and parameterizes the 3D CAD files to work with the desired inputs.

# RUN
To run the code simply launch main.m in Matlab R2016a
Ensure that the Matlab current folder is the MATLAB folder where main.m is located, otherwise errors will occur when writing to the log and SolidWorks files.

1. Enter two of Length, Width, or Fineness Ratio into the envelope dimensions section
2. Press the calculate button to see if there are any warnings with the input dimensions
3. Set the sliders to the desired values for each of the input parameters
4. Select the desired driving parameter from the radio buttons beside the slider. These will force the program to ensure that parameter is met and will reduce the others as needed.
5. Press Generate
6. Check on the code in the command window in Matlab to see the status
7. Review the results that are displayed on the GUI


# HELP
~Code is taking a long time to run:
The code will attempt to hit all the parameters set in the GUI and will reduce the two non driving values. If the sliders are all maxed out it will have to lower the values on each pass through the code until it can solve it. Reduce the non-driving parameters if the simulation is being run many times. The progress can be seen in the Command Window.

~Warning next to the generate button:
The warning next to the generate button is from the envelope dimensions and is to let the user know there might be issues with some of the values input. Depending on the error, increase or decrease the values.

~Warning pop-up:
If the code runs until end and a pop-up warning comes up, there was an issue meeting the driving parameter or minimum specifications. Generally the best way to fix them is reduce the parameter and/or increase the airship volume.

~Error pop-up:
Error pop-ups will stop the code from running if there is issues with the envelope values entered. There is also a error message at the end if the net weight of the airship is negative (not an airship if it can't fly). Generally changing the envelope dimensions will resolve these errors.

~Unhandled error:
These are errors coming from Matlab and not handled by the program. The first thing to check is that the Matlab current folder is the folder with main.m. Other option is to try different inputs into the GUI. If nothing is working, email apenn095@uottawa.ca.

~More help?
The report Appendix has a section on the GUI of the program which goes much more in depth compared to this readme
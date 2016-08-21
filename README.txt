Author: Liam Moynihan
with support from Sina Afshari, Dr. Sandipan Mishra, and others.

This tool was developed at the Smart Lighting ERC, Rensselaer Polytechnic Institute (http://smartlighting.rpi.edu/)
It is made open-source through the support of the Rensselaer Center for Open Source Software (http://rcos.rpi.edu/)

=========
| Basic Usage |
=========
1) Download and place folder in a convenient loaction for access with Matlab

2) run color_matcher_gui.m using matlab

3) The TestData folder includes data that can be imported as part of the below demo:
	*rgbaw.txt contains spectral data from 5 LEDs (red, green, blue, amber, and white) along with lux and power data
	for them. Format is wavelength in the first column with spd(s) in the next column(s). Max Lux data for the LEDs 
	can be included with a 0 in the wavelength column. Max power is marked with a -1 in the wavelength column.
	*The other files contain data for various other light sources.

4) In the gui, select 'Import LED' and navigate to rgbaw.txt. Select 'Import Ideal' and choose any of the other 
   sources in TestData. The spectra of the individual LEDs will appear in the main plot. You can compare the ideal spectrum
   with the generated spectrum by selecting the dropdown list above the plot. 

5) Select the 'Color Spaces' tab to compare the ideal and generated lights in more detail. 

6) Return to the 'Spectrum Setup' tab and note that there are sliders and text boxes that allow you to apply multipliers 
to each LED. This allows you to manually change the generated light by varying the multipliers of the individual LEDs. 

7) Depending on the ideal spectrum you imported, it may be too bright match with the LEDs. You can compensate for this by
   reducing the ideal lux using the textbox under 'Ideal Spectrum and Lux'. 

8) There is a section for simple optimizations. Simply select one from the dropdown and clicking 'Optimize'.

9) You have more control over the optimization in the 'Complex Optimizations' section. This optimizes the LED multipliers
   based on a summation cost function of the form

	f=A*CRI+B*power+C*dE

   CRI is the color rendering index of the generated light, power is the power of the generated function, and dE is the color 
   difference between the generated and ideal lights. A, B, and C are the weights that are controlled by the user in the 
   first row of text boxes in this section. The second row provides constraints on those same attributes, as well as total
   lux of  the generated spectrum. Setting the CRI constraint to 80 will require the optimizer to produce a generated spectrum
   with >80 CRI. Similarly, setting the power constraint to 20 will require the optimizer to produced a generated spectrum 
   that uses less than 20 watts. 

10) You can also toggle between using CRI and CQS (two similar color science metrics), and cycle between several ways of
    measuring color difference, by selecting the labels in the 'Complex Optimization' table. Try changing the color 
    difference column from LUV dE to JNDs, or 'Just-Noticeable Difference'. This uses a 3-step MacAdams Ellipse to 
    approximate the color difference that the average person would notice.

11) You can remove any constraint or weighting term from consideration by entering a non-numeric string in the appropriate
    text box. It will switch to 'Off'.

12) For demo, set all the weights to 'Off' except CRI. Remove all the constraints except for 'JND', which you should set 
    to 1. Select the 'Optimize' button. This will optimize the LED multipliers to maximize the CRI (since that is the only
    term in the cost function) while requiring that the generated color is within 1 JND of the ideal color. Note that
    with this setup the brightness is not a consideration for the optimization, so the generated spectrum could be
    considerably darker than the ideal. You can use the lux constraint to require a certain brightness, or you can use a 
    different color difference measurement which takes brightness into account. 

NOTE: Do not modify the name, content, or location of the RequiredData folder.

===============================================
| Major sources referenced during development |
===============================================
1)	Wendy Davis and Yoshi Ohno. Their paper, which defined the CQS metric, was also referenced for calculations
	http://opticalengineering.spiedigitallibrary.org/article.aspx?articleid=1096282

2)	Bruce Lindbloom, whose site was useful as a source of information. Also used transform matrices available on 
	his website. 
	http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html

4)	Professor Andrew Bierman, from the Lighting Research Center
	http://www.lrc.rpi.edu/
	Provided the "macAdamEllipse.m" function, and associated data.

5)      Matt Aldrich, author of the matlab toolbox 'pspectro'
	Some data that was used for this tool originated with pspectro
	Some code from pspectro was also used and modified (see get_cri1995 and get_nrefspd functions). Copyright information for pspectro included below.

	http://www.mathworks.com/matlabcentral/fileexchange/28185-pspectro--photometric-and-colorimetric-calculations
	http://resenv.media.mit.edu/lighting/
	
	Copyright (c) 2010, Matt Aldrich
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are
	met:

	    * Redistributions of source code must retain the above copyright
	      notice, this list of conditions and the following disclaimer.
        * Redistributions in binary form must reproduce the above copyright
          notice, this list of conditions and the following disclaimer in
          the documentation and/or other materials provided with the distribution

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
	
	
6) 	Jeff Mathers, for his matlab toolbox "Spectral and XYZ Color Functions"
	http://www.mathworks.com/matlabcentral/fileexchange/7021-spectral-and-xyz-color-functions
	Several functions were used to allow spectra to be plotted with color corresponding to wavelength
	
	His copyright is below
	
	Copyright (c) 2010, Jeff Mather
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are
	met:

		* Redistributions of source code must retain the above copyright
		  notice, this list of conditions and the following disclaimer.
		* Redistributions in binary form must reproduce the above copyright
		  notice, this list of conditions and the following disclaimer in
		  the documentation and/or other materials provided with the distribution

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.

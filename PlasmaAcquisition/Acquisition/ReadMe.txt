LabView Instructions:
	- begin with setting the NIDAQ and amplification circuitry in place
	- run 'LangmuirProbeControlV2.vi'
	- after conducting the appropriate ion/electron cleaning set the max and min voltage for the sweep
	- click 'Log Data' and then run the program
	- when the program starts running a .lvm file will be created in the directory
	- after a few second there will tens of I-V or d2IdV2-V curves in the file
	- click 'STOP'
	- rename the .lvm file that was created so that using the program again doesn't overwrite the file
	- continue for all plasma conditions that are to be analyzed
	- if using ReadInData.m ensure that all data files are placed in a separates directory once complete
	
In the folder 'Documentation' is a .7z file containing all the files associated with the LabView program used as created by Barrett Taylor
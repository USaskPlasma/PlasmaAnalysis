LabView:
	- if you're using an NIDAQ and the LabView program included in the folder 'Acquisition' located in the previous directory 
		then see the ReadMe.txt in that folder

ReadInData:
	- if you're using the provided LabView program then you can use ReadInProbeData.m to read in and format the data for analysis
	- to use ReadInData first set up the indicated input parameters inside the script
	- ensure that all of the data to be formatted is in its own separate directory 
	- also ensure that the files corresponding to the analog second derivative is ordered immediately after the non-differentiated signal data
	- run the script
	- select the directory containing the data to be formatted
	- plots of individual I-V and d2IdV2-V curves from each file will be presented for inspection
	- press 'y' to use that curve, 'n' to reject it, 'r' to redo the selection of the file's data, and 'b' to go back to redo the previous
		file's data
	- once the amount of I-V and d2IdV2-V curves corresponding to sweepsPerSet and maxSets are entered the data is written to a .csv file and
		place in FormattedData and then the next files data is presented
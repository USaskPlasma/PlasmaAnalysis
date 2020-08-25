Function Documentation:
	Every function has a separate text file in Functions_Docs containing it's usage, what functions use it, what custom functions it uses,
		its doc-string, global variables and local (temporary) variables, as well as some attempt at explaining the function's logic/structure.
		
Operation:
	PlasmaAnalysis:
		- set all parameters in PlasmaAnalysis.m in accordance to the section 'Input Parameters' and the probe and ion properties
		- once all parameters are set run the script to begin the analysis   

	NumericalAnalysis:
		- if NumericalAnalysis is to be done a plot of the current-voltage curve and a GUI for parameters for the numerical differentiation will appear
		- enter in the polynomial order and window length of the smoothing to be done (notice, the window length must be a positive, odd integer)
		- once values are entered click 'Update Plot' to inspect the shape of the numerical derivatives
		- the polynomial order and window length can be adjusted until satisfactory numerical derivatives are obtained
		- once complete, click 'Continue' to go to the next iteration, 'Continue to Next Run' to proceed to the next dataset
			using current inputs for smoothing for the remaining iterations, or click 'Continue for all Runs' to use the current inputs
			for the remaining iterations and datasets without further prompting
		- Notice: if LangmuirAnalysis is also to be done then continuing for the remaining iterations or datasets will also prevent further
			prompting from the GUI for the LangmuirAnalysis. Ensure that values for the LangmuirAnalysis are inputted before doing this
		- if the numerical derivatives are too jagged or require too much smoothing then clicking 'Abort' will stop NumericalAnalysis and 
			use LangmuirAnalysis instead
	
	LangmuirAnalysis:
		- if LangmuirAnalysis is to be done a plot of the log of current vs voltage and a GUI for LangmuirAnalysis parameters will appear
		- enter in values for the boundaries of the linear regions of the pre-electron saturation and electron saturation regions
		- once values are entered click 'Update Plot' to inspect the linear fits to the two regions
		- once complete, click 'Continue' to go to the next iteration, 'Continue to Next Run' to proceed to the next dataset
			using current inputs for the remaining iterations, or click 'Continue for all Runs' to use the current inputs
			for the remaining iterations and datasets without further prompting
	
	Reading in Results:
		- after the entire analysis is complete, output files containing the results are created and placed in the Results folder
		- use the script, ReadInResults.m to create Matlab structures of the results
		- use the variables FName and StrucName to determine what files get read in and what their corresponding structure name
			will be
		- FName and StrucName are to be given as cell arrays
		- Notice: any extra files in results (i.e. files corresponding to EEDFs, ion current, and average input data) will all be included so
			long as the main results filename is in FName
		- once FName and StrucName are filled out simply run the script
		- data in the structures can be accessed as described in the script
	
PlasmaAnalysis Inputs/Outputs:
	Input File:
		- Input file is to ordered in columns
		- First column is the number corresponding with the dataset
		- Second column is for voltage data
		- Third column is for current data
		- Fourth column is for the analog second derivative of the current w/ respect to voltage (if available)
		- Any error values are to be absolute values and are to be located in any of the following columns
		
		See InputFormatExample.csv for a very simple example containing made up input values of an I-V curve
	
	Input Parameters:
		Radius: probe radius (in cm)
		Length: probe length (in cm)
		IonAMU: effective ion mass in AMU
		
		V_prefix: factor to bring voltage data to volts (ex. if data is in mV V_prefix = 1e-3)
		I_prefix: factor to bring current data to amps (ex. if data is in mA I_prefix = 1e-3)
		
		Confidence: confidence value for error calculations
		
		Iterations: number of iterations to be done when analyzing each dataset - on first iteration there's no ion current being subtracted,
			on the second ion current is subtracted and different values are obtained which give a different ion current fit and so on...
		LangmuirAnalysis: is a Langmuir method analysis to be done? true or false
		AnalogAnalysis: is an analysis to be done using analog derivatives (assuming they're available)? true or false
		NumericalAnalysis: is an analysis to be done using numerical derivatives? true or false
		
		IonAnalyis: integer to specify which electron current analysis is used for ion current analysis (3 for A, 2 for N, 1 for LM)
		
		V_error_id: is there error to the voltage data included? If yes, which column? If no, enter 0
		I_error_id: is there error to the current data included? If yes, which column? If no, enter 0
		d2IdV2_error_id: is there error to the current analog second derivative data included? If yes, which column? If no, enter 0
		
		FileName: name of output file. If it should be the same name as the input file then enter NaN
		Save_Avg_IV_Data: value for if averages of the input data is to be saved. 1 for yes, 0 for no
		EEDF_Out: value for if EEDFs should be saved. 0 for none, 1 for numerical analysis EEDF, 2 for analog analysis EEDF, 3 for both
		Ion_Current_Out: value for if best ion current fit is to be saved. 1 for yes, 0 for no
		
	Output Files:
		[FileName].csv:	
			Contains standard results from the plasma analysis.
			All values listed below get arranged in a row. Separate rows are for individual I-V & d2IdV2-V curves.
			The last row is for the average values and errors involving the confidence given in Input Parameters.
			If the value is given as NaN that means either the analysis was not conducted or it was unable to be acquired.
			
			Vfl: float potential (in volts)			
			Vfl_err:
			
			Te_A: electron temperature from AnalogAnalysis (in eV)
			Te_err_A:
			Vpl_A: plasma potential (in V)
			Vpl_err_A:
			Ie_sat_A: electron saturation current (in amps)
			Ie_sat_err_A:
			Ne_A: electron density (in N/cm^3)
			Ne_Err_A:
			
			Te_N: electron temperature from NumericalAnalysis (in eV)
			Te_err_N:
			Vpl_N: plasma potential (in V)
			Vpl_err_N:
			Ie_sat_N: electron saturation current (in amps)
			Ie_sat_err_N:
			Ne_N: electron density (in N/cm^3)
			Ne_Err_N:
			
			Te_LM: electron temperature from LangmuirAnalysis (in eV)
			Te_err_LM:
			Vpl_LM: plasma potential (in V)
			Vpl_err_LM:
			Ie_sat_LM: electron saturation current (in amps)
			Ie_sat_err_LM:
			Ne_LM: electron density (in N/cm^3)
			Ne_Err_LM:
			
			N_OML: ion density from OMLanalysis (in N/cm^3)
			N_err_OML:
			Rsq_OML: r-squared value of fit
			
			N_ABR: ion density from ABRanalysis (in N/cm^3)
			N_err_ABR:
			Te_ABR: electron temperature from ABRanalysis (in eV)
			Te_err_ABR:
			Rsq_ABR: r-squared value of fit
			
			N_BRL: ion density from BRLanalysis (in N/cm^3)
			N_err_BRL:
			Te_BRL: electron temperature from BRLanalysis (in eV)
			Te_err_BRL:
			Rsq_BRL: r-squared value of fit
			
		[FileName]_AvgData.csv:
			Contains all input data average for every I-V and d2IdV2-V curves.
			Creation is specified by Save_Avg_IV_Data
			
			Column 1 contains voltage data, V (in volts)
			Column 2 contains absolute voltage error, V_err (in volts)
			Column 3 contains current data, I (in amps)
			Column 4 contains absolute current error, I_err (in amps)
			Column 5 contains current second derivative data, if applicable
			Column 6 contains absolute current second derivative data, if applicable
			
		[FileName]_EEDF_A.csv:
			Contains voltage and corresponding values for the Electron Energy 
			Distribution Function acquired from AnalogAnalysis
			Creation is specified by EEDF_Out
			
			Column 1 contains voltage data, V_EEDF_A (in volts)
			Column 2 contains corresponding EEDF_A values (in eV)
			
		[FileName]_EEDF_N.csv:
			Contains voltage and corresponding values for the Electron Energy 
			Distribution Function acquired from NumericalAnalysis
			Creation is specified by EEDF_Out
			
			Column 1 contains voltage data, V_EEDF_N (in volts)
			Column 2 contains corresponding EEDF_N values (in eV)
	
		[FileName]_Iion_[ABR|BRL|OML].csv:
			Contains voltage and calculated ion current from the model of best fit.
			Column 1 contains voltage data, V_[ABR|BRL|OML] (in volts)
			Column 2 contains ion current data, I_[ABR|BRL|OML] (in amps)
		
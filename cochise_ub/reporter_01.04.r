# Copyleft 2010-11 Xavier de Pedro (GNU/GPL'd)
# xavier.depedro(a)ub.edu - $Revision-Id$
#
############################################################
## PARAMETERS
clean_r_environ_at_start <- 0 # Param to remove all objects in the R environment before starting the reporting
	# Clean R objects if requested
	if (clean_r_environ_at_start == 1) { rm(list = ls() )}

# Name of this r script to report student activity from the traces file information
reporter_r_script = "reporter_01.04.r";
	
reporter_mode <- "local" ; # r_mode= reporter_mode. Options: "web" | "local"

## Canvis respecte al reporter_XX.X.r local (search for XXXX throughout the code below):
path_local <- "/home/xavi/workspace/Dades_prova_test";
path_web <- "/extra/Rdata";

# choose between stats|physics (Statistics or Physics, respectively)
report_type <- "stats" ; # reporter_type = "physics"

start_clean_output_dir <- 0; # Param start_clean_output_dir to indicate whether you want to remove the leftover .txt files from previous runs. 1 = remove *.txt files at startup | 0 = leave that directory as is.
debug_desc <- 1; # 1 = keep. 0 = remove.# Param debug_desc to indicate whether the log file should be kept at the end or not
single_data_file <- "1"; # 1 for yes | 0 for no. # Mode to save a data file for group statistics, ready for histogram charts
console_report <- "0"; # 1 for yes | 0 for no. Reporting on console needed when working on the web to process single student files XXXX
testrun <- "0" # Param to indicate whether test run should be performed (test=1, on test directories) or normal run (test=0)
profile_memory <- 0 # Param to profile memory usage
display_memory_use <- 1 # Param to display memory usage with gc()
############################################################

if(reporter_mode == "web") {path<-path_web;}else{path<-path_local;};  # XXXX
# Define "data_file" when working locally to avoid R complain that it doesn't know what data_file is, since it's only properly used when through Tiki website
if(reporter_mode == "web") {data_file<-data_file;}else{ data_file<-"There is no data file when working locally, only through Tiki attachments to tracker items";};  # XXXX

# if (file.exists(data_file)) { # XXXX. process the file. Otherwise, report missing file to process. this line needs to be uncommented only the web version of the script

if (testrun == "1") {
	reporter_path_to_input_files <- "test/out/";
	reporter_path_to_output_files <- "test/out/";
}else{
	#reporter_path_to_input_files <- "files_out/" # same for web XXXX
	#reporter_path_to_output_files <- "files_out/" # same for web XXXX
	reporter_path_to_input_files <- "files_out/2010/";
	reporter_path_to_output_files <- "files_out/2010/";
}

  ## ----------------------------------------------------------------
  ##  REQUIREMENTS - ini
  ## ----------------------------------------------------------------
  # install.packages('reshape') # "Reshape" Package to perform the equivalent of 'DataPilot' in OOo or 'PivotTables' in M$ EXcel
  if (!require(reshape)) install.packages('reshape')
  library(reshape);
  
  # # If needed to install as a local package (sometimes de repository is offline):
  #install.packages("/home/statmedia/Documents/grof_ub/R-project/XML_3.1-0.tar.gz", repos=NULL)
  if (!require(XML)) install.packages("XML", repos = "http://www.omegahat.org/R")
  library(XML);
  
  ## install GNU/Linux package libxml2-dev(el) for R package XML to install.
  # # in suse 11 (cochise.bib.ub.es) I had to add the extra package to the system: libxml2-devel in order to allow the R package XML to install.
  # # in Ubuntu 10.04, I had to add the extra package to the system: libxml2-dev
  # # Otherwise, R complained about missing xml2-config program missing

  if (!require(R4X)) install.packages("R4X", repos = "http://R-Forge.R-project.org")
  # # If needed to install as a local package (sometimes de repository is offline):
  # install.packages("/home/statmedia/Documents/grof_ub/R-project/R4X_0.1-25.tar.gz", repos=NULL)
  library(R4X);
  
  # # or from linux console "R CMD INSTALL /home/statmedia/Documents/grof_ub/R-project/R4X_0.1-25.tar.gz"
  # # packages "brew", "operators" seems to be a dependancy
  if (!require(reshape)) install.packages("brew")
  if (!require(reshape)) install.packages("operators")
  library(brew);
  library(operators);
  
  ## REQUIREMENTS - end
  ## ----------------------------------------------------------------
    
  ###########################################################################################################################################################################
  ## Changelog:
  # v01.04- 1103__: Added n_active_actions (number of student actions) to the session list.
  # 	 * Added rows at the end of the table location_pivottable to indicate again the milestone names and whether each milestone has been achieved at least once
  # 	 * Fixed the weird case for 2009 4079 when no milestones and just 1 student action was found
  #		 * Show the file number and name in the console when processing in local host so show progress in batch mode.
  #		 * Fixed a few typos in strings.
  #		 * Added maximum number of milestones next to the number of unique milestones achieved
  #		 * Added missing first column in row of presence / absence of each milestone in pivot table (console and file)
  #		 * Added clean_r_environ_at_start <- 1 # Param to remove all objects in the R environment before starting the reporting
  #		 * Added params to profile memory usage and display memory usage by R
  # v01.03- 110228: Fixed the problem with the procesing of data from 2008 (where no sections where indicated when grading the questions)
  #		 * Fix the variable duration when only one session is found
  # 	 * Converted function time_h_m into time_d_h_m in order to show the number of days of the duration of each session (there seem to be cases of looong sessions).
  #		 * single_data_file stores grades (fraction and decimal number) between quotation marks to prevent the decimal point to be considered as the thousands mark by some spreadsheet software at csv importation
  # 	 * add the milestone id (number) besides the milestone label in the tables
  #		 * add n_milestones (hard coded so far) to have all milestone columns in tables (also the empty ones for that user and traces file)
  #		 * Added testrun param (to ease the enabling/disabling of the test mode)...
  #		 * New regeps added from Jordi (v5)
  #		 * Added note for end users: "There is no direct relationship ensured between between the grade and the number of milestones shown in the table"
  #		 * Add info in single_data_file regarding whether the student has performed the unilateral milestone 10.UnRB3 or not
  #		 * Add count of unique milestones achieved per student in single_data_file
  #		 * Fixed missing file name for the new commands to write __Notes__ about the table
  #		 * Fixed extra spaces added for single_data_file variable names and some values
  #		 * Added info on report and on single_data_file about the number of times that the student opens the help window with the class notes 
  #		 * Updated dictionary for file type 18 (Button) 
  #		 * Fixed error with the algorythm to count the number of milestones (once all milestones - empty or not - were shown as columns in location_pivottable)
  #		 * Show the file number and name in the console when processing in local host so show progress in batch mode.
  # v01.02- 110206: Moving forward. Updated to a new format of bzr (2.0) tree or revisions.
  # 	 * commits have to go through the new Bazaar dialogue and menus, not the "TEAM" in eclipse any more
  #		 * Fetch grades per section and include them in the reported results for single reports and for the single_data_file for the whole set of traces files
  # 	 * added xml_net2 with function "xmlInternalTreeParse" instead of "xml", to avoid weird errors with xpathApply functions for grades 
  #		 * full set of milestones (with repetitions) identified and shown in milestones tables.
  #		 * fixed error with session codes in location_milestones.r after full set of milestones (with repetitions) identified.
  #		 * Ensured that xml variables are initialized to zero at start time (just in case, not known to produce any issue, but this change cannot hurt at all).
  # 	 * Added the reporter version in the file name of single_data_file and at the bottom of the reports in .txt.
  #		 * Single_data_file (for the report in batch) includes a new column with the name and path of the source xml file where the data in each row comes from
  #		 * Added the option to start clean output dir (remove *.txt and *.csv), with a confirmation step if output dir = input dir (to prevent deleting source files for traces in statmedia) 
  # v01.01- 110102: Converted pivot table into wiki (for html) table.
  #      * option added to store data from all users processed in single_data_file
  # v01.0 - 100909: Fixed many bugs detected during the meeting today:
  #      * session_id treated as numbers and not factors: location_milestone.r updated
  #      * session_id's in pivot table coded properly, typo fixed in n_quick_sessons
  #      * fixed a few things in the file saved as report, to get closer to the one printed in the console & web (still more to sync)
  #      * fixed definition of location matrix (as NULL again, and added with rbind), so that no need to have fake raws as starters
  #      * Reindented everything. Added reporter_mode (web or local).
  #      * Duration of sessions added. Calculation of quick sessions updated accordingly (bug fixed).
  #      * Fixed bug when just One session, that was showing NA for time_h_s. Fixed n_quick_sessions (-1).
  #      * Added studentId to file name wich contains the report as the value deduced from inside the xml (needed for report files on the web server, with weird tmp filenames without it).
  # v00.9 - 100906: Fixed typo in a line when writing the output at the console. Added semi-colons where missing (end of lines)
  #      Removed message "character(0)" from output console in all runs (message from the system command; intern=FALSE fixed it)
  # v00.8 - 100827: Refactor code in functions to locate_milestone. Re-shape the output to fit the table format agreed in the last meeting.
  #      Updated regular expressions from Jordi.
  # v00.7 - 100728: Take more profit of the maginc in the XML package in R, since the raw regexps from Jordi translated to R didn't return the expected results
  #        and on the contrary, the other documentation on the XML package seem to be clear enough and shows a very powerful and versatil R package
  #      for processing XML files, using XPATH. See:  http://www.omegahat.org/RSXML/shortIntro.html
  #      The problem I had with the values returned by grexepr as matches was that the escape characters are not counted (i.e, "\n" is counted as just one character)
  #      and \" is counted as one character also). This way, the column number correspond to the value returned by grexepr.
  #      Values from location (milestones, etc.) saved properly in the report file and in console. Not yet in the table format agreed at the last meeting.
  #      ...
  # v00.6 - 100528: Surround by double quotes the output from description fields, which nowadays contain just single quotes.
  #       This way, the report is csv compliant again.
  #        regexp searches implemented to identify the path followed by the student. Position of each milestone added to report
        # * identify properly the regexps for milestone 1 and 2: empty right now.
  #       .
  # v00.5 - 100519: Report for statistics logs also. Basic reporting finally works again, after having XML related bug in RKward fixed by RKward author
  #       Sample Regexps from Jordi do work already. Syntax adapted to escape double quotes.
  # v00.4 - 090720: Report the params of each animations and each calibration
  # v00.3 - 090707: Report on the specific questions we want to know from student activity (# of calibrations, animations, ...)
  # v00.2 - 090629: Report on the basic information from the traces file saved in simple .txt file
  # v00.1 - 090619: initial file created.
  ## ---------------------------------------------------------------------------------------------------------------

  ####################################################################################
  ## decode_time_id
  # --------------
  # Function to format time like dd-mm-yy hh:mm:ss from the time_id code
  ####################################################################################
  decode_time_id <- function(time_id){
    
    # Split time in parts
    s_year <- substr(as.character(time_id), 1, 4);
    s_month <- substr(as.character(time_id), 5, 6);
    s_day <- substr(as.character(time_id), 7, 8);
    s_hour <- substr(as.character(time_id), 9, 10);
    s_minute <- substr(as.character(time_id), 11, 12);
    s_second <- substr(as.character(time_id), 13, 14);
    
    time_formated <- paste(paste(s_year, s_month, s_day, sep="-"),paste(s_hour, s_minute, s_second, sep=":"), sep=" ");
    return(list(time_formated, s_year, s_month, s_day, s_hour, s_minute, s_second));
  }
  ####################################################################################

  ####################################################################################
  ## time_d_h_m
  # --------------
  # Function to show time in days, hours and minutes (xx d, yy h, zz min) that was previously given in seconds
  # time_d_m_h_ in this functions/subroutine corresponds to time_d_m_h in the main program
  # total_time_ in this functions/subroutine corresponds to total_time (in seconds) in the main program
  # days_: number of days for that time 
  # hours_: number of hours after those days 
  # minutes_: number of minutes after those days and hours 
  ####################################################################################
  time_d_h_m <- function(total_time_){
    
    # Show time in days, hours and minutes that was previously given in seconds
	# for debugging: total_time_ <- total_time
	days_ <- floor(total_time_/(24*3600));
	hours_ <- floor(total_time_/3600 - days_*24);
	minutes_ <- round(total_time_/60 - days_*24*60 - hours_*60);
    time_d_h_m_ <- paste(days_, " d, ", hours_, " h, ", round((total_time_/3600 - floor(total_time_/3600))*60)," min", sep="");      
  return(time_d_h_m_);
  }
  ####################################################################################
  
  ##setwd("/home/xavi/Documents/Dades_prova")
  ##setwd("/media/disk/grof_ub/Dades_prova")
  ##setwd("/media/2B0B4E266B7FBC41/grof_ub/Dades_prova")
  ##setwd("/home/statmedia/Documents/grof_ub/Dades_prova/")
  setwd(path); # defined above

  ####################################################
  # Clean garbage and leftover files, if requested
  # Adding a confirmation check only if direcgtory for unput files = dir for output files
  # (the user might be removing the .txt files with source data for the xml traces files)
  ####################################################
  ## And only in the case when input_path is different from output_path (to avoid deleting source data in data case)
	  fun <- function() {
		  ANSWER <- readline(paste("Are you sure you want to remove all .txt and .csv files from the output (= input) directory ", reporter_path_to_output_files, "? (y/n) ", sep=""))
		  ## a better version would check the answer less cursorily, and
		  ## perhaps re-prompt
		  if (substr(ANSWER, 1, 1) == "n")
			  cat("Ok, left untouched. Conservative decission.\n")
		  else
			  fun.cleanfiles()
			  cat("Ok, files removed (if any).\n")
	  }
	  fun.cleanfiles <- function () {
		  system(paste("rm ", reporter_path_to_output_files, "*.txt", sep=""), TRUE);
		  system(paste("rm ", reporter_path_to_output_files, "*.csv", sep=""), TRUE);
	  }
	  if(interactive() && testrun == 0 && start_clean_output_dir == 1 && reporter_path_to_input_files == reporter_path_to_output_files) {
		  fun()
	  }else if (testrun == 1 && start_clean_output_dir == 1) {
		  fun.cleanfiles() # if in test run mode, and requesting to start clean, remove the previous files from the test folder
	  }
  ####################################################
    
  # Initialize some variables
  report_on_file_list_name <- "";
  abs_reportedfile0 <- "";
  
      ## report_on_file_list
      report_on_file_list_name <- paste(reporter_path_to_output_files,Sys.Date(), format(Sys.time(), "_%H-%Mh_"),"report_on_file_list.txt", sep="");
 
	  # Rprofmem: Initialize memory monitoring if requested
	  if (profile_memory == 1) {
		  rprof_filename = paste(report_on_file_list_name,"_Rprofmem.txt", sep="")
		  Rprof(filename = rprof_filename, append = FALSE, interval = 0.02, memory.profiling=TRUE)
		  # I lso tried with Rprofmem, but it didn't provide meaningful data to me
		  #Rprofmem(filename = paste(report_on_file_list_name,"_Rprofmem.txt", sep=""), append = FALSE, threshold = 20000)  
	  } else{
		  Rprof(NULL)
	  }


  if (report_type == "physics" && reporter_mode != "web") {
    # Get the list of files in "input" directory through a system call to "ls *" and save the result to a file on disk
    system(paste("ls ",reporter_path_to_input_files,"trace-*.xml > ",report_on_file_list_name, sep=""), intern = FALSE);
  } else {
      if (report_type == "stats" && reporter_mode != "web") {
        # Get the list of files in "input" directory through a system call to "ls *" and save the result to a file on disk
        system(paste("ls ",reporter_path_to_input_files,"*.xml > ",report_on_file_list_name, sep=""), intern = FALSE);      
      }
    }
  
    # In case of reporter_mode non web, get the list of files to process. If web, only one file
    if (reporter_mode != "web") {
      # Read the file with the list of files to be processed
      report_on_file_list <- read.table(report_on_file_list_name, sep="");
      
      # Count the number of source files
      number_of_source_files <- length(report_on_file_list[[1]]);
      
      # Do it through gsub
      report_on_file_list <- gsub(reporter_path_to_input_files,"", report_on_file_list[[1]]);
      report_on_file_list <- gsub(".xml","", report_on_file_list);
      }else{ # reporter mode = web
       report_on_file_list  <- data_file; # needed?
       number_of_source_files <- 1;
      }    

  # Prepare file to record single_data_file in csv format, so that it can be processed later by r, spreadsheets or any means
  if(single_data_file == "1") {
    # Create such file name with absolute path
    single_data_file_name <- paste(reporter_path_to_output_files, "all_data_from_", Sys.Date(), format(Sys.time(), "_%H-%Mh_"), reporter_r_script,".csv",sep="");
    # Start writing to it...
#    write("\"# Data collected from all processed users' traces files\"", file=single_data_file_name, append = TRUE, sep = "");
#    write(paste("\"Student\", \"N_Actions\", \"Time_spent_sec\", \"N_Sessions\", \"N_Sessions_more1\", \"N_Milestones\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\"", sep=""), file=single_data_file_name, append = TRUE, sep = "");
    write(paste("\"Student\",\"N_Actions\",\"Time_spent_sec\",\"N_Sessions\",\"N_Sessions_more1\",\"N_Milestones\",\"N_Unique_Milestones\",\"Milestone_10.UnRB3?\",\"N_Statmedia_Button\",\"Points/MaxPoints\",\"Final_Grade\",\"Relative_file_path\"", sep=""), file=single_data_file_name, append = TRUE, sep = "");
#  # Initialize dummy variable with StudentId to collect data from each student
#    all_user_data_tmp <- studentId;
#    # the next values will be appended as columns with cbind
  };  

  for(file_n in 1:number_of_source_files ) {
  # ================================================================
  # Start the loop for processing source file with traces to process
  # ================================================================
  
      # Assign the next filename to the conversion file name
      reportedfile0 <- report_on_file_list[file_n];
    
	  	# When in local mode, show in the console the file number (out of max files to report on) and its name
		if (reporter_mode != "web") {
			cat(paste("----------- Reporting on file ", file_n, "/", number_of_source_files, ": ", reportedfile0, ".xml ----------\n", sep=""),sep="");
			if (display_memory_use == 1) {
				gcinfo(FALSE);
				print(gc());
			}
			# And the equivalent on report_on_file_list_name if debug_desc is enabled, to allow keeping the info of memory use in a file, etc, if requested by the user
			write(paste("----------- Reporting on file ", file_n, "/", number_of_source_files, ": ", reportedfile0, ".xml ----------\n", sep=""), file=report_on_file_list_name, append = TRUE, sep = "");
			if (display_memory_use == 1) {
				gcinfo(TRUE)
				write(gc(), file=report_on_file_list_name, append = TRUE, sep = "");
				gcinfo(FALSE)
			}		
		}
		
      abs_reportedfile0_local <- paste(reporter_path_to_input_files, reportedfile0, ".xml", sep="");
      abs_reportedfile0_web <- data_file; # change required for the online version through PluginR. XXXX
    ifelse(reporter_mode == "web", abs_reportedfile0<-abs_reportedfile0_web, abs_reportedfile0<-abs_reportedfile0_local);  # XXXX
      
      # Get the number of lines from the unix command "wc -l <"
      nlines_file <- as.numeric(system(paste("wc -l <", abs_reportedfile0), TRUE)) -1;
        # from http://tolstoy.newcastle.edu.au/R/help/04/12/8815.html
        # "Suppopse file.name is "massive.csv".
        # Then paste("wc -l <", file.name) is "wc -l < massive.csv", which is a UNIX command to write the number of lines in massive.csv to stdout, and system(cmd, TRUE) executes the UNIX command and returns everything it writes to stdout as an R character vector, one element per line of output. In this case, there's one line of output, so one element. Don't forget the TRUE; without it the command's standard output is not captured, just displayed.
        # Finally, as.numeric turns that string into a number".
    
      # Open Connection for the file to make a report on
      con <- file(abs_reportedfile0, "r", blocking = FALSE, encoding = "utf-8");
            # For the first line, get studentId and first row of dd_net
      
    # Load Sample traces file
    
    # (a) Validate XML file and set it into a R structure, containning metainformation from the xml file itself
        # Check XML:"xml" (TRUE if xml file)
        # isXMLString(readLines(abs_reportedfile0));
    
        # For the XMl file to validagte, the DTD file listed in side the xml file has to be available in the same path as the reporter R script.
        # May'2010: I have detected the problem with the current xml file. "grade" cannot be a second attribute of param nodes.
    
        # #As of May 15th, 2010, this parsingof the xml file in a single go withthis line produces an error (and exit of RKWard).
        ## xml_r <- xmlTreeParse(readLines(abs_reportedfile0),  asText=TRUE, validate = TRUE)
        #Instead, in simple smaller steps (as copied from the help text for xmlTreeParse, it seems to work:
        # Read the text from the file, after initializing the variable
		xml_r <- NULL;
        xml_r <- paste(readLines(abs_reportedfile0), "\n", collapse="");
        
    # (b) Load xml file into an R object conatainning the clean xml, after initializing the variables
	  xml_net_local <- NULL;
	  xml_net2 <- NULL;
	  xml_net_web <- NULL;
      xml_net_local <- xml(abs_reportedfile0);
	  xml_net2 <- xmlInternalTreeParse(abs_reportedfile0);
	  xml_net_web <- xml(data_file); # required in the online version through PluginR. XXXX
	  ifelse(reporter_mode == "web", xml_net<-xml_net_web, xml_net<-xml_net_local);  # XXXX
      
    if (report_type == "physics") {
    ##########################################################
    ## - ini report on PHYSICS logs
    ##########################################################
    
      # Start writing to the file here
      header_text = paste("\"Report from the Tweezers traces file: ***", reportedfile0,
      "***, on ", Sys.Date(), format(Sys.time(), " %H:%Mh "),
      ", originally with ", nlines_file," lines.\"", sep="")
      write(header_text, file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = FALSE, sep = " ")
    
      # Header for basic report on the xml file
      write("", file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, sep = " ")
      write("\"Basic report on the xml file\"", file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, sep = " ")
      write("\"----------------------------\"", file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, sep = " ")
    
      write.table(tmp_bb, file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, quote = TRUE, sep = ", ",
            eol = "\n", na = "NA", dec = ".", row.names = TRUE,
            col.names = FALSE, qmethod = c("escape", "double"))
    
      ## TRIALS - ini ------------------------------
      # unlist(xmlElementSummary(abs_reportedfile0)$nodeCounts)
      # unlist(xmlElementSummary(abs_reportedfile0)$attributes$event)
      # unlist(xmlElementSummary(abs_reportedfile0)$attributes$param)
      #
      #  xml_r$doc$children$log$children
      #  xml_r$doc$children$log$children["param"]
      #  xml_r$doc$children$log$children$event["param"]
      #
      # xml_net[ "doc/children/log/children/event" ]
      #  length(xml_net[ "event" ])
      #  xml_net[ "event" ]
      #  length(xml_net[ "event/@action" ])
      #  xml_net[ "event/@action" ][1:3]
      ## TRIALS - end ------------------------------
    
      # Count number of calibrations performed by the student in the log file
      n_calibrations <- length(which(xml_net[ "event/@action" ] == "Trap Calibrated"))
      # Keep id's of the events which hold calibrations
      calibrations <- which(xml_net[ "event/@action" ] == "Trap Calibrated")
      calibrations
    
      # Count number of animations performed by the student in the log file
      n_animations <- length(which(xml_net[ "event/@action" ] == "Animation button clicked"))
      # Keep id's of the events which hold animations
      animations <- which(xml_net[ "event/@action" ] == "Animation button clicked")
      animations
    
      # Record those results manually obtained at the report file
      write("", file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, sep = " ")
      write("\"Basic report on student activity\"", file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, sep = " ")
      write("\"--------------------------------\"", file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, sep = " ")
      write(paste("\"Number of Calibrations\", ",n_calibrations[1],sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, sep = " ")
      write(paste("\"Number of Animations\" ,",n_animations[1],sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, sep = " ")
    
      write("", file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, sep = " ")
      write("\"Calibrations\"", file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, sep = " ")
      write("\"------------\"", file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, sep = " ")
      # Loop to keep record of all params during each calibration and to save the params to the file on disk
      for(nn in 1:n_calibrations ) {
      write(paste("\"Parameters at the Calibration Number\", ",nn,sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, sep = " ")
      # Get the content of the params at each calibration
      params_calib_tmp <- xml_net[ "event[calibrations[[nn]]]/" ]
      params_calib_tmp
      # Count the number of params in this calibration
      n_params_calib_tmp <- length(params_calib_tmp)
    
        for (npar in 1:n_params_calib_tmp)  {
          # Write each line of the parameters set
        # Split ech xml param line into 3 elements, 1 for param, 2 for name and 3 for value
          params_calib_tmp[[npar]] <- unlist(params_calib_tmp[[npar]])
        # Save the param names and values in the file
          write(paste("\t\"",params_calib_tmp[[npar]][[2]],"\", ",params_calib_tmp[[npar]][[3]],sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, sep = " ")
        }
      }
    
      write("", file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, sep = " ")
      write("\"Animations\"", file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, sep = " ")
      write("\"----------\"", file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, sep = " ")
      # Loop to keep record of all params during each animation and to save the params to the file on disk
      for(nn in 1:n_animations ) {
      write(paste("\"Parameters at the Animation Number\", ",nn,sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, sep = " ")
      #animations[[1]]
      #nn <- 1
      params_anim_tmp <- xml_net[ "event[animations[[nn]]]/" ]
      params_anim_tmp
      n_params_anim_tmp <- length(params_anim_tmp)
      n_params_anim_tmp # 14
        for (npar in 1:n_params_anim_tmp)  {
          # Write each line of the parameters set
          params_anim_tmp[[npar]] # equals to params_anim_tmp$param
        # Split ech xml param line into 3 elements, 1 for param, 2 for name and 3 for value
          params_anim_tmp[[npar]] <- unlist(params_anim_tmp[[npar]])
          params_anim_tmp[[npar]]
      params_anim_tmp[[npar]][[2]]
          write(paste("\t\"",params_anim_tmp[[npar]][[2]],"\", ",params_anim_tmp[[npar]][[3]],sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_report.txt",sep=""), append = TRUE, sep = " ")
        }
      }
    
      # Free resources used for keeping the xml file in memmory
      #free(xml_r)
      #free(xml_net)
      ## - end physics
    ##########################################################
    ## - end report on PHYSICS logs
    ##########################################################    
    } else {
    ##########################################################
    ## - ini report on STATISTICS logs
    ##########################################################

      # Identify the user (or users, or more than one, even if it should only be one). Used for filename in web.
      studentId <- unique(xml_net[ "event/@user" ]);
    
          # Start writing to the file here
          header_text = paste("\"Report from the Statmedia log files: ***", reportedfile0,
          "***, on ", Sys.Date(), format(Sys.time(), " %H:%Mh "),
          ", originally with ", nlines_file," lines.\"", sep="");
          write(header_text, file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = FALSE, sep = " ");  
    
        # Count number of different sessions performed by the student in the log file
        sessions <- unique(xml_net[ "event/@session" ]);
		
        #session_list <- t(sessions);
        #  session_list <- matrix(c("", 0),length(sessions),2, byrow =TRUE);
        session_list <- NULL;
        
        # loop to set session_id and session_label pairs in session_list variable
        for(ii in 1:(length(sessions))) {
          session_list <- rbind(session_list, c(ii,  sessions[ii], decode_time_id(sessions[ii])[[1]]));
        } # end of ii
  
      # --------------------------------------------------------
      ## REGEXPS - ini
      # --------------------------------------------------------  
        # **Idees generals**  
        # - Sol haver-hi un problema amb el punt. Tendeix a no reconÃ¨ixer no imprimibles. Alternativa: [\w\W]
        # - Qualsevol nombre d'events:  (?:[^<]*?<event[\w\W]*?</event>)*?  
        # - Qualsevol nombre de parametres o descripcio:   (?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?
        #
        ## **Procés de resolució**
        
        # Initialize a few more variables (otherwise R seems to complain)
        milestone_id <- "";
        milestone_label <- "";
		milestone_count <- "";
		n_milestones <- "15" ; # So far (Feb 2011) this value is hadcoded. In the future, this could be dynamic (based on the number of milestone regexps in an external file, for instance).
        location <- NULL;
		location_template <- NULL;
		milestone_n <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15");
		milestone_label <- c("01.LdGA", "02.LdGB", "03.1SaA", "04.1SaB", "05.2SaAV", "06.LdCB", "07.LdC3", "08.2SaB3", "09.PaiB3", "10.UnRB3", "11.LdDop", "12.LdNic", "13.RegDN", "14.LinDN", "15.PreDN");
		
        #location
        # internal dummy index for the matches to be recorded in the location matrix
        ii <- 0;
        # Locate the positions and lengths respect of all matches to this regexp
        # <event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Load Variable\"|action=\"Load Variable\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Variable\"[^>]*?value=\"Grup_A\"|value=\"Grup_A\"[^>]*?name=\"Variable\")
      
        ## *01, LdGA, v201102061726*
		#// Variable Grup A is loaded in the calculator
		location_tmp <- gregexpr("<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Load Variable\"|action=\"Load Variable\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Variable\"[^>]*?value=\"Grup_A\"|value=\"Grup_A\"[^>]*?name=\"Variable\")",xml_r);
		milestone_id <- "01";
		source("location_milestone.r");
      
		#*02, LdGB, v201102061742*
		#// Variable Grup B is loaded in the calculator
		location_tmp <- gregexpr("<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Load Variable\"|action=\"Load Variable\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Variable\"[^>]*?value=\"Grup_B\"|value=\"Grup_B\"[^>]*?name=\"Variable\")",xml_r);      
		milestone_id <- "02";
		source("location_milestone.r");
		
		#*03, 1SaA, v201102061744*
		#// One sample analysis is run on variable Grup A
		location_tmp <- gregexpr("<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Request analysis - One-sample analysis\"|action=\"Request analysis - One-sample analysis\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>(?:[^<]*?<event[^>]*?(?:application=\"Statmedia form\"|application=\"Ons\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>)*?[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable\"|action=\"Select variables - Variable\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable\"[^>]*?value=\"Grup_A\"|value=\"Grup_A\"[^>]*?name=\"Select variables - Variable\")",xml_r);
		milestone_id <- "03";
		source("location_milestone.r");
		
			#NOTES: Traces desordenades, accepto outputs i enviament de formularis entre petici� d'an�lisi i selecci� de variables.
		
		#*04, 1SaB, v201102061748*
		#// One-sample analysis is run on variable Grup B
		location_tmp <- gregexpr("<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Request analysis - One-sample analysis\"|action=\"Request analysis - One-sample analysis\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>(?:[^<]*?<event[^>]*?(?:application=\"Statmedia form\"|application=\"Ons\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>)*?[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable\"|action=\"Select variables - Variable\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable\"[^>]*?value=\"Grup_B\"|value=\"Grup_B\"[^>]*?name=\"Select variables - Variable\")",xml_r);
		milestone_id <- "04";
		source("location_milestone.r");
		
			#NOTES: Traces desordenades, accepto outputs i enviament de formularis entre petici� d'an�lisi i selecci� de variables.
			
		#*05, 2SaAB, v201102061759*
		#// Two-sample analysis is run with variables Grup A and Grup B
		location_tmp <- gregexpr("<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Request analysis - Two-sample analysis\"|action=\"Request analysis - Two-sample analysis\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>(?:[^<]*?<event[^>]*?(?:application=\"Statmedia form\"|application=\"Tws\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>)*?[^<]*?(?:<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 1\"|action=\"Select variables - Variable 1\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 1\"[^>]*?value=\"Grup_A\"|value=\"Grup_A\"[^>]*?name=\"Select variables - Variable 1\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 2\"|action=\"Select variables - Variable 2\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 2\"[^>]*?value=\"Grup_B\"|value=\"Grup_B\"[^>]*?name=\"Select variables - Variable 2\")|<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 1\"|action=\"Select variables - Variable 1\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 1\"[^>]*?value=\"Grup_B\"|value=\"Grup_B\"[^>]*?name=\"Select variables - Variable 1\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 2\"|action=\"Select variables - Variable 2\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 2\"[^>]*?value=\"Grup_A\"|value=\"Grup_A\"[^>]*?name=\"Select variables - Variable 2\"))",xml_r);
		milestone_id <- "05";
		source("location_milestone.r");
		
			#NOTES: Traces desordenades, accepto outputs i enviament de formularis entre petici� d'an�lisi i selecci� de variables. Assumit ordre indiferent de les variables
		
		#*06, LdCB, v201102061800*
		#// Variable Control_Basal is loaded in the calculator
		location_tmp <- gregexpr("<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Load Variable\"|action=\"Load Variable\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Variable\"[^>]*?value=\"Control_Basal\"|value=\"Control_Basal\"[^>]*?name=\"Variable\")",xml_r);
		milestone_id <- "06";
		source("location_milestone.r");
		
		#*07, LdC3, v201102061805*
		#// Variable Control_3_setmanes is loaded in the calculator
		location_tmp <- gregexpr("<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Load Variable\"|action=\"Load Variable\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Variable\"[^>]*?value=\"Control_3_setmanes\"|value=\"Control_3_setmanes\"[^>]*?name=\"Variable\")",xml_r);
		milestone_id <- "07";
		source("location_milestone.r");
		
		#*08, 2SaB3, v201102061811*
		#// Two-sample analysis is run with variables Control_Basal and Control_3_setmanes
		location_tmp <- gregexpr("<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Request analysis - Two-sample analysis\"|action=\"Request analysis - Two-sample analysis\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>(?:[^<]*?<event[^>]*?(?:application=\"Statmedia form\"|application=\"Tws\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>)*?[^<]*?(?:<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 1\"|action=\"Select variables - Variable 1\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 1\"[^>]*?value=\"Control_Basal\"|value=\"Control_Basal\"[^>]*?name=\"Select variables - Variable 1\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 2\"|action=\"Select variables - Variable 2\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 2\"[^>]*?value=\"Control_3_setmanes\"|value=\"Control_3_setmanes\"[^>]*?name=\"Select variables - Variable 2\")|<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 1\"|action=\"Select variables - Variable 1\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 1\"[^>]*?value=\"Control_3_setmanes\"|value=\"Control_3_setmanes\"[^>]*?name=\"Select variables - Variable 1\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 2\"|action=\"Select variables - Variable 2\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 2\"[^>]*?value=\"Control_Basal\"|value=\"Control_Basal\"[^>]*?name=\"Select variables - Variable 2\"))",xml_r);
		milestone_id <- "08";
		source("location_milestone.r");
		
			#NOTES: Traces desordenades, accepto outputs i enviament de formularis entre petici� d'an�lisi i selecci� de variables. Assumit ordre indiferent de les variables
		
		#*09, PaiB3, v201102061833*
		#// Paired samples contrast is selected with variables Control_Basal and Control_3_setmanes
		location_tmp <- gregexpr("(?:(?:<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 1\"|action=\"Select variables - Variable 1\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 1\"[^>]*?value=\"Control_Basal\"|value=\"Control_Basal\"[^>]*?name=\"Select variables - Variable 1\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 2\"|action=\"Select variables - Variable 2\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 2\"[^>]*?value=\"Control_3_setmanes\"|value=\"Control_3_setmanes\"[^>]*?name=\"Select variables - Variable 2\")|<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 1\"|action=\"Select variables - Variable 1\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 1\"[^>]*?value=\"Control_3_setmanes\"|value=\"Control_3_setmanes\"[^>]*?name=\"Select variables - Variable 1\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 2\"|action=\"Select variables - Variable 2\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 2\"[^>]*?value=\"Control_Basal\"|value=\"Control_Basal\"[^>]*?name=\"Select variables - Variable 2\"))[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>(?:[^<]*?<event[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>)*?[^<]*?<event (?:application=\"Tws\"[^>]*?action=\"Change to Paired Samples\"|action=\"Change to Paired Samples\"[^>]*?application=\"Tws\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>)|(?:<event (?:application=\"Tws\"[^>]*?action=\"Change to Paired Samples\"|action=\"Change to Paired Samples\"[^>]*?application=\"Tws\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>(?:[^<]*?<event[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>)*?[^<]*?(?:<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 1\"|action=\"Select variables - Variable 1\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 1\"[^>]*?value=\"Control_Basal\"|value=\"Control_Basal\"[^>]*?name=\"Select variables - Variable 1\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 2\"|action=\"Select variables - Variable 2\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 2\"[^>]*?value=\"Control_3_setmanes\"|value=\"Control_3_setmanes\"[^>]*?name=\"Select variables - Variable 2\")|<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 1\"|action=\"Select variables - Variable 1\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 1\"[^>]*?value=\"Control_3_setmanes\"|value=\"Control_3_setmanes\"[^>]*?name=\"Select variables - Variable 1\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 2\"|action=\"Select variables - Variable 2\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 2\"[^>]*?value=\"Control_Basal\"|value=\"Control_Basal\"[^>]*?name=\"Select variables - Variable 2\"))[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>)",xml_r);
		milestone_id <- "09";
		source("location_milestone.r");
		
		#*10, UnRB3, v2011020070614*
		#// Unilateral right contrast is select with variables Control_Basal and Control_3_setmanes
		location_tmp <- gregexpr("(?:(?:<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 1\"|action=\"Select variables - Variable 1\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 1\"[^>]*?value=\"Control_Basal\"|value=\"Control_Basal\"[^>]*?name=\"Select variables - Variable 1\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 2\"|action=\"Select variables - Variable 2\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 2\"[^>]*?value=\"Control_3_setmanes\"|value=\"Control_3_setmanes\"[^>]*?name=\"Select variables - Variable 2\")|<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 1\"|action=\"Select variables - Variable 1\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 1\"[^>]*?value=\"Control_3_setmanes\"|value=\"Control_3_setmanes\"[^>]*?name=\"Select variables - Variable 1\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 2\"|action=\"Select variables - Variable 2\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 2\"[^>]*?value=\"Control_Basal\"|value=\"Control_Basal\"[^>]*?name=\"Select variables - Variable 2\"))[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>(?:[^<]*?<event[^>]*?(?:application=\"Statmedia form\"|application=\"Tws\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>)*?[^<]*?<event[^>]*? (?:application=\"Tws\"[^>]*?action=\"Change alt Hipot for Mean to unilat right\"|action=\"Change alt Hipot for Mean to unilat right\"[^>]*?application=\"Tws\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>)|(?:<event[^>]*? (?:application=\"Tws\"[^>]*?action=\"Change alt Hipot for Mean to unilat right\"|action=\"Change alt Hipot for Mean to unilat right\"[^>]*?application=\"Tws\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>(?:[^<]*?<event[^>]*?(?:application=\"Statmedia form\"|application=\"Tws\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>)*?[^<]*?(?:<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 1\"|action=\"Select variables - Variable 1\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 1\"[^>]*?value=\"Control_Basal\"|value=\"Control_Basal\"[^>]*?name=\"Select variables - Variable 1\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 2\"|action=\"Select variables - Variable 2\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 2\"[^>]*?value=\"Control_3_setmanes\"|value=\"Control_3_setmanes\"[^>]*?name=\"Select variables - Variable 2\")|<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 1\"|action=\"Select variables - Variable 1\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 1\"[^>]*?value=\"Control_3_setmanes\"|value=\"Control_3_setmanes\"[^>]*?name=\"Select variables - Variable 1\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable 2\"|action=\"Select variables - Variable 2\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable 2\"[^>]*?value=\"Control_Basal\"|value=\"Control_Basal\"[^>]*?name=\"Select variables - Variable 2\"))[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>)",xml_r);
		milestone_id <- "10";
		source("location_milestone.r");
				
			#No ho s� trobar en 30 o 152 o 123
			#NOTA: Hipot haur� de convertir-se a Hypot
		
		#*11, LdDop, v201102070935*
		#// Variable Descens_Dopamina is loaded in the calculator
		location_tmp <- gregexpr("<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Load Variable\"|action=\"Load Variable\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Variable\"[^>]*?value=\"Descens_Dopamina\"|value=\"Descens_Dopamina\"[^>]*?name=\"Variable\")",xml_r);
		milestone_id <- "11";
		source("location_milestone.r");
		
		#*12, LdNic, v201102070941*
		#// Variable Nicotina is loaded in the calculator
		location_tmp <- gregexpr("<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Load Variable\"|action=\"Load Variable\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Variable\"[^>]*?value=\"Nicotina\"|value=\"Nicotina\"[^>]*?name=\"Variable\")",xml_r);
		milestone_id <- "12";
		source("location_milestone.r");
				
		#*13, RegDN, v201102070955*
		#// Regression analysis is run with Descens_Dopamina and Nicotina
		location_tmp <- gregexpr("<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Request analysis - Linear Regression\"|action=\"Request analysis - Linear Regression\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>(?:[^<]*?<event[^>]*?(?:application=\"Statmedia form\"|application=\"Reg\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>)*?[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable Dep.\"|action=\"Select variables - Variable Dep.\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable Dep.\"[^>]*?value=\"Descens_Dopamina\"|value=\"Descens_Dopamina\"[^>]*?name=\"Select variables - Variable Dep.\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable Indep.\"|action=\"Select variables - Variable Indep.\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable Indep.\"[^>]*?value=\"Nicotina\"|value=\"Nicotina\"[^>]*?name=\"Select variables - Variable Indep.\")",xml_r);
		milestone_id <- "13";
		source("location_milestone.r");
		
			#NOTES: Traces desordenades, accepto outputs i enviament de formularis entre petici� d'an�lisi i selecci� de variables. Assumeixo que la variable dependent es tra�a abans que la independent.
		
		#*14, LinDN, v201102071543*
		#// Regression Line is selected with variables Descens_Dopamina vs Nicotina
		location_tmp <- gregexpr("<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Request analysis - Linear Regression\"|action=\"Request analysis - Linear Regression\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>(?:[^<]*?<event[^>]*?(?:application=\"Statmedia form\"|application=\"Reg\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>)*?[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable Dep.\"|action=\"Select variables - Variable Dep.\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable Dep.\"[^>]*?value=\"Descens_Dopamina\"|value=\"Descens_Dopamina\"[^>]*?name=\"Select variables - Variable Dep.\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable Indep.\"|action=\"Select variables - Variable Indep.\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable Indep.\"[^>]*?value=\"Nicotina\"|value=\"Nicotina\"[^>]*?name=\"Select variables - Variable Indep.\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>(?:[^<]*?<event[^>]*?(?:application=\"Statmedia form\"|application=\"Reg\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>)*?[^<]*?<event (?:application=\"Reg\"[^>]*?action=\"Change to Reg. Line\"|action=\"Change to Reg. Line\"[^>]*?application=\"Reg\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>",xml_r);
		milestone_id <- "14";
		source("location_milestone.r");
		
			#NOTES: Traces desordenades, accepto outputs i enviament de formularis entre petici� d'an�lisi i selecci� de variables.
		
		#*15, PreDN, v201102071641*
		#// Linear prediction of Descens_Dopamina for Nicotina=140 is calculated 
		location_tmp <- gregexpr("<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Request analysis - Linear Regression\"|action=\"Request analysis - Linear Regression\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>(?:[^<]*?<event[^>]*?(?:application=\"Statmedia form\"|application=\"Reg\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>)*?[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable Dep.\"|action=\"Select variables - Variable Dep.\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable Dep.\"[^>]*?value=\"Descens_Dopamina\"|value=\"Descens_Dopamina\"[^>]*?name=\"Select variables - Variable Dep.\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>[^<]*?<event[^>]*?(?:application=\"Cal\"[^>]*?action=\"Select variables - Variable Indep.\"|action=\"Select variables - Variable Indep.\"[^>]*?application=\"Cal\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Select variables - Variable Indep.\"[^>]*?value=\"Nicotina\"|value=\"Nicotina\"[^>]*?name=\"Select variables - Variable Indep.\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>(?:[^<]*?<event[^>]*?(?:application=\"Statmedia form\"|application=\"Reg\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>)*?[^<]*?<event (?:application=\"Reg\"[^>]*?action=\"Change: Predic. Value\"|action=\"Change: Predic. Value\"[^>]*?application=\"Reg\")[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<param[^>]*?(?:name=\"Change\"[^>]*?value=\" 140\"[^>]*?>|value=\" 140\"[^>]*?name=\"Change\"[^>]*?>)(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event>",xml_r);
		milestone_id <- "15";
		source("location_milestone.r");		
            
        
        if(length(location)==0) {
          location <- rbind(location,c("-", "-", "-", "-", "-", "-", "-"));
          location <- rbind(location,c("-", "-", "-", "-", "-", "-", "-"));
        }

		# Create a location_template with all milestones (id and label)
		for (ii in 1:n_milestones) { 
			location_template <- rbind(location_template,c("   .", milestone_n[ii], milestone_label[ii], ".", ".", ".", "0"));
		}
		
		# Define column names after the variable has been initialized and reset to zero.
        colnames(location) <- c("Action_id", "Milestone_id", "Milestone_label", "Position", "Length", "Session_label", "Session_id");
		colnames(location_template) <- c("Action_id", "Milestone_id", "Milestone_label", "Position", "Length", "Session_label", "Session_id");

		# Create a table similar to location but as template for all potential milestones
			# Merge values from location_df (which contain matches) with values from a table with all milestones (with or without matches)		
	#		m1 <- merge(location_template, location, by.x = "Milestone_label", by.y = "Milestone_label");
	#		m2 <- merge(location_template, location, all = TRUE);
	#		mx <- merge(location_template, location, by.x = "Milestone_label", by.y = "Milestone_label", all.x = TRUE);
	#		mx2 <- merge(location_template, location, by = intersect(names(location_template), names(location)), all.x = TRUE);
	#		location_template[,3] %in% location[,3]
		milestone_ids_matched <- as.numeric(location_template[location_template[,3] %in% location[,3],][,2])
		# location_template[-milestone_ids_matched,]
		location <- rbind(location, location_template[-milestone_ids_matched,])
		# TODO Sorting by column Milestone_id is still needed

        # Keep only the records from the matrix location which contain valid data (remove empty rows) and store then in location_df (data frame)
        # Just in case, but not needed anymore since location is initiallized as NULL, and all values are valid values since reporter_00.9,r
        location_df <- subset(as.data.frame(location), Action_id != 0 & Action_id != "-");
		
      # --------------------------------------------------------
      ## REGEXPS - end
      # --------------------------------------------------------
          
          # -----------------
          ## DATA PILOT - ini
          # -----------------
            # Unfactor the Session_Id's (as suggested here as a workaround): http://tolstoy.newcastle.edu.au/R/help/03a/6316.html
          # in order to allow the pivot table to show session_id numbers as numbers, and don't fail when treating them as factors instead.
          location_df$Session_id <- as.numeric(levels(location_df$Session_id)[as.integer(location_df$Session_id)])
    
          #  Convert data frame of location into a "Pivot table" with the cast function in the "Reshape" package
          	# if no actions, create location_pivottable by hand to avoid further issues with arrays with less dimensions than expected, etc
		  	if (dim(location_df)[1] > 0) {
				location_pivottable <- cast(location_df, Action_id ~ Milestone_label, value="Session_id", fill="", mean);
				location_pivottable <- subset(location_pivottable, Action_id != "   .");
				# Do this for loop only when location pivot table has some content; otherwise, row.names complains
				if (dim(location_pivottable)[1] > 0) {  
					for (ii in 1:dim(location_pivottable)[1]) {
						row.names(location_pivottable)[ii] <- ii;
					}
				}				
			} else { # cases when there are no milestones achieved. location_pivottable still "deserves" some content in order to avoid problems later on milestones_count variable being empty, etc.
				location_pivottable <- as.matrix(t(c(0, rep("0",15))))
				colnames(location_pivottable) <- c("Action_Id", milestone_label)
				# location_pivottable[,-1],
			}		  
			

		  # Once the location_pivottable has been created, the rows with no Action_Id can be removed again
		  location_df <- subset(location_df, Action_id != "   .");

		  # -----------------
        ## DATA PILOT - end
          # -----------------
        
    #-------------------------------------------------------
    ## CALCULATIONS FOR THE REPORTS - ini
    #-------------------------------------------------------
      
      
      #Calculate time ini and time end
      times <- unique(xml_net[ "event/@time" ]);
      time_tmp <- times[1];
      time_ini <- paste(substr(time_tmp, 1, 4), "-", substr(time_tmp, 5, 6), "-", substr(time_tmp, 7, 8), ", ", substr(time_tmp, 9, 10), ":", substr(time_tmp, 11, 12), "h", sep="");
      
      time_tmp <- times[length(times)];
      time_end <- paste(substr(time_tmp, 1, 4), "-", substr(time_tmp, 5, 6), "-", substr(time_tmp, 7, 8), ", ", substr(time_tmp, 9, 10), ":", substr(time_tmp, 11, 12), "h", sep="");
      
      
      sessions_s <- NULL
      times_s <- NULL
      
      # Convert session values into seconds from 2000 ("sessions_s")
      for(ii in 1:length(sessions))  {
        sessions_s[[ii]] <- ((as.numeric(substr(sessions[[ii]], 1, 4)) - 2000) * 365 * 24 * 3600 + # year
              as.numeric(substr(sessions[[ii]], 5, 6))         * 30 * 24 * 3600 + # month
              as.numeric(substr(sessions[[ii]], 7, 8))              * 24 * 3600 + # day
              as.numeric(substr(sessions[[ii]], 9, 10))                  * 3600 + # hours
              as.numeric(substr(sessions[[ii]], 11, 12))                 *   60 + # minutes
              as.numeric(substr(sessions[[ii]], 13, 14)))                        ;# seconds
      }
      
      # Convert all time values into seconds from 2000 ("time_s")
      for(ii in 1:length(times))  {
        times_s[[ii]] <- ((as.numeric(substr(times[[ii]], 1, 4)) - 2000) * 365 * 24 * 3600 + # year
              as.numeric(substr(times[[ii]], 5, 6))         * 30 * 24 * 3600 + # month
              as.numeric(substr(times[[ii]], 7, 8))              * 24 * 3600 + # day
              as.numeric(substr(times[[ii]], 9, 10))                  * 3600 + # hours
              as.numeric(substr(times[[ii]], 11, 12))                 *   60 + # minutes
              as.numeric(substr(times[[ii]], 13, 14)))                        ;# seconds
      }
            
      times_matched <- match(sessions,times) # times_matched equals the position in time values where each new session starts. E.g.: 1 3 28
      
      total_time <- 0;
      
      # When more than one session, check for length of sessions
      if (length(sessions)>1) {
        for(ii in 1:(length(sessions)-1)) {
            total_time <- total_time + times_s[times_matched[ii+1]-1] - times_s[times_matched[ii]];  # In seconds
          } # end of for; do with all except the last one, which will be added  like
          #         times_s[length(times_s)] - times_s[times_matched[3]] ;
          
          total_time <- total_time + times_s[length(times_s)] - times_s[times_matched[ii+1]] ;
          
      # end of if more than one sessions
      } else {
        total_time <- times_s[length(times)] - times_s[1];  # In seconds
      } # end of case when only one session
            
      # ini - Calculate duration of sessions
        # Initialize "duration in seconds" variable
        duration_s <- NULL;
        # If only one session, calculate directly
        if (length(sessions)==1) {
          duration_s <- rbind(duration_s, times_s[length(times_s)] - times_s[times_matched[1]]);  # In seconds  
        }else{
        # else, calculation between one session and the time just before from the next session
          # For ii (1:length(times_matched)) { Duration = times[times_matched[ii+1]-1] - times[times_matched[ii]]}
          for(ii in 1:(length(times_matched)-1)) {
            # ii <- ii+1  #for debugging in eclipse
            duration_s <- rbind(duration_s, times_s[times_matched[ii+1]-1] - times_s[times_matched[ii]]);  # In seconds  
          } # end of for; do with all except the last one, which will be added  like
            duration_s <- rbind(duration_s, times_s[length(times_s)] - times_s[times_matched[ii+1]]);  # In seconds  
        }
        # end of case when more than one session
      # end - Calculate duration of sessions

      # Append "duration in seconds" column to the session_list variable
      session_list <- cbind(session_list,time_d_h_m(duration_s))

	  # ini - Calculate number of active actions
	  n_active_actions <- length(unlist(gregexpr("<event[^>]*?(?:type=\"active\")",xml_r)));
	  # In order to have the number of active actions per session, I'll have to use xpath syntax,
	  # and not just some simple grepexpr
	  n_active_actions_per_session <- table(unlist(xpathApply(xml_net2, "//event[@type=\"active\"]", xmlGetAttr, "session")));
	  
	    # Ensure that if no active actions per session, 0 (as a value) is assigned
		if (length(n_active_actions_per_session) == 0 && (typeof(n_active_actions_per_session) == "character" || typeof(n_active_actions_per_session) == "integer")) {
			n_active_actions_per_session <- 0
		}
		# We could also test against 
		# identical(as.character(n_active_actions_per_session), character(0))

	  # sum(n_active_actions_per_session)

	  # Append the number of different actions performed by the student per session in the log file
	  session_list <- cbind(session_list,n_active_actions_per_session)
	  
      # ini - Calculate number of quick sessions
        n_quick_sessions <- 0; # quick defined by Jordi as less than 30 seconds
#        # When more than one session, check for length of sessions
#        if (length(sessions)>1) {
          for(ii in 1:(length(sessions))) {
            # Check at session_list, if time_s_end minus time_s_ini is smaller than 60 seconds
            if ((duration_s[ii]) < 60) {
              n_quick_sessions <- n_quick_sessions +1;
            }
          } # end of for
#        } else { # end of if length(sessions)>0, and check when only 1 session
#			if ((duration_s[ii]) < 60) {
#				n_quick_sessions <- 1;
#			}
#		}
      # end - Calculate number of quick sessions

		# Calculate n_unique_milestones, milestone10
		# Number of rows in the location_pivottable
		#dim(location_pivottable)[1]
		# If the milestone is achieved, the value of such sum should be higher than the total number of rows
		# Convert location pivot_table into numeric and sum all values from session numbers for each column (milestone)
		#length(lapply(lapply(location_pivottable[,-1],as.numeric),sum))
		n_unique_milestones <- length(lapply(lapply(location_pivottable[,-1],as.numeric),sum)[lapply(lapply(location_pivottable[,-1],as.numeric),sum) > dim(location_pivottable)[1]])
		
		if ( n_unique_milestones > 0) {
			# try to check if milestone10 is found only if there are some milestones; otherwise, error would be returned 
			if ( lapply(lapply(location_pivottable[,-1],as.numeric),sum)[10] > dim(location_pivottable)[1] ) {
				milestone10 <- 1
			}else{
				milestone10 <- 0	
			}
		}else{ # cases when there are no milestones found at all: assign milestone10 manually to 0 also
			milestone10 <- 0
		}

		# Calculate number of times that the student opens the help button to read the Stamedia I class notes
		n_statmedia_button <- length(xpathApply(xml_net2, "//event[@action=\"Button\"]")) # 

		#-------------------------------------------------------
		# FETCH GRADES and SUM them
		#-------------------------------------------------------
		# Initialize variables
		nodes_graded <- NULL;
		sections <- NULL;
		n_sections <- NULL;
		gradepoint_table <- NULL;
		gradepoints <- NULL;
		outofmaxpoints <- NULL;
		
		# Fetch all grades from all answers to all sections
		#nodes_graded <- xpathApply(xml_net, "//event[@action=\"Grade\"]") # 
		nodes_graded <- xpathApply(xml_net2, "//event[@action=\"Grade\"]") # 
		# length(nodes_graded);
#as.numeric(xmlAttrs(xmlChildren(unlist(nodes_graded)[[ii]])[[4]])[[2]])
#as.numeric(xmlAttrs(xmlChildren(unlist(nodes_graded)[[1]])[[4]])[[2]])

		# n_sections # sections are the forms with questions for the students to be graded upon
		#sections <- xpathApply(xml_net, "//param[@name=\"Section\"]", xmlGetAttr, "value") # it works!!! nice xml take2 approach & functions!
#		sections <- getNodeSet(xml_net, "//param[@name=\"Section\"]", xmlGetAttr, "value") # it works!!! nice xml take2 approach & functions!
		sections <- xpathApply(xml_net2, "//param[@name=\"Section\"]", xmlGetAttr, "value") # it works!!! nice xml take2 approach & functions!
#		sections <- getNodeSet(xml_net2, "//param[@name=\"Section\"]", xmlGetAttr, "value") # it works!!! nice xml take2 approach & functions!
		# sections
		n_sections <- length(unique(as.numeric(unlist(sections))))
		# n_sections
		if (length(nodes_graded) > 0) { # check for the case when no answer is given at all, and no grade is referred in the xml file
			for(ii in 1:(length(nodes_graded))) {		
				if (n_sections == 0) { # Case for 2008, when no section is indicated in the grading at the end of the traces file (line type 7)
					#  hardcode the min number of sections to 1 (in 2008), when no explicit sections names were found in the traces file 
					section <- 0; 
					field <- as.numeric(xmlSApply(unlist(nodes_graded)[[ii]], xmlGetAttr, "value")[1]); # get the field (question) for each one of the list
					final_answer <- as.numeric(xmlSApply(unlist(nodes_graded)[[ii]], xmlGetAttr, "value")[2]); # get the final answer for each one of the list
					# convert decimal points written with commas (as in 2008 traces files) into points
					gradepoint_comma <- xmlSApply(unlist(nodes_graded)[[ii]], xmlGetAttr, "value")[3]; #decimal points as commas
					gradepoint_point <- gsub(",",".", gradepoint_comma, fixed = TRUE); # decimal points as points
					gradepoint <- as.real(gradepoint_point); # get the gradepoint for each one of the list
				} else { # Case for > 2008, when section is indicated in the grading at the end of the traces file (line type 9)
					section <- as.numeric(xmlSApply(unlist(nodes_graded)[[ii]], xmlGetAttr, "value")[1]); # get the section number for each one of the list
					field <- as.numeric(xmlSApply(unlist(nodes_graded)[[ii]], xmlGetAttr, "value")[2]); # get the field (question) for each one of the list
					final_answer <- as.numeric(xmlSApply(unlist(nodes_graded)[[ii]], xmlGetAttr, "value")[3]); # get the final answer for each one of the list
					gradepoint <- as.real(xmlSApply(unlist(nodes_graded)[[ii]], xmlGetAttr, "value")[4]); # get the gradepoint for each one of the list
				}
				# From the list of nodes related to grading fetched...
				gradepoint_table <- rbind(gradepoint_table, c(section, field, final_answer, gradepoint)); # assign each set values to the matrix of gradepoints 
			} # end of else fro mthe for loop
		}else{ # provide some value for field, final answer and gradepoint manually
			# From the list of nodes related to grading fetched...
			gradepoint_table <- rbind(c(0, 0, 0, 0 ),c( 0,  0, 0, 0)); # assign each set values to the matrix of gradepoints 
		} # end of if nodes_graded < or = 0		
		colnames(gradepoint_table) <- c("Section","Question","Final answer","Points");
		# gradepoint_table

		# 
		if (n_sections == 0) { # Case for 2008, when no section is indicated in the grading at the end of the traces file (line type 7)
			# hardcode the min number of sections to 1 (in 2008), when no explicit sections names were found in the traces file 
			n_sections <- 1; 
		}

		# show gradepoint
		for(ii in 1:n_sections) {		
			# In 2008 traces file format, there is no section name, so that the "ii" ( correlative number of section)
			#   will be hardcoded to "0", and thus, for traces of this year, the dummy variable "ii" will be "1", 
			#   but the "which" function has to match against "ii-1" (= the value "0") in the gradepoint table 
			if ( sum(gradepoint_table[,1]) == 0 ) {
				# case for traces files from 2008, where label for section is "0" (ii-1)
				gradepoint_table[which( gradepoint_table[,1] == ii-1 ),4]; # show points for the answers to the questions in the section ii
				gradepoints[ii] <- sum(gradepoint_table[,4][which( gradepoint_table[,1] == ii-1 )]); # sum points for the section ii
				# Case in 2008 when no answers are provided at all, so hardcoded to 16 questions
				if (length(nodes_graded) > 0) {
					outofmaxpoints[ii] <- 16;
				}else{
					# normal case, when the maximum number of points is given by the number of times the action grade shows up in the xml traces file
					outofmaxpoints[ii] <- length(gradepoint_table[,4][which( gradepoint_table[,1] == ii-1 )]);
				}
			} else {
				# case for traces files from after 2008, where label for section is "ii" (1 or 2)
				gradepoint_table[which( gradepoint_table[,1] == ii),4]; # show points for the answers to the questions in the section ii
				gradepoints[ii] <- sum(gradepoint_table[,4][which( gradepoint_table[,1] == ii)]); # sum points for the section ii
				outofmaxpoints[ii] <- length(gradepoint_table[,4][which( gradepoint_table[,1] == ii)]);				
			}
		}
		# colSums(gradepoints) # We don't need this one since it sums by  columns for all points, without splitting them among sections
		
		# --------------------------------------------------------

      #-------------------------------------------------------
      ## CALCULATIONS FOR THE REPORTS - end
      #-------------------------------------------------------

      #-------------------------------------------------------
      ## START REPORT ON R CONSOLE (local or through website)
      #-------------------------------------------------------
      if (console_report == "1") { # In case report on console is desired (not if just willing to generate single file with all data)
        ## ini - Print html report through Wiki syntax
        #      cat("\n", sep="");
        
        cat("\n", sep="");
        cat("! Computer-supported Learning Assessment - '", report_type,"' (v0.1) - Student: ", studentId,"\n", sep="");
        cat("__Start:__ ", time_ini , "\n__End  :__ ", time_end,"\n\n", sep="");
        
        cat("{maketoc title=\"\"}\n\n", sep="");
        
        cat("!!# General Information", sep="\n");
        cat("||", sep="\n");
		cat(paste("Student: ", studentId, sep=" | "), sep="\n");
		cat(paste("Total time spent: ", time_d_h_m(total_time), sep=" | "), sep="\n");
        cat(paste("Number of sessions in total: ", length(sessions), sep=" | "), sep="\n");      
          cat(paste("Number of sessions which lasted more than 1 min: ", length(sessions) - n_quick_sessions, sep=" | "), sep="\n");
        cat(paste("Number of student actions: ", n_active_actions, sep=" | "), sep="\n");
		cat(paste("Number of total actions: ", xmlElementSummary(abs_reportedfile0)$nodeCounts[[2]], sep=" | "), sep="\n");
		cat(paste("Number of different milestones achieved (/max.): ", paste(n_unique_milestones, "/", n_milestones, sep=""), sep=" | "), sep="\n");
		cat(paste("Number of times accessing the 'Statmedia I' class notes: ", n_statmedia_button, sep=" | "), sep="\n");
		cat("||", sep="\n");
      
        ## Masterig XML files - take2
        ## ************************************************************************************************
        ## **************** Documentation at: http://www.omegahat.org/RSXML/shortIntro.html ***************
        ## ************************************************************************************************
        # doc = xmlInternalTreeParse("Install/Web/index.html.in")
#        xml_net = xmlInternalTreeParse(abs_reportedfile0);
                
          cat("!!# Assessment", sep="\n");
          cat("!!!# Significant Informations", sep="\n");
		  
		  # report gradepoints
		  cat(paste("__Grade for each section (", n_sections, "):__\n", sep=""));
		  for(ii in 1:n_sections) {		
			  if (section=="0") { # Case for traces files from 2008
				  section_label <- "0"
			  } else {
				  section_label <- ii;
			  }
			  cat(paste("Section ", section_label, ": ", gradepoints[ii], "/", outofmaxpoints[ii], " points.\n", sep="")); # shows the sume of grade points for each section 
		  }
		  
          cat("__Grades on questions:__ \n", sep=""); # NOTA PROBLEMA (si existeix)
          #   unlist(xpathApply(xml_net, "//event[@action=\"Grade\"]/description"))[[1]]
          #   unlist(xpathApply(xml_net, "//event[@action=\"Grade\"]/description"))
          #   cat(unlist(xpathApply(xml_net, "//event[@action=\"Grade\"]/description")), sep=""); #
          #   unlist(xpathApply(xml_net2, "//event[@action=\"Grade\"]", xmlGetAttr, "session"))
          #   unlist(xpathApply(xml_net, "//event[@action=\"Grade\"]/description", xmlValue, "description"))
          cat(unlist(xpathApply(xml_net2, "//event[@action=\"Grade\"]/description", xmlValue, "description")), sep="\n");
      
          cat("\n!!!# Process Assessment", sep="\n");
      
        cat("Locations of the milestones in the xml file, printed in pivot table format\n", sep = "");
        #print(location_pivottable);
        
        # Convert df location_pivottable in a pretty table
        cat(paste("{FANCYTABLE(head=\"", sep=""));
		cat(paste(colnames(location_pivottable), sep = "", collapse=" | "), sep = "");          
		cat(paste("\",headaligns=\"center\",headvaligns=\"middle\",sortable=\"n\",colaligns=\"center", sep=""));
          ii<-1;
          for (ii in 1:(dim(location_pivottable)[2]-1)) {
            cat(paste(' | center ', sep = ''), sep = "");          
          }
          cat(paste("\",colvaligns=\"middle\")}", sep=""));
        cat("\n", sep = "");
        for (i in 1:nrow(location_pivottable)) {
            for (j in 1:ncol(location_pivottable)) {
              cat(paste('', location_pivottable[i, j] ,' | ', sep = ''), sep = "");          
            }
            cat("\n", sep = "");
        }
		# Print again the milestone names in the last row
		cat(paste(colnames(location_pivottable), sep = "", collapse=" | "), sep = "");          
		cat("\n", sep = "");
		# Calculate counts for each milestone
		milestone_count <- lapply(lapply(location_pivottable[,-1],as.numeric),sum)
		for (names_ii in 1:length(location_pivottable[,-1])) {
			if ((as.integer(milestone_count[names_ii]) - dim(location_pivottable)[1]) > 0) {
				milestone_count[names_ii] <- "X";
			} else {
				milestone_count[names_ii] <- "-";
			}
		}
		# Show if a milestone has been achieved (X) or not (-)
		string_milestone_counts_console <- paste("Any | ", paste(milestone_count[1:length(milestone_count)-1], "", sep = ' | ', collapse=""), sep="", collapse="");
		string_milestone_counts_console <- paste(string_milestone_counts_console, unlist(milestone_count[length(milestone_count)]),sep="", collapse="");
		cat(paste(string_milestone_counts_console, "\n", sep=""));
		
		cat(paste("{FANCYTABLE}\n", sep=""));
		cat(paste("{SUB()}''__Notes__:'' \n* ''The numbers in the table indicate the Session number.''\n", sep=""));
		cat(paste("* ''Last row indicates whether each milestone a milestone has been achieved (X) or not (-).''\n", sep=""));
		cat(paste("* ''There is no direct relationship ensured between the grade and the number of milestones shown in the previous table.{SUB}''\n\n", sep=""));
		cat(paste("|| ::__Milestone%%%Number__:: | ::__Milestone%%%Name__:: | ::__Milestone description__:: \n", sep=""));
		cat(paste("01 | LdGA | Variable Grup A is loaded in the calculator\n", sep=""));
		cat(paste("02 | LdGB | Variable Grup B is loaded in the calculator\n", sep=""));
		cat(paste("03 | 1SaA | One sample analysis is run on variable Grup A\n", sep=""));
		cat(paste("04 | 1SaB | One-sample analysis is run on variable Grup B\n", sep=""));
		cat(paste("05 | 2SaAB | Two-sample analysis is run with variables Grup A and Grup B\n", sep=""));
		cat(paste("06 | LdCB | Variable Control_Basal is loaded in the calculator\n", sep=""));
		cat(paste("07 | LdC3 | Variable Control_3_setmanes is loaded in the calculator\n", sep=""));
		cat(paste("08 | 2SaB3 | Two-sample analysis is run with variables Control_Basal and Control_3_setmanes\n", sep=""));
		cat(paste("09 | PaiB3 | Paired samples contrast is selected with variables Control_Basal and Control_3_setmanes\n", sep=""));
		cat(paste("10 | UnRB3 | Unilateral right contrast is select with variables Control_Basal and Control_3_setmanes\n", sep=""));
		cat(paste("11 | LdDop | Variable Descens_Dopamina is loaded in the calculator\n", sep=""));
		cat(paste("12 | LdNic | Variable Nicotina is loaded in the calculator\n", sep=""));
		cat(paste("13 | RegDN | Regression analysis is run with Descens_Dopamina and Nicotina\n", sep=""));
		cat(paste("14 | LinDN | Regression Line is selected with variables Descens_Dopamina vs Nicotina\n", sep=""));
		cat(paste("15 | PreDN | Linear prediction of Descens_Dopamina for Nicotina=140 is calculated \n", sep=""));
		cat(paste("||\n", sep=""));

				
				
		cat("__Milestones required for each question__\n")
		cat("* __Section 1__\n")
		cat("** Question 1.1: -\n")
		cat("** Question 1.2: -\n")
		cat("** Question 1.3: Requires (01.LdGA and 03.1SaA) or (01.LdGA, 02.LdGB and 05.2SaAB)\n")
		cat("** Question 1.4: Requires (02.LdGB and 04.1SaB) or (01.LdGA, 02.LdGB and 05.2SaAB)\n")
		cat("** Question 1.5: -\n")
		cat("** Question 1.6: Requires (01.LdGA and 03.1SaA) or (01.LdGA, 02.LdGB and 05.2SaAB)\n")
		cat("** Question 1.7: Requires (02.LdGB and 04.1SaB) or (01.LdGA, 02.LdGB and 05.2SaAB)\n")
		cat("* __Section 2__\n")
		cat("** Question 2.1: -\n")
		cat("** Question 2.2: Requires 06.LdCB, 07.LdC3, 08.2SaB3, 09.PaiB3 and 10.UnRB3\n")
		cat("** Question 2.3: Requires 06.LdCB, 07.LdC3, 08.2SaB3, 09.PaiB3 and 10.UnRB3\n")
		cat("** Question 2.4: Requires 06.LdCB, 07.LdC3, 08.2SaB3, 09.PaiB3 and 10.UnRB3\n")
		cat("** Question 2.5: -\n")
		cat("** Question 2.6: Requires 11.LdDop, 12.LdNic, 13.RegDN and 14.LinDN\n")
		cat("** Question 2.7: Requires 11.LdDop, 12.LdNic, 13.RegDN and 14.LinDN\n")
		cat("** Question 2.8: Requires 11.LdDop, 12.LdNic, 13.RegDN and 14.LinDN\n")
		cat("** Question 2.9: Requires 11.LdDop, 12.LdNic, 13.RegDN, 14.LinDN and 15.PreDN\n")
		
      ##  length(location_pivottable)
      ##  cat(paste(for(ii in 1:length(location_pivottable)) paste("location_pivottable[,ii],", sep=""), sep=" | "), sep="\n");
        
      
          cat("!!# Sessions",sep="\n");
      #    cat("LLISTA DE SESSIONS: Ordre / Codi / Temps inicial / DuraciÃ³ / Nombre dâaccions actives\n\n", sep="");    
        cat("||", sep=" ")
        cat(paste("Session_id", "Session_label", "Start time", "Duration", "N Student Actions", sep=" | "), sep="\n");
        cat(paste(session_list[,1], session_list[,2], session_list[,3], session_list[,4], session_list[,5], sep=" | "), sep="\n");
        cat("||", sep="\n");
      
        #    cat("!!!# Significant Informations By Session", sep="\n");
        #    cat("LLISTAT DE RESPOSTES DEL PROBLEMA A FINAL DE SESSIÃ: Nom resposta / Valor\n\n", sep="");
        ## Aquests valors no es donen per que requeririen mÃ©s treball amb xpath dins d'R per a cada exercici, i Jordi proposar de deixar-ho correr, llavors.
      
          cat("!!# Process Assessment Index", sep="\n");
          #cat("~~grey:''LLISTAT FITES: Nom / S/N / Nombre de vegades / Ordres / Temps''~~\n\n", sep="");    
          #cat("List of milestones, with the action_id where they appreared: 'id' 'action_id', 'milestone_id','milestone_label','position', 'length', 'Session' (only shown reocrds with milestone matches):\n", sep = "");
        #print(location_df);
#        print(cbind(location_df[1],location_df[3:5],location_df[7]))
        cat("||", sep=" ")
        cat(paste("Session_id", "action_id", "milestone_label", "~~grey:position %%% {SUB()}(in ''chars.'' at xml_r){SUB}~~", "~~grey:length %%% {SUB()}(in ''chars.'' at xml_r){SUB}~~", sep=" | "), sep="\n");
        cat(paste(location_df[,7], location_df[,1], location_df[,3], paste("~~grey:", location_df[,4], "~~", sep=""), paste("~~grey:", location_df[,5], "~~", sep=""), sep=" | "), sep="\n");
        cat("||", sep="\n");
        
          cat("!!-# Full work tracing", sep="\n");
        # LLISTAT DESCRIPCIONS: Temps / Text  
        #cat("\n{REMARKSBOX(type=\"tip\",title=\"Full description of the actions logged\",highlight=\"n\",close=\"n\")}{FADE(label=\"Click HERE to view/hide it\")}", sep="");
        cat(paste("\n* ",xml_net[ "event/description/#" ], "", sep=""))

			## Alternative method to fetch the descriptions when (for whatever reason) the simple method in the line above fails (xml_net[ "event/description/#" ])
			#description_messages =  lapply(xpathSApply(xml_net2, "//description"), toString.XMLNode)
			#description_messages =  gsub("<description>", "", description_messages)
			#description_messages =  gsub("</description>", "", description_messages)
			#cat(paste("\n* ",description_messages, "", sep=""))

		#cat("\n{FADE}{REMARKSBOX}", sep="");

        
        cat("\n");
        cat("!!# Technical Information", sep="\n");
          cat("Processed in ", format(Sys.time(), "%d-%m-%Y %H:%M:%S"), " (", reporter_r_script,")\n", sep="");
          cat("File Path of this report: ", path, "/", reporter_path_to_input_files, "\n", sep="");
        ## end - Print html report through Wiki syntax
      };
        
      #-------------------------------------------------------
      ## END REPORT ON R CONSOLE (local or through website)
      #-------------------------------------------------------
      
    #-------------------------------------------------------
    ## START REPORT ON FILE ON DISK (locally or on the server disk)
    #-------------------------------------------------------
      ## ini - Add Basic stats ("low hanging fruit") from X4L, after X4L is back working for me even with Ubuntu Lucid upgrades of packages & RKward-devel (18/05/10)
        write("", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
        write("\"Basic counts in the xml file\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
        write("\"----------------------------\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
        write(paste("\"Number of nodes type 'log':\", ", xmlElementSummary(abs_reportedfile0)$nodeCounts[[4]], sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = "")
        write(paste("\"Number of nodes type 'description':\", ", xmlElementSummary(abs_reportedfile0)$nodeCounts[[3]], sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = "")
        write(paste("\"Number of nodes type 'event':\", ", xmlElementSummary(abs_reportedfile0)$nodeCounts[[2]], sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = "")
        write(paste("\"Number of nodes type 'param':\", ", xmlElementSummary(abs_reportedfile0)$nodeCounts[[1]], sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = "")
        
        # # In case we need to check manually the names and values of each column in xmlElementSummary
        #xmlElementSummary(abs_reportedfile0)$nodeCounts
        
        
        ## end - Add Basic stats ("low hanging fruit") from X4L, after X4L is back working for me even with Ubuntu Lucid upgrades of packages & RKward-devel (18/05/10)
        
        # Record those results manually obtained at the report file
        write("", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
        write("\"Basic report on student activity\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
        write("\"--------------------------------\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
        write(paste("\"Student:\", ", studentId, sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write(paste("\"Total time spent:\", \"", total_time, " seconds (", time_d_h_m(total_time), ")\"", sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write(paste("\"Number of sessions in total:\", ", length(sessions), sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write(paste("\"Number of sessions which lasted more than 1 min:\", ", length(sessions) - n_quick_sessions, sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write(paste("\"Number of student actions (active):\", ", n_active_actions, sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write(paste("\"Number of total actions (active and reactive):\", ", xmlElementSummary(abs_reportedfile0)$nodeCounts[[2]], sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = "")
		write(paste("\"Number of different milestones achieved (/max.):\", \"", n_unique_milestones, "/", n_milestones,"\"",  sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write(paste("\"Number of times accessing the 'Statmedia I' class notes:\", ", n_statmedia_button, sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		
		# report gradepoints
		write(paste("\n\"Grade for each section (", n_sections, ")\"", sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ");
		write("\"--------------------------\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		for(ii in 1:n_sections) {		
			if (section=="0") { # Case for traces files from 2008
				section_label <- "0"
			} else {
				section_label <- ii;
			}
			write(paste("\"Section ", section_label, "\", \"", gradepoints[ii], "/", outofmaxpoints[ii], " points\"", sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " "); # shows the sume of grade points for each section 
		}
		write(paste("\"Final grade\", \"", sum(gradepoints)/sum(outofmaxpoints)*10, " points\"", sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " "); # shows the sume of grade points for each section 
		
		
        write(paste("\n\"Sessions:\", ",sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
        write("\"Session Id\", \"Session Label\", \"Start time\", \"Duration\",  \"Number of Student Actions\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
        write(paste("\"", session_list[,1], "\", \"", session_list[,2], "\", \"", session_list[,3], "\", \"", session_list[,4], "\", \"",  session_list[,5], "\"", sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep="\n");  
        
        write(paste("\n\"Locations of the milestones in the xml file:\"",sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
        write("\"with the syntax shown below (only shown records with milestone matches):\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
        write("\"--------------------------------\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
        #write("\"id\",\"action_id\",\"milestone_id\",\"milestone_label\",\"position\",\"length\",\"Session_label\",\"Session_id\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
        #write.table(location_df, row.names=TRUE, col.names=FALSE, file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = ",")
        write("\"id\",\"Session_id\",\"action_id\",\"milestone_number\",\"milestone_label\",\"position in xml_r\",\"length in xml_r\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
        write.table(cbind(location_df[7], location_df[1], location_df[2:5]), row.names=TRUE, col.names=FALSE, file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = ",")
        
        write("\n\"Same as above but in a Pivot table shape\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
        write("\"--------------------------------\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
        write("\"action_id\",\"milestone_label's\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		# Write the milestone names in the first row.
		write(paste("\"Action_id", paste(t(milestone_label), sep = "", collapse = "\",\""), "\"", sep = "\", \"", collapse = ""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = ",")		          
		write.table(location_pivottable, row.names=FALSE, col.names=FALSE, file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = ",")
			# Write again at the end of the table, the milestone names.
			write(paste("\"Action_id", paste(t(milestone_label), sep = "", collapse = "\",\""), "\"", sep = "\", \"", collapse = ""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = ",")		          
			# Show if a milestone has been achieved (X) or not (-)
			string_milestone_counts_file <- paste("\"Any\",\"", paste(milestone_count[1:length(milestone_count)], sep = "", collapse="\",\""), "\"", sep="");
			write(paste(string_milestone_counts_file, "\n", sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = ",")		          

			
		write(paste("\"__Notes__\"", sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = ",")
		write(paste("\"* The numbers in the table indicate the Session number.\"", sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = ",")
		write(paste("\"* Last row indicates whether each milestone a milestone has been achieved (X) or not (-).\"", sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = ",")
		write(paste("\"* There is no direct relationship ensured between the grade and the number of milestones shown in the previous table.\"\n", sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = ",")
		
		write("\n\"Milestone Number\", \"Milestone Name\", \"Milestone description\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"-----------------------------------------------------------------\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"01\", \"LdGA\", \"Variable Grup A is loaded in the calculator\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"02\", \"LdGB\", \"Variable Grup B is loaded in the calculator\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"03\", \"1SaA\", \"One sample analysis is run on variable Grup A\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"04\", \"1SaB\", \"One-sample analysis is run on variable Grup B\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"05\", \"2SaAB\", \"Two-sample analysis is run with variables Grup A and Grup B\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"06\", \"LdCB\", \"Variable Control_Basal is loaded in the calculator\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"07\", \"LdC3\", \"Variable Control_3_setmanes is loaded in the calculator\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"08\", \"2SaB3\", \"Two-sample analysis is run with variables Control_Basal and Control_3_setmanes\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"09\", \"PaiB3\", \"Paired samples contrast is selected with variables Control_Basal and Control_3_setmanes\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"10\", \"UnRB3\", \"Unilateral right contrast is select with variables Control_Basal and Control_3_setmanes\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"11\", \"LdDop\", \"Variable Descens_Dopamina is loaded in the calculator\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"12\", \"LdNic\", \"Variable Nicotina is loaded in the calculator\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"13\", \"RegDN\", \"Regression analysis is run with Descens_Dopamina and Nicotina\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"14\", \"LinDN\", \"Regression Line is selected with variables Descens_Dopamina vs Nicotina\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"15\", \"PreDN\", \"Linear prediction of Descens_Dopamina for Nicotina=140 is calculated \"\n", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")		
		
		write("\"Milestones required for each question\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"-------------------------------------\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"* __Section 1__\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"** Question 1.1\", \"-\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"** Question 1.2\", \"-\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"** Question 1.3\", \"Requires (01.LdGA and 03.1SaA) or (01.LdGA, 02.LdGB and 05.2SaAB)\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"** Question 1.4\", \"Requires (02.LdGB and 04.1SaB) or (01.LdGA, 02.LdGB and 05.2SaAB)\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"** Question 1.5\", \"-\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"** Question 1.6\", \"Requires (01.LdGA and 03.1SaA) or (01.LdGA, 02.LdGB and 05.2SaAB)\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"** Question 1.7\", \"Requires (02.LdGB and 04.1SaB) or (01.LdGA, 02.LdGB and 05.2SaAB)\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"* __Section 2__\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"** Question 2.1\", \"-\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"** Question 2.2\", \"Requires 06.LdCB, 07.LdC3, 08.2SaB3, 09.PaiB3 and 10.UnRB3\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"** Question 2.3\", \"Requires 06.LdCB, 07.LdC3, 08.2SaB3, 09.PaiB3 and 10.UnRB3\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"** Question 2.4\", \"Requires 06.LdCB, 07.LdC3, 08.2SaB3, 09.PaiB3 and 10.UnRB3\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"** Question 2.5\", \"-\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"** Question 2.6\", \"Requires 11.LdDop, 12.LdNic, 13.RegDN and 14.LinDN\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"** Question 2.7\", \"Requires 11.LdDop, 12.LdNic, 13.RegDN and 14.LinDN\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"** Question 2.8\", \"Requires 11.LdDop, 12.LdNic, 13.RegDN and 14.LinDN\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write("\"** Question 2.9\", \"Requires 11.LdDop, 12.LdNic, 13.RegDN, 14.LinDN and 15.PreDN\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
				
        write("\n\"Human readable description of student interaction\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
        write("\"-------------------------------------------------\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
        write(paste("\"", xml_net[ "event/description/#" ] , "\"", sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
        
		write("\"-------------------------------------------------\"", file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write(paste("\"Processed in \", \"", format(Sys.time(), "%d-%m-%Y %H:%M:%S"), "\"", sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write(paste("\"Version\", \"", reporter_r_script,"\"", sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		write(paste("\"File Path of this report\", \"", path, "/", reporter_path_to_input_files, "\"", sep=""), file=paste(reporter_path_to_output_files, reportedfile0, "_", studentId, "_report.txt",sep=""), append = TRUE, sep = " ")
		
        
            # Free resources used for keeping the xml file in memmory
            #   free(xml_r)
            #   free(xml_net)
            ## - end stats
    #-------------------------------------------------------
    ## END REPORT ON FILE ON DISK (locally or on the server disk)
    #-------------------------------------------------------
  
    ##########################################################
    ## - end report on STATISTICS logs
    ##########################################################
     }
    
    ## Delete the report_file_list file if not in debug mode
    if (debug_desc != 1) {
      system(paste("rm ", report_on_file_list_name, sep=""), TRUE);
    }
    
    # Close connection to the source xml file
    close(con);
  
  # ================================================================
  # End the loop for processing source file with traces to process
  # ================================================================

  # If report on single_data_file is on, write data from this student here
  if (single_data_file =="1") {
    # write(paste("\"Student\", \"N_Student_Actions\", \"Time_spent_sec\", \"N_Sessions\", \"N_Sessions_more1\", \"N_Milestones\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\"", sep=""), file=single_data_file_name, append = TRUE, sep = "");
    write(paste(studentId, ",", n_active_actions, ",", total_time, ",", length(sessions), ",", length(sessions) - n_quick_sessions, ",", dim(location_pivottable)[1], ",", n_unique_milestones, ",", milestone10, ",", n_statmedia_button, ",\"", sum(gradepoints),"/",sum(outofmaxpoints), "\",\"", sum(gradepoints)/sum(outofmaxpoints)*10, "\",\"", abs_reportedfile0, "\"",  sep=""), file=single_data_file_name, append = TRUE, sep = "");	
  };

  } # end of processing that file from the list of files to report on

  # When in local mode, show in the console the file number (out of max files to report on) and its name
  if (reporter_mode != "web") {
	  cat(paste("#############################################################\n", sep=""),sep="");
	  cat(paste("## Job finished                                            ##\n", sep=""),sep="");
	  cat(paste("#############################################################\n", sep=""),sep="");
	  # If monitor memmory is on, show a summary at the end
	  if (profile_memory == 1) {
		  Rprof(NULL)
		  print(summaryRprof(filename = rprof_filename, chunksize = 5000,
		  	memory=c("none","both","tseries","stats"),
		  	index=2, diff=TRUE, exclude=NULL))		  
	  }  
  }

 
# } else { # XXXX: End of if there is a file to process.
# cat("There is no file to process and report on. Go back to your [index.php|HomePage] to add a file"); # XXXX
# } # XXXX
# {RR}

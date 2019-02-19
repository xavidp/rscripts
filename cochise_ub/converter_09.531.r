##################################################################################
# ==================== Script to import student tracker data. ====================
# Copyleft 2009-2011 Xavier de Pedro (GNU/GPL'd)
# xavier.depedro(a)ub.edu
# http://cochise.bib.ub.es
##################################################################################
# Name of this r script to convert tracker log:
converter_r_script = "converter_09.531.r"

##################################################################################
# Run-time parameters
##################################################################################
#path<-"/media/2B0B4E266B7FBC41/grof_ub/Dades_prova_test";
path<-"/home/xavi/workspace/Dades_prova_test";

# Param start_clean_output_dir to indicate whether you want to remove the leftover files from the converter_path_to_output_files or not
# 1 = remove *.xml, *.txt and *.csv files at startup | 0 = leave that directory as is.
start_clean_output_dir <- 1;

# Param debug_desc to indicate whether description fileds have to be followed by a description-auto-log line (for debugging) or not.
# 1 = add that description-auto-log line. 0 = clean output at the xml file.
debug_desc <- 0;

testrun <- "0" # Param to indicate whether test run should be performed (test=1, on test directories) or normal run (test=0)

if (testrun == "1") {
	converter_path_to_input_files = "test/in/";
	converter_path_to_output_files = "test/out/";	
}else{
	#converter_path_to_input_files = "files_in/";
	#converter_path_to_output_files = "files_out/";
	converter_path_to_input_files = "data/2008_StatMediaAmbRespostes/";
	converter_path_to_output_files = "files_out/2008/";	
}

##################################################################################

# **************************************************************************************************************************
# * dependencies: debian package "tofrodos" (or equivalent in other distros) is required to convert files from dos to unix
# **************************************************************************************************************************
#
# TODO:* add the few missing aesthetics tasks to converter from Jordi's comments in a recent email
	#**Comentaris sobre RT4143Cor_xml_v5.xml (adjuntat)**
	#		C: Crític. Hi ha pèrdua d'informació.
	#		I: Important. Dificulta l'anàlisi
	#		E: Estètic. Quedaria millor
	#
	#+ I, l.85: Hi ha paràmetres en el nom de l'acció. Passa en molts dels
	#	--	outputs i en algun canvi de valors de paràmetres (l.1083) -- arreglat?

# TODO:* agafar codi d'alumne del nom de l'arxiu, i grup (dos caracters) i any.
#
# **************************************************************************************************************************
# Changelog 
# **************************************************************************************************************************
# Bugs fixed and things already implemented
#
# v0.9531 - 1103__: Added "event_type" attribute for all the other line types different from 10 to 17, to avoid potential confusion 
#			  with default event_type being considered as active instead of reactive.
#			Description in line type 1 (new session and save form) include a reference to "new session" nowadays, also. 
#			Make all line types to record a description node (avoid using string_desc_tmp as much as possible)
#			Fixed double writing of the html comment in the xml file with the converter version number.
#			Make line type 4 always start with an event tag and not only ini that patch for 2008. 
# 			Previous line type 2 have to be ended with a closing event tag accordingly
#		 	Show the file number and name in the console when processing in local host so show progress in batch mode.
#			Show the number of files with missmatches out of the total number of files converted
# v0.9530 - 110227: All columns (from all milestones) are shown in tables 
#			Unknown line types reported in console and in files also.
# 			param clean also cleans the csv files in the output dir
#			added event tag to lines 5, 6, 7, ... so that nowadays, anything looking like the answer of a form
#			  (with or without question, answer or points) generates a reactive type of event 
#			line type 7 corresponds to question,answer,points (2008), the equivalent to line type 9 for >2008.
#			Added the decoded time_id in the description strings for line types 4, 5, 6, 7. 
# 			Adapted dictionaries to report more strings from 2008 traces files, and line type 12.1 detection improved
#			Added testrun param (to ease the enabling/disabling of the test mode) and fixed issue when no Action_Id's...
#			fixed description of start_clean_output_dir
#			Fixed the missmatches in traces files from 2008. Added also position numbers to the report of mismatches.
# v0.9529 - 110206: Improved the mismatch_tag reporting (always on, and also when in batch mode): 
#			shown in console, report_on_file_list_name and reported on new file prepended with 00_N_missmatches_in_....txt
#			Ha ha ha :-): a new (misteriously non reported by its authors) line type 18 is found! 
#			   "# line type = 18   <- "1 4111 2010-05-25 18:13:50;But;Statmedia I ;11"
#			Fixed issue of tag event missmatch due to missing recognition of line types 18.x 
#			List of files to be converted: only fetching *.txt nowadays, to allow having backups of defective files such as RT4240Cor.old... (etc)
#			Fixed the name of the file with logs of missmatches, and save only also in log file when in debub_desc = 1
#			Add new param to clean *.txt and *.xml files from the output_path directory, 
# 			    and only in the case when input_path is different from output_path (to avoid deleting source data in data case)
#			Removed extra </event> tag when first line was line type 2, which produced defective xml files in some data files from 2008
#			Updated line type 6 (from 2008) to include similar description and tags as line type 7, and fix the tag missmatch in some data files from 2008
# v0.9528 - 110131: Removed deprecated param ("unused argument") "(extended = TRUE)" from 
#			strsplit(as.character(aa_tmp), " ", extended = TRUE, ... and similar strings
#			fixed issue with defective lines 15.2 such as "...;Jic;Change: values =;3139" (no values after "="). Present in 2010/RT4041Cor.txt
# v0.9527 - 100908: Fixed a few bugs for when no milestone is matched at all (yes, there are some students like that)
#			Fixed problem when no line type 3 at all (studentId assigned differently nowadays). 
# v0.9526c- 100907: Updated dictionary 10_cal: "sees input values" -> "sees output values". 
#			Removed the (wrong) timestamp from line type 9, since we don't know clearly when it belongs to. 
# v0.9526b- 100830: Applied fixes for the 3 issues reported by Jordi Cuadros in recent email. 
#			Code under bazaar revision control. Using bzr-explorer and Eclipse. Added time string at the begining of all descriptions.		     
# v0.9526 - 100528: Removed the " & " from line types, because it doesn't seem to comply with xml validity. 
#		    Tag event from all line types properly started or ended again (thanks to "kodos" and Jordi sample regexp's). 
#		    "_xml.xml" ending of xml file changed for ".xml", which is more repoter.r friendly :-). Renamed conversor.r to converter.r 
#		    double quotes inside description fields converted into single quotes, for compatibility with .csv format in reporter.r
#		    Added a check for event tag missmatches using regexp at the end of the conversion of each file.
# 		    "Operation in the calculator" in xml files from some line types: changed for the real action made by the user, as shown in the traces source file.
# 		    tag xml file with the right encoding it had: UTF-8
#		    Convert missing non-English strings in traces files for their English equivalents (Secció, ...)
# v0.9525 - 100517: Bug with the new version of "tofrodos" (which didn't understand the commnad "dos2unix" but "fromdos", and thus, comaplined with 
#		    the first read of aa_tmp) fixed. 
#		    Change of session fixed (properly identified and recorded). 
#		    Patch the bug in 1.4 when "Probabilistic-Change to show graph" (bb_tmp2 with just one value)
#		    fileN_log.txt made optional (only saved if in debug mode).
#		    Line type 7: param with 3 attributes splited in two params with 2 attributes each, since reporter complained (it seems invalid xml file).
#		                 Moreover, line type 7 seems non-existing any more, since the results-grades from forms are currently saved with another syntax
# v0.9524 - 100422: Many more bug fixes, in converter code and dictionaries. 
#		    Lines 11 to 17 revised one by one and sanitized. Added param for optional description-auto-log on a few line types for when debugging
#		    issues tagged as Critical or Important by Jordi have been already implemented/fixed. Still to apply the aesthetics ones.
#		    xml produced finally complies with xml tag structure, as checked by XML and R4X packages in R.
# v0.9523 - 100417: Removed date and time from all description content. Each event tag has only one description tag, with all content grouped inside. 
#		    Some more bugs fixed. Spaces in saved files for indenting changed for tabs. Added "event_type" attribute for line types 10 to 17.
#		    description-auto renamed to description tag after the old hand-made description tag without using dictionary for line types 10 to 17 
#		    has been renamed temporarily to description-old (before complete removal)
# v0.9522 - 100324: Statmedia Dictionary loaded as a whole and automatic recognition of sentences implemented. In process of diminishing false positives.., 
#		    <description-auto> and <description-auto-log> includeed in xml for debugging purposes. Many bugs fixed and improvements made.
# v0.951 - 100224:  Splicing content of line types from 10 to 17 and improving descriptions as human readable text. 
#		    Missing: Continue from line type 14 onwards.... (and/or check all cases in line type 13.x)
# v0.950 - 100210:  Moved descriptions to the end, and started to write the natural language in them. 
#		    Joined all lines from Calculator (1, 7.1, 7.2, under the same general line type)
#		    Renamed line types, to use the information fom the Statmedia dictionary. 
#		    Normal data lines from calculator and other frames classified as line types from 10 to 17. 
#		    The others re-set to lower line type numbers. See below for more details.
# v0.94 - 100122: Added string param to line type 2 because nowadays logs can (an dusually do) start with line type 2. Line type 9 added. 
#		  Since June 2009, 1st line of logs contain line type 2: "Respostes de studentId yyyy-mm-dd hh:mm:ss"
#		  Two new line types added: 10 for "Boto accio = Guardar", and 11 for "Secció 1 camp 1 resposta final = 1 punts = -0.0".
#		  Default line type set to "99".
# v0.93 - 090721: evaluate also the first line, since the 2nd set of files from Bioestadistica start also with.... surprise, surprise... "answers to forms" (!)
# 		+ several bugfixes
		# * Automagically identify also the type of the first line, since it's not always the same at the second set of files from Bioestadística. :-/
		# * line types 7.x have the initial <event> tag nowadays
		# * answer_X and question_X used indistinctively? (only the label "answer_" is used nowadays)
		# * ensure that param tag is surrounded by an event tag always
		# * number=1 all the time (changed to event_counter, to avoid confusions, and nowadays records only event numbers, like the reporter.r)
# v0.92 - 090330: implement suggestions from project meeting 090310
# v0.91 - 090303: set formulari and answers inside event tags, as well as the grading at the end
# v0.90 - 090227: get the right strings as parameters, even where there are many params in one column
# v0.8 - 090223: work in batch mode (process all files from the "in/" directory in an unattended mode)
# v0.7 - 090220: saves all events and params in diferent tags of the xml file.
#	6 line types identified already, and a 7th type for otherwise. 
#
# **************************************************************************************************************************
# Examples of line types identified by this script
# **************************************************************************************************************************
# line type = 1    aa_tmp <- "1ra entrada de la sessio. Formulari = P1t1"
# line type = 2    aa_tmp <- "Respostes de 4009 2008-05-19 12:32:25"
# line type = 3    aa_tmp <- "Respostes 4009"
# line type = 4    aa_tmp <- "Formulari = P1t2"
# line type = 4    aa_tmp <- "Form = P1t2"
# line type = 5    aa_tmp <- "1 2"
# line type = 6    aa_tmp <- "1 "
# line type = 7    aa_tmp <- "1 2 0,00"
# line type = 8    aa_tmp <- "Boto accio = Guardar"
# line type = 9    aa_tmp <- "Secció 1 camp 1 resposta final = 1 punts = -0.0"
# line type = 10.1 aa_tmp <- "9 4009 2008-05-19 12:27:04;Cal;Select variables - Variable 1: Grup_B;973"
# line type = 10.2 aa_tmp <- "29 4009 2008-05-30 10:21:31;Cal;Probabilistic-Output: f(x) = 0.39894 F(x) = 0.5 x = 1.64485 E(X) =0 Var(X)=1 1-F(x) = 0.5;2840"
# line type = 11.1 aa_tmp <- "1 4012 2009-05-31 18:15:21;Ons;1er cop;2073"
# line type = 11.2 aa_tmp <- "1 4012 2009-05-31 18:19:20;Ons;Change: percentil = 0;2088"
# line type = 11.3 aa_tmp aa_tmp <- "2 4012 2009-05-31 18:19:20;Ons;Output Descriptive = Grup_A 10 0.587 0.54 0.11 0.0291 0.59 0.65 0.0092 0.0008 0.54 ;2088"
# line type = 12.1 aa_tmp <- "1 4006 2009-05-31 19:06:19;Tws;1er cop;288"
# line type = 12.2 aa_tmp <- "2 4006 2009-05-31 19:06:19;Tws;Output Descriptive = Grup_A - Grup_B 10 0.08 -0.04 0.26 0.0849 0.8 0.22 0.0268 0.0072 0.08 0.4599 10 0.599 0.0431 10 0.519 0.0635 ;288"
# line type = 13.1 aa_tmp <- "1 4006 2009-06-01 17:29:33;Reg;1er cop;2069"
# line type = 13.2 aa_tmp <- "2 4006 2009-06-01 17:29:33;Reg;Output Descens_Dopamina NicotinaDescens_Dopamina Nicotina 0.08 140.481 0.0849 2.085 0.0056 0.0351 0.0014 -0.1207 0.9233  ( -0.0317 ; 0.0346 ) -0.1207  95.0 %  ( -4.7795 ; 4.538 )  ( -4.7841 ; 4.5427 ) ;2069"
# line type = 14.1 aa_tmp <- "1 4049 2009-05-22 14:32:23;Prp;1er cop;1011"
# line type = 14.2 aa_tmp <- "1 4049 2009-05-22 14:34:29;Prp;Change to  Two populations ;1101"
# line type = 14.3 aa_tmp <- "2 4049 2009-05-22 14:34:29;Prp;Output 10 5 10 5 0.5 0.5  ( 0.1901 ; 0.8099 )  ( 0.1901 ; 0.8099 ) 95 %  0.5 0 1  ( -0.4383 ; 0.4383 ) ;1101"
# line type = 15.1 aa_tmp <- "1 4068 2009-05-26 16:21:04;Jic;1er cop;1257"
# line type = 15.2 aa_tmp <- "2 4068 2009-05-26 16:21:04;Jic;Change: classes = 3;1263"
# line type = 16.1 aa_tmp <- "1 4068 2009-05-26 16:21:39;Ji2;1er cop;1269"
# line type = 16.2 aa_tmp <- "2 4068 2009-05-26 16:21:39;Ji2;Change: columns = 3;1273"
# line type = 17   aa_tmp <- "1 4135 2009-05-29 12:11:25;Tab;java.awt.event.ItemEvent[ITEM_STATE_CHANGED,item=Variable discreta. Núm. classes = valors diferents (màx. 25),stateChange=SELECTED] on checkbox0;493"
# line type = 18   aa_tmp <- "1 4111 2010-05-25 18:13:50;But;Statmedia I;11"

####################################################################################
# decode_time_id
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

setwd(path);

####################################################
# Clean garbage and leftover files, if requested
####################################################
## And only in the case when input_path is different from output_path (to avoid deleting source data in data case)
if (start_clean_output_dir == 1 && converter_path_to_input_files != converter_path_to_output_files) {
	system(paste("rm ", converter_path_to_output_files, "*.xml", sep=""), TRUE);
	system(paste("rm ", converter_path_to_output_files, "*.txt", sep=""), TRUE);
	system(paste("rm ", converter_path_to_output_files, "*.csv", sep=""), TRUE);
}
####################################################

# #Set names and paths for dictionaries
dict_name_10 = "dictionary/statmedia_dictionary_10_cal.txt"
dict_name_11 = "dictionary/statmedia_dictionary_11_ons.txt"
dict_name_12 = "dictionary/statmedia_dictionary_12_tws.txt"
dict_name_13 = "dictionary/statmedia_dictionary_13_reg.txt"
dict_name_14 = "dictionary/statmedia_dictionary_14_prp.txt"
dict_name_15 = "dictionary/statmedia_dictionary_15_jic.txt"
dict_name_16 = "dictionary/statmedia_dictionary_16_ji2.txt"
dict_name_17 = "dictionary/statmedia_dictionary_17_tab.txt"
dict_name_18 = "dictionary/statmedia_dictionary_18_but.txt"

## conversion_file_list
conversion_file_list_name = paste(converter_path_to_output_files,Sys.Date(), format(Sys.time(), "_%H-%Mh_"),"conversion_file_list.txt", sep="")
# Get the list of files in "input" directory through a system call to "ls *" and save the result to a file on disk
system(paste("ls ",converter_path_to_input_files,"*.txt > ",conversion_file_list_name, sep=""), TRUE)
# Read the file with the list of files to be processed
conversion_file_list <- read.table(conversion_file_list_name, sep="")

# Loop to assign all files to their corresponding variables in a go
for(ii in 10:18) {
  assign(paste("dict_",ii,sep=""), read.table(get(paste("dict_name_",ii,sep="")),sep="#", row.names = NULL))
}


# Count the number of source files
number_of_source_files = length(conversion_file_list[[1]])

# remove the directory prefix from the names
  # Assign the names to a dummy variable tmp, in two columns
  # tmp <- data.frame(matrix(unlist(strsplit(as.character(conversion_file_list[[1]]),converter_path_to_input_files)), ncol=2, byrow=T))
#  # get the second column as file list, since it doesn't contain the prefixes any more
#  conversion_file_list <- tmp[2]

  # Or do it through gsub, alternatively
  conversion_file_list <- gsub(converter_path_to_input_files,"", conversion_file_list[[1]])
  conversion_file_list <- gsub(".txt","", conversion_file_list)
#  data.frame(conversion_file_list) ;
  
# Initialize variables used at the end of the script
missmatch_list <- NULL;
unknown_list <- NULL;

for(file_n in 1:number_of_source_files ) {

#filen_n <- 1 # DEBUG : for manual debugging purposes

# Start the loop

  # Assign the next filename to the conversion file name
  conversionfile0 <- conversion_file_list[file_n]

  	# When in local mode, show in the console the file number (out of max files to report on) and its name
	cat(paste("Converting file ", file_n, "/", number_of_source_files, ": ", conversionfile0, ".txt\n", sep=""),sep="");
  
  abs_conversionfile0 <- paste(converter_path_to_input_files, conversionfile0, ".txt", sep="")
  abs_xmlfile <- paste(converter_path_to_output_files, conversionfile0,".xml", sep="")

  ## First clean the source file and save a new cleaned file
  # (1) convert file from dos to unix, so that all new lines (carriage returns, CRLF) and saved in unix-macosx type (LF)
  # (2) remove blank lines 
  # (3) remove unintended semicolons in columns from variables, as well as unintended spaces at the end of sections of parameteres (" ;").

  # File 1: file with all carriage returns in unix type
  conversionfile_clean1 = paste(conversionfile0,"_clean1", sep="")
  abs_conversionfile_clean1 = paste(converter_path_to_output_files, conversionfile_clean1, ".txt", sep="")

  # File 2: file without blank lines
  conversionfile_clean2 = paste(conversionfile0,"_clean2", sep="")
  abs_conversionfile_clean2 = paste(converter_path_to_output_files, conversionfile_clean2, ".txt", sep="")
  file.create(abs_conversionfile_clean2)

  # File 3: file without unintended semicolons, and without space followed by semicolon (" ;").
  conversionfile_clean3 = paste(conversionfile0,"_clean3", sep="")
  abs_conversionfile_clean3 = paste(converter_path_to_output_files, conversionfile_clean3, ".txt", sep="")
  file.create(abs_conversionfile_clean3)

  conversionfile = conversionfile_clean3
  abs_conversionfile = abs_conversionfile_clean3

  # Define file name for logging purposes of the whole conversion process
  log_conversion = paste(converter_path_to_output_files, conversionfile0,"_log.txt",sep="");

  # (1) convert file from dos to unix, so that all new lines (carriage returns, CRLF) and saved in unix-macosx type (LF)
  # This is done by using dos2unix command, which is available at the debian package "tofrodos"
##  system(paste("dos2unix <", abs_conversionfile0, " > ", abs_conversionfile_clean1, sep=""), TRUE)

  # or with the command "fromdos", in more recent version of the software, it seems (Spring 2010)
  system(paste("fromdos <", abs_conversionfile0, " > ", abs_conversionfile_clean1, sep=""), TRUE)

  # (2) remove blank lines 
  # Count lines in source file
  nlines_file <- as.numeric(system(paste("wc -l <", abs_conversionfile_clean1), TRUE))
  # Remove all blank lines from the file and save them in file appended with _clean1 
  system(paste("sed -e /^$/d ", abs_conversionfile_clean1, " > ", abs_conversionfile_clean2, sep=""), TRUE)
  # Get number of lines from shell command for clean file 1 (without blank lines)
  nlines_file_clean <- as.numeric(system(paste("wc -l <", abs_conversionfile_clean2), TRUE))
  nlines_removed <- (nlines_file - nlines_file_clean)

  # (3) remove unintended semicolons in columns from variables, 
  # and convert tabulators into spaces
  # and non-English strings into their English equivalents
  # and without space followed by semicolon (" ;").
  # Convert all " ; " into " , " (and save to the file appended with "_clean2"). Needed for scan()
  # For readLines, the global substitution could be performed at a later stage, but not for scan()
  # and we need using scan() because sometimes there are blank lines, and readLines() stops when findnig a blank line
  # whereas scan() can keep going through the param  "blank.lines.skip = TRUE"

	# Open Connection for the file to be converted 
	con1 <- file(abs_conversionfile_clean2, "r", blocking = FALSE, encoding = "ISO-8859-15")
	# Open Connection for the output file
	con2 <- file(abs_conversionfile_clean3, "w", blocking = FALSE, encoding = "ISO-8859-1")


	# Loop to read all lines
	for (ii in 1:nlines_file_clean) { # From the second line onwards

	  # For the first line, get studentId and first row of dd_net
	  aa_tmp <- readLines(con1, 1) # Read only one line at a time
	  # Check whether it's a normal data line and if, process it
	  # Substitute the semicolon ";", if any, from the parameters variable, for a simple comma, to avoid breaking the next step
	  # note that sub does the job once, and gsub does a global substitution (substitutes all matches)
	  aa_tmp <- gsub(" ; "," , ",aa_tmp, fixed = TRUE)
	  # Substitute the tabs "	", if any, for spaces " ", from the data added by human at the ond of the file
	  aa_tmp <- gsub("\t"," ",aa_tmp)
	  # Convert all "Secció" for "Section", and similar non-English into English equivalents
	  aa_tmp <- gsub("Secció","Section",aa_tmp, fixed = TRUE)
	  aa_tmp <- gsub("discreta. Núm. classes = valors diferents (màx.","discrete. Number of classes = different values (max.",aa_tmp, fixed = TRUE)
	  aa_tmp <- gsub("Avançar","Move_forward",aa_tmp, fixed = TRUE)
	  aa_tmp <- gsub("Guardar","Save",aa_tmp, fixed = TRUE)
	  aa_tmp <- gsub("accio","action",aa_tmp, fixed = TRUE)
	  aa_tmp <- gsub("Boto","Button",aa_tmp, fixed = TRUE)
	  aa_tmp <- gsub("Formulari","Form",aa_tmp, fixed = TRUE)
	  aa_tmp <- gsub("resposta final","final answer",aa_tmp, fixed = TRUE)
	  aa_tmp <- gsub("resposta final","final answer",aa_tmp, fixed = TRUE)
	  aa_tmp <- gsub(" punts"," points",aa_tmp, fixed = TRUE)
	  aa_tmp <- gsub(" camp "," field ",aa_tmp, fixed = TRUE)
	  
	  # Convert space followed by semicolon (" ;") ,shown at then of the params section and before the last semicolon, into just the semicolon (";").
	  aa_tmp <- gsub(" ;",";",aa_tmp, fixed = TRUE)
	  
	  # Write the cleaned line
	  writeLines(aa_tmp, con = con2, sep = "\n")
	} # end of loop reading lines

  close(con1)
  close(con2)

  ## end of Cleaned source file from unintended blank lines or semicolons in columns from variables

      # Feb 2, 2009 On a second step, and if log files are not changed/splitted in different files with similar data, 
      # read line by line an apply a case function to find the type of line, and apply some specific procedure
      #  for each type of line accordingly

      # Read the input file line by line.

	# Get the number of lines from the unix command "wc -l <"
	nlines_file_clean <- as.numeric(system(paste("wc -l <", abs_conversionfile), TRUE)) -1
	  # from http://tolstoy.newcastle.edu.au/R/help/04/12/8815.html
	  # "Suppopse file.name is "massive.csv".
	  # Then paste("wc -l <", file.name) is "wc -l < massive.csv", which is a UNIX command to write the number of lines in massive.csv to stdout, and system(cmd, TRUE) executes the UNIX command and returns everything it writes to stdout as an R character vector, one element per line of output. In this case, there's one line of output, so one element. Don't forget the TRUE; without it the command's standard output is not captured, just displayed.
	  # Finally, as.numeric turns that string into a number". 

	# Open Connection for the file to be converted 
	con <- file(abs_conversionfile, "r", blocking = FALSE, encoding = "ISO-8859-1")
	      # For the first line, get studentId and first row of dd_net
	      aa_tmp <- readLines(con, 1) # Read only the first line

    ## Start writing logs to files if debug enabled
    if (debug_desc == 1) {

      # - ini: Non standard rows are not parsed right now, just written to a log_converter.txt file for logging purposes
      write.table(paste("# ", converter_r_script, " - ", Sys.Date(), format(Sys.time(), "_%H:%Mh_"), sep=""), file=log_conversion, append=FALSE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape")

      write.table(paste("# File processed: ", abs_conversionfile0 , ", originally with ", nlines_file," lines.",  sep=""), file=log_conversion, append=TRUE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape")

      write.table(paste("# Number of blank lines removed from source file: ", nlines_removed, sep=""), file=log_conversion, append=TRUE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape")

      write.table(paste("#  Lines with just a number represent valid standard data that has been processed successfully. Non standard rows, if any are not processed but written to this file for logging purposes.", sep=""), file=log_conversion, append=TRUE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape")

      write.table(paste("#  Debugging mode (including description-auto-log tags?) = ", debug_desc, sep=""), file=log_conversion, append=TRUE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape")

      #  # Write the line number for logging and debugging purposes
      #  write.table(paste("1 ", sep=""), file=log_conversion, append=TRUE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

    } # end of debug file creation

  # - end

  ## Write first line of output xml file one line at a time - ini
  # Write the initial tag for xml version and charset
  write.table("<?xml version=\"1.0\" encoding=\"UTF-8\"?>", file=abs_xmlfile,append=FALSE, row.names=F, quote = F, sep=" ", 
  dec = ".", col.names=F, qmethod="escape" )

  # Write the initial <log> tag
  write.table(paste("<!DOCTYPE log SYSTEM \"Logging_v2.dtd\">",sep=""), file=abs_xmlfile, append=TRUE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )  
  
  # Write the initial <log> tag
  write.table("<log>", file=abs_xmlfile, append=TRUE, 
  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	# Add conversion script version to description for loging purposes
	string_desc <- paste("\t<!-- Logs converted by \"", converter_r_script, "\" on ", Sys.Date(), " at ", format(Sys.time(), "%H:%Mh"), " -->", sep="")
	
	# Write it
	write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
			row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

# Check the line type of the first line, and process it


	  option = 99 # default value for when no other criteria is met ("otherwise" type of value)
	  option_minus_1 <- option # to allow identifying the very first line (whatever type) in the log (option=X && option_minus_1=99)
	  event_counter <- 1; # hard coded first value of the event_counter, regardless of the line type found in the first position
	  line_n = 1 # Re-set the line counter at the log file to start from 1

	  ## Get Student_id and year
	  # Get student id from the first line, and once you have it, apply it to the conditions to identify line types elsewhere throughout the file.
	  # Once upon a time, the student id came in the same position in the first line, but this is no loger valid... just a dream from the past:-)

	  # line types 1, 7: Student_id in 2nd position after spliting by spaces and more than 5 elements
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 5) ) { studentId <- unlist(strsplit(as.character(aa_tmp), " "))[2] }

	  # line type 3: Student_id in 2nd position after spliting by spaces and only 2 elements
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) == 2) && (unlist(strsplit(as.character(aa_tmp), " "))[1] == "Respostes")) {
		    studentId <- unlist(strsplit(as.character(aa_tmp), " "))[2]
	      }

	  # line type 2: Student_id in 3rd position after spliting by spaces and exactly 5 elements
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) == 5) && (unlist(strsplit(as.character(aa_tmp), " "))[1] == "Respostes")) {
		    studentId <- unlist(strsplit(as.character(aa_tmp), " "))[3]
			# Store year in two steps: first get the part corresponding to the date like yyyy-mm-dd 
			year_tmp_old <- unlist(strsplit(as.character(aa_tmp), " "))[4]
			# and then split yyyy-mm-dd by "-" and get the first part: yyyy
			year_tmp_old <- unlist(strsplit(as.character(year_tmp_old), "-"))[1]			
	      }

	  ## Cases to consider for the 1st line 

	  # 1 = Record number from the current session. "1ra" is the first value.
	      if ( (unlist(strsplit(as.character(aa_tmp), " "))[1] == "1ra")) { option = 1 } 

	  # 2 = 1st & 2nd values are "Respostes de"
	      if ( (unlist(strsplit(as.character(aa_tmp), " "))[1] == "Respostes") && (unlist(strsplit(as.character(aa_tmp), " "))[2] == "de")) { option = 2 } 

	  # 3 = 1st & 2nd values are "Respostes [studentId]".
	      if ( (unlist(strsplit(as.character(aa_tmp), " "))[1] == "Respostes") && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId)) { option = 3 } 

	  # 4 = 1st value is "Formulari"
	      if ( (unlist(strsplit(as.character(aa_tmp), " "))[1] == "Formulari") || (unlist(strsplit(as.character(aa_tmp), " "))[1] == "Form") ) { option = 4 } 

	  # 5 = 1st value is numeric and second is not studentId -> answers of formularis, with answer
	      if ( is.finite(as.integer(unlist(strsplit(aa_tmp, " "))[[1]])) && ( length(unlist(strsplit(as.character(aa_tmp), " "))) > 1) ) { 
		if( (unlist(strsplit(as.character(aa_tmp), " "))[2] != studentId) && ( length(unlist(strsplit(as.character(aa_tmp), " "))) < 3) ) {option = 5 } # formulari with answer
		if( (unlist(strsplit(as.character(aa_tmp), " "))[2] != studentId) && ( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) ) {option = 7 } # Respostes de formularis amb correcció (tres elements, l'últim és la nota, binària, 0 o 1)
	      }

	  # 6 = 1st value is numeric and second is not studentId -> answers of formularis, but **without** answer
	      if ( is.finite(as.integer(unlist(strsplit(aa_tmp, " "))[[1]])) && ( length(unlist(strsplit(as.character(aa_tmp), " "))) < 2) ) {option = 6 } # formulari without answer

	  # 7 = Respostes de formularis de 2008, amb correcció (tres elements, l'últim és la nota, binària, 0 o 1).
	    # Defined previously in option 5

	  # 8 = 1st value is "Button"
	      if ( (unlist(strsplit(as.character(aa_tmp), " "))[1] == "Button")) { option = 8 } 

	  # 9 = 1st value is "Section". Respostes de formularis de 2009 i 2010, amb correcció
	      if ( (unlist(strsplit(as.character(aa_tmp), " "))[1] == "Section")) { option = 9 } 

	  # 10.7.0 = normal data line. studentId is the second value, and "Cal" is the text just after the first ";"
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId) &&
		    (unlist(strsplit(as.character(aa_tmp), ";"))[2] == "Cal")) { 
				option = 10;
				
				# Store year in two steps: first get the part corresponding to the date like yyyy-mm-dd 
				year_tmp_old <- unlist(strsplit(as.character(aa_tmp), " "))[3]
				# and then split yyyy-mm-dd by "-" and get the first part: yyyy
				year_tmp_old <- unlist(strsplit(as.character(year_tmp_old), "-"))[1]			

			}

	  # 11.7.2 = normal data line. studentId is the second value, and "Ons" is the text just after the first ";"
#	       if ( length(grep("Output", unlist(strsplit(as.character(aa_tmp), ";"))[3])) > 0 ) { option = 10.7.1+ } 
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId) &&
		     (unlist(strsplit(as.character(aa_tmp), ";"))[2] == "Ons")) { option = 11 }

	  # 12 = normal data line. studentId is the second value, and "Tws" is the text just after the first ";"
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId) &&
		     (unlist(strsplit(as.character(aa_tmp), ";"))[2] == "Tws")) { option = 12 }

	  # 13 = normal data line. studentId is the second value, and "Reg" is the text just after the first ";"
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId) &&
		     (unlist(strsplit(as.character(aa_tmp), ";"))[2] == "Reg")) { option = 13 }

	  # 14 = normal data line. studentId is the second value, and "Prp" is the text just after the first ";"
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId) &&
		     (unlist(strsplit(as.character(aa_tmp), ";"))[2] == "Prp")) { option = 14 }

	  # 15 = normal data line. studentId is the second value, and "Jic" is the text just after the first ";"
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId) &&
		     (unlist(strsplit(as.character(aa_tmp), ";"))[2] == "Jic")) { option = 15 }

	  # 16 = normal data line. studentId is the second value, and "Ji2" is the text just after the first ";"
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId) &&
		     (unlist(strsplit(as.character(aa_tmp), ";"))[2] == "Ji2")) { option = 16 }

	  # 17 = normal data line. studentId is the second value, and "Tab" is the text just after the first ";"
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId) &&
		     (unlist(strsplit(as.character(aa_tmp), ";"))[2] == "Tab")) { option = 17 }
	 
	  # 18 = normal data line. studentId is the second value, and "But" is the text just after the first ";"
		  # line type = 18   <- "1 4111 2010-05-25 18:13:50;But;Statmedia I;11"
		  if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId) &&
			 (unlist(strsplit(as.character(aa_tmp), ";"))[2] == "But")) { option = 18 }
	 
	  # 99 = default value, when no previous criteria are met


  switch (EXPR=option, 
    ## option = 1 -> Record number from the current session. "1ra" is the first value
    {
    },

    ## option = 2 -> Process line where 1st & 2nd values are "Respostes de"
    { 
	# identify studentId
	studentId <- unlist(strsplit(as.character(aa_tmp), " "))[3]

      # Split the vector by spaces
      bb_tmp <- unlist(strsplit(as.character(aa_tmp), " ", fixed = TRUE, perl = FALSE))
      # Convert the vector into a data.frame 
      bb_tmp <- data.frame(matrix(bb_tmp, ncol=5, byrow=T))

	  # Col titles are as follows
	  # 1 ="Respostes", 2="de", 3="userId", 4="Server_yyyy-mm-dd", 5="Server_hh:mm:ss",
	  time_id <- paste(bb_tmp[[4]],bb_tmp[[5]], sep=" ")
	  # Change date and time style so that all numbers and followed without separators (neither hyphens, colons or spaces)
	  # This is performed here using regular expression, setting the characters to search surrounded by ([]) 
	  # I.e., in this case: ([:- ])
	  time_id <- gsub("([-: ])","",time_id)
	  sessionId=time_id;
	  # Define the default event_type for this line type
	  event_type <- "active";
	  
      # Process it ...
      # Define string_event
	string_event <- paste("\t<event application=\"","Statmedia form","\" action=\"", "Save form (2)","\" user=\"", studentId ,"\" session=\"",
	  sessionId, "\" time=\"", time_id, "\" time_ms=\"0\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")

	decode_time_id(time_id)[[1]];
	
	# Write it
	write.table(paste(string_event, sep=""), file=abs_xmlfile, append=TRUE, 
	row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

# 	# Define string_param1
# 	  string_param1 <- paste("\t\t<param name=\"", bb_tmp[[1]],"_userId\" value=\'", bb_tmp[[3]], "\'/>\n", sep="")

	# Define string_param2
	    # Calculate time_respostes
# 	    time_respostes <- paste(bb_tmp[[4]],bb_tmp[[5]], sep=" ")
# 	    # Change date and time style so that all numbers and followed without separators (neither hyphens, colons or spaces)
# 	    # This is performed here using regular expression, setting the characters to search surrounded by ([]) 
# 	    # I.e., in this case: ([:- ])
# 	    time_respostes <- gsub("([-: ])","",time_respostes)
# 
# 	  string_param2 <- paste("\t\t<param name=\"", bb_tmp[[1]],"_time\" value=\"", time_respostes, "\"/>", sep="")

# 	  # Write both
# 	  write.table(paste(string_param1, string_param2, sep=""), file=abs_xmlfile, append=TRUE, 
# 	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

		# Disabled on 11/02/12
		# But re-enabled on 12/02/11
		
			# Define string description
			string_desc <- paste("\t\t<description>",	decode_time_id(time_id)[[1]]," - User \'",bb_tmp[[3]],"\' submitted the form with answers on ", decode_time_id(time_id)[[1]], "</description>", sep="")
			
			#Write desc 
			write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
					row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

			# Write ending event tag
			write.table("\t</event>", file=abs_xmlfile, append=TRUE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape"  )

      if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
	  write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	} # end of if debug_desc

    },

    ## option = 3 -> Process line where 1st & 2nd values are "Respostes [studentId]".
    { 
    },

    ## option = 4 -> Process line where 1st value is "Formulari"
    { 
    },

    ## option = 5 -> Process line where 1st value is numeric and second is not studentId -> formularis: questions with answers
    { 
  },

    ## option = 6 -> Process line where 1st value is numeric and second is not studentId -> formularis: questions without answers
    { 
    },

    ## option = 7 -> Process line where 1st value is numeric and second is not studentId, and third is the grade of the item -> questions with answers and grading, adding by human at the end of the source file
    { 
  },

    ## option = 8 -> Process line where the first value is "Button"
    {
    },

    ## option = 9 -> Process line where the first value is "Section"
    {
    },

    ## option = 10.7.0 -> Process normal data line. studentId is the second value, and "Cal" is the text just after the first ";"
    { 
	      # identify studentId
	      studentId <- unlist(strsplit(as.character(aa_tmp), " "))[2]

	      # Get the first row for dd_net
		# Split the first column in its different values separated by ";", although the result is only a single vector
		bb_tmp <- unlist(strsplit(as.character(aa_tmp), ";",  fixed = TRUE, perl = FALSE))

		  # Convert the vector into a data.frame 
		  bb_tmp <- data.frame(matrix(bb_tmp, ncol=4, byrow=T))

		# Split the first column in its different values, although the result is only a single vector
		cc_tmp <- unlist(strsplit(as.character(bb_tmp[[1]]), " ", fixed = TRUE, perl = FALSE))

		  # Convert the vector into a data.frame 
		  cc_tmp <- data.frame(matrix(cc_tmp, ncol=4, byrow=T))

		## Split the column with the action and params data (bb_tmp[[3]]) in two columns: action , and params. The result is vector
		bb_tmp2 <- unlist(strsplit(as.character(bb_tmp[[3]]), "[:=] ", perl = TRUE))

		  # Convert the vector into a data.frame 
		  bb_tmp2 <- data.frame(matrix(bb_tmp2[1:2], ncol=2, byrow=T))

		  # Join the two extra columns for action and param by columns: all 4 new columns from cc, and from the 2nd to the last in aa
		  bb_tmp <- cbind(bb_tmp, bb_tmp2)

		# Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
		dd_tmp <- cbind(cc_tmp, bb_tmp[-1])
		dd_net <- dd_tmp

	## Start writing
	  # Col titles are as follows
	  # 1="seqN", 2="userId", 3="Server_yyyy-mm-dd", 4="Server_hh:mm:ss", 5="Application", 6="Action_i_params", 7="time_ms" 
	  # 7="Action", 8="param_value"
	  time_id <- paste(dd_tmp[[3]],dd_tmp[[4]], sep=" ")
	  # Change date and time style so that all numbers and followed without separators (neither hyphens, colons or spaces)
	  # This is performed here using regular expression, setting unlist(strsplit(as.character(aa_tmp), " "))[1] == "1ra"unlist(strsplit(as.character(aa_tmp), " "))[1] == "1ra"he characters to search surrounded by ([]) 
	  # I.e., in this case: ([:- ])
	  time_id <- gsub("([-: ])","",time_id)
	  sessionId=time_id;

	    # Define the default event_type for this line type
	    event_type <- "active";

	  # Define string_event
	  string_event <- paste("\t<event application=\"",bb_tmp[[2]],"\" action=\"",unlist(strsplit(as.character(dd_tmp[[6]]),":"))[1], "\" user=\"",dd_tmp[[2]],"\" session=\"",
	    sessionId, "\" time=\"", time_id, "\" time_ms=\"", dd_tmp[[7]], "\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")

	# Define string_param
		# Rewrite some params in a different way from the action they refer to
# 		if (bb_tmp2[[1]] == as.character("Load Variable") ) {bb_tmp2[[1]] = "Variable"}
# 		if (bb_tmp2[[2]] == as.character("Distribución Normal") ) {bb_tmp2[[2]] = "Normal"}
# 		if (bb_tmp2[[1]] == as.character("Probabilistic-Change to Select Distribution") ) {bb_tmp2[[1]] = "Distribution selected"}


	string_param <- paste("\t\t<param name=\"", bb_tmp2[[1]],"\" value=\"", bb_tmp2[[2]], "\"/>", sep="")

	# Add conversion script version to description for loging purposes
	# Removed on FEb 2011 since this log line (html comment) is added beforehand always, even when the first line is type 10.
	#string_desc <- paste("\t\t<!-- Logs converted by \'", converter_r_script, "\" on ", Sys.Date(), " at ", format(Sys.time(), "%H:%Mh"), " -->", sep="")

# 	  # Defines string description
# 	  string_desc <- paste(string_desc,"\n\t\t<description>",time," - User \'",dd_tmp[[2]],"\' performed the action \'",dd_tmp[[6]],"\' </description>", sep="")

	  # Search for match of each string in vocabulary into action description of that line. If true, the index number (line number in dict.) is returned
	  # or 0 for more than 1 match, or NA for no match at all.
	  dict_match <- NA;
	  ii <- 0;
	  for(ii in 1:dim(get(paste("dict_",floor(option),sep="")))[1]) {
		    search_for <- unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[ii,1]),"[{=]"))[1];
		    search_at <- dd_tmp[[6]];
		    dict_match[[ii]] <- charmatch(search_for, search_at);
		    }
	  # Show the output in human readable format for that match in the log text match
	  text4humans <- get(paste("dict_",floor(option),sep=""))[[2]][which(dict_match == 1)]

	  # Define string description-auto
 	  string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'",dd_tmp[[2]], "\' ", text4humans, ": ",bb_tmp2[[2]],"</description>", sep="")

	  # Check if debugging mode in order to add description-auto-log or not
	  if (debug_desc == 1) {
	    string_desc <- paste(string_desc, "\n\t\t<description-auto-log>search_for = \"", unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[[1]][which(dict_match == 1)]),"[{=]"))[1], "\"; search_at = \"", search_at, "\"; dict_match = \"", which(dict_match == 1), "\"; line type=\"", option ,"\"</description-auto-log>", sep="")
	  }

   # Write Event
    write.table(paste(string_event, sep=""), file=abs_xmlfile, append=TRUE, 
    row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	# Write param
	write.table(paste(string_param, sep=""), file=abs_xmlfile, append=TRUE, 
	row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	# Write desc
	write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
	row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

# I remove it in FEb. 2011, since it seems to get duplicated when line type 10 is at the beginning.
#        write.table("\t</event>", file=abs_xmlfile, append=TRUE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape"  )

      if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
	  write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	} # end of if debug_desc

    },

    ## option = 11.7.1+ -> Process normal data line. studentId is the second value, and "Ons" is the text just after the first ";"
    { 
    },

    ## option = 12 -> Process normal data line. studentId is the second value, and "Tws" is the text just after the first ";"
    { 
    },

    ## option = 13 -> Process normal data line. studentId is the second value, and "Reg" is the text just after the first ";"
    { 
    },
    ## option = 14 -> Process normal data line. studentId is the second value, and "Prp" is the text just after the first ";"
    { 
    },
    ## option = 15 -> Process normal data line. studentId is the second value, and "Jic" is the text just after the first ";"
    { 
    },
    ## option = 16 -> Process normal data line. studentId is the second value, and "Ji2" is the text just after the first ";"
    { 
    },
    ## option = 17 -> Process normal data line. studentId is the second value, and "Tab" is the text just after the first ";"
    { 
    },
	## option = 18 -> Process normal data line. 
	{ 
	},
	
	## option = 99 -> None of the above
    { 
    }

  ) # End of swith case


  ## Write first line of output xml file one line at a time - end

  ## Clean sessionId_tmp from previous runs of this script
  sessionId_tmp <- "00";

  ## Start loop for processing from the 2nd to the last line of the source cleaned file
  for (line_n in 2:(nlines_file_clean+1)) 
    { # From the second line onwards
  #	aa_tmp <- readLines(con, 1) # Read line by line - however, ReadLines doeqsn't allow to skip blank lines. that's why I'm trying with scan() instead

  #    # Read new line
  #    aa_tmp <- scan(con, nlines = 1, what="character", blank.lines.skip = TRUE, sep=";" ) # Read line by line
      # For the first line, get studentId and first row of dd_net
      aa_tmp <- readLines(con, 1) # Read only the first line

	  option_minus_1 <- option

	  # Set default event type to active (it will be changed to reactive if "Output" is found at bb_tmp[[3]]
	  event_type <- "active";

	  option = 99 # default value for when no other criteria is met ("otherwise" type of value)

	  ## Cases to consider for the 2nd line onwards
	  # 1 = Record number from the current session. "1ra" is the first value
	      if ( (unlist(strsplit(as.character(aa_tmp), " "))[1] == "1ra")) { option = 1 } 

	  # 2 = 1st & 2nd values are "Respostes de"
	      if ( (unlist(strsplit(as.character(aa_tmp), " "))[1] == "Respostes") && (unlist(strsplit(as.character(aa_tmp), " "))[2] == "de")) { option = 2 } 

	  # 3 = 1st & 2nd values are "Respostes [studentId]".
	      if ( (unlist(strsplit(as.character(aa_tmp), " "))[1] == "Respostes") && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId)) { option = 3 } 

	  # 4 = 1st value is "Formulari"
	      if ( (unlist(strsplit(as.character(aa_tmp), " "))[1] == "Formulari") || (unlist(strsplit(as.character(aa_tmp), " "))[1] == "Form") ) { option = 4 } 

	  # 5 = 1st value is numeric and second is not studentId -> answers of formularis, with answer
	      if ( is.finite(as.integer(unlist(strsplit(aa_tmp, " "))[[1]])) && ( length(unlist(strsplit(as.character(aa_tmp), " "))) > 1) ) { 
		if( (unlist(strsplit(as.character(aa_tmp), " "))[2] != studentId) && ( length(unlist(strsplit(as.character(aa_tmp), " "))) < 3) ) {option = 5 } # formulari with answer
		if( (unlist(strsplit(as.character(aa_tmp), " "))[2] != studentId) && ( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) ) {option = 7 } # Respostes de formularis amb correcció (tres elements, l'últim és la nota, binària, 0 o 1)
	      }

	  # 6 = 1st value is numeric and second is not studentId -> answers of formularis, but **without** answer
	      if ( is.finite(as.integer(unlist(strsplit(aa_tmp, " "))[[1]])) && ( length(unlist(strsplit(as.character(aa_tmp), " "))) < 2) ) {option = 6 } # formulari without answer		  ;

	  # 7 = Respostes de formularis amb correcció (tres elements, l'últim és la nota, binària, 0 o 1)
	    # Defined previously in option 5

	  # 8 = Process line where the first value is "Button"
	      if ( (unlist(strsplit(as.character(aa_tmp), " "))[1] == "Button")) { option = 8 } 

	  # 9 = Process line where the first value is "Section"
	      if ( (unlist(strsplit(as.character(aa_tmp), " "))[1] == "Section")) { option = 9 } 

	  # 10.7.0 = normal data line. studentId is the second value, and "Cal" is the text just after the first ";"
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId) &&
		     (unlist(strsplit(as.character(aa_tmp), ";"))[2] == "Cal")) { option = 10 }

	  # 11.7.1 = normal data line. studentId is the second value, and "Ons" is the text just after the first ";"
#	       if ( length(grep("Output", unlist(strsplit(as.character(aa_tmp), ";"))[3])) > 0 ) { option = 10.7.1+ } 
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId) &&
		     (unlist(strsplit(as.character(aa_tmp), ";"))[2] == "Ons")) { option = 11 }

	  # 12 = normal data line. studentId is the second value, and "Tws" is the text just after the first ";"
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId) &&
		     (unlist(strsplit(as.character(aa_tmp), ";"))[2] == "Tws")) { option = 12 }

	  # 13 = normal data line. studentId is the second value, and "Reg" is the text just after the first ";"
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId) &&
		     (unlist(strsplit(as.character(aa_tmp), ";"))[2] == "Reg")) { option = 13 }

	  # 14 = normal data line. studentId is the second value, and "Prp" is the text just after the first ";"
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId) &&
		     (unlist(strsplit(as.character(aa_tmp), ";"))[2] == "Prp")) { option = 14 }

	  # 15 = normal data line. studentId is the second value, and "Jic" is the text just after the first ";"
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId) &&
		     (unlist(strsplit(as.character(aa_tmp), ";"))[2] == "Jic")) { option = 15 }

	  # 16 = normal data line. studentId is the second value, and "Ji2" is the text just after the first ";"
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId) &&
		     (unlist(strsplit(as.character(aa_tmp), ";"))[2] == "Ji2")) { option = 16 }

	  # 17 = normal data line. studentId is the second value, and "Tab" is the text just after the first ";"
	      if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId) &&
		     (unlist(strsplit(as.character(aa_tmp), ";"))[2] == "Tab")) { option = 17 }
	 
	 # 18 = normal data line. studentId is the second value, and "But" is the text just after the first ";"
	 	# line type = 18   <- "1 4111 2010-05-25 18:13:50;But;Statmedia I;11"
	 	if (( length(unlist(strsplit(as.character(aa_tmp), " "))) > 2) && (unlist(strsplit(as.character(aa_tmp), " "))[2] == studentId) &&
			 (unlist(strsplit(as.character(aa_tmp), ";"))[2] == "But")) { option = 18 }
	 
	 
	  # 99 = default value, when no previous criteria are met

	  # Write the ending </event> tag where applicable
	  # If previous line types are option 1, 3, 4, 5, 6, 7, 9, 10, 11 ... 18, write the ending </event> tag
	  if ( (floor(option_minus_1) >= 10 && floor(option_minus_1) <= 18)  || option_minus_1 == 9 || option_minus_1 == 7  || option_minus_1 == 6    || option_minus_1 == 5  || option_minus_1 == 4  || option_minus_1 == 3) {	
	      # Write the final </event> tag
	      write.table("\t</event>", file=abs_xmlfile, append=TRUE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape"  )
	  } 

	  # If this line is not 5 or 6 or 7 or 8, and previous line is 5 or 7 or 8, write the ending </event> tag
	  if (( option != 5 && option != 6 && option != 7 && option != 8 ) && (option_minus_1 == 8) ) {	
	      # Write the final </event> tag
	      write.table("\t</event>", file=abs_xmlfile, append=TRUE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape"  )
	  } 

	  # add ending </event> tag if (option 1 or option 4 or option 5 or option 6) and minus 1 =2, or the first line: option 2 and minus 1 =99
	  if ( (( option == 1 || option == 4  || option == 5  || option == 6 ) && (option_minus_1 == 2 ) && ( line_n > 2 )) || (( option == 2 ) && (option_minus_1 == 99 ))  ) {	
	      # Write the final </event> tag
	      write.table("\t</event>", file=abs_xmlfile, append=TRUE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape"  )
	  } 

#	  #Feb 28th, 2011
#	  # add ending </event> tag if option 4 and minus 1 =2
#	  if ( (option == 4) && (option_minus_1 == 2) ) {	
#		  # Write the final </event> tag
#		  write.table("\t</event>", file=abs_xmlfile, append=TRUE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape"  )
#	  } 
  switch (EXPR=option, 
    ## option = 1 -> Record number from the current session. "1ra" is the first value.
    {
      # Split the vector by spaces
      bb_tmp <- unlist(strsplit(as.character(aa_tmp), " ",  fixed = TRUE, perl = FALSE))
      # Convert the vector into a data.frame 
      bb_tmp <- data.frame(matrix(bb_tmp, ncol=8, byrow=T))

	# for testing, there might be a line type 8 before any other one that would create "string_desc_tmp", so that, just in case, create it if
	# if it not defined previously
	if (exists("sessionId_tmp") && (line_n > 2)) {
	  # Assign Session Id to the sessionId from time in the previous line type 2.
	  sessionId <- sessionId_tmp;
	}

      # Process it ...
	  # Col titles are as follows . Formulari = P1t1
	  # 1 ="1ra", 2="entrada", 3="de", 4="la", 5="sessio.", 6="Formulari", 7="=", 8="P1t1", 


# 	# Define string_param1
# 	  string_param1 <- paste("\n        <param name=\"New session\" value=\"1\"/>", sep="")

# 	# Define string_param2
# 	  string_param2 <- paste("\n        <param name=\"Form\" value=\"", bb_tmp[[8]], "\"/>", sep="")

# 	  # Write both
# 	  write.table(paste(string_param1, string_param2, sep=""), file=abs_xmlfile, append=TRUE, 
# 	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	    # Move forward one number in the event counter "event_counter"
	    event_counter <- event_counter+1;

 	  string_event <- paste("\t<event application=\"","Statmedia form","\" action=\"", "New session","\" user=\"", studentId ,"\" session=\"",
 	  sessionId, "\" time=\"", time_id, "\" time_ms=\"", "\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")

	# Define string description
	  string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'", studentId,"\' started a new session and submitted the form with answers on ", decode_time_id(time_id)[[1]], "</description>", sep="")
	  	  	  
	# Write it
	write.table(string_event, file=abs_xmlfile, append=TRUE, 
	row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	#Write desc 
	write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
			row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	# And close the event tag right now, to avoid problems later on identifying where it should be added or not
        write.table("\t</event>", file=abs_xmlfile, append=TRUE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape"  )

      if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
	  write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	} # end of if debug_desc

    },

    ## option = 2 -> Process line where 1st & 2nd values are "Respostes de"
    { 

      # Split the vector by spaces
      bb_tmp <- unlist(strsplit(as.character(aa_tmp), " ",  fixed = TRUE, perl = FALSE))
      # Convert the vector into a data.frame 
      bb_tmp <- data.frame(matrix(bb_tmp, ncol=5, byrow=T))

#	  # Keep studentID from bb_tmp[[3]] for future use in line type 9 at the test file
#	  studentId <- bb_tmp[[3]]];
#no need to re-assign it since it was assigned already beforehand	  
      # Process it ...
      # Define string_event

	  # Calculate the time  number for this event
	  time_id <- paste(bb_tmp[[4]],bb_tmp[[5]], sep=" ")
	  # Change date and time style so that all numbers and followed without separators (neither hyphens, colons or spaces)
	  # This is performed here using regular expression, setting the characters to search surrounded by ([]) 
	  # I.e., in this case: ([:- ])
	  time_id <- gsub("([-: ])","",time_id)

	  # Keep sessionId_tmp for the case when next line is type 1 (1a entrada a la sessió, etc), and then, associate it with a new SessionId
	  sessionId_tmp <- time_id;
	  
	  # Check for new year in the time stamp, as an indicator of new session for traces files for 2008, since there doesn't seem to exist any other tag
	  # or indicator of new session by any other means, as it exists in traces files for years > 2008. In such case, assign the new sessionId_tmp as sessionId
	  year_tmp <- unlist(strsplit(as.character(bb_tmp[[4]]), "-", fixed = TRUE, perl = FALSE))[1]
	  if (year_tmp != year_tmp_old) { # If change of year, create a new sessionId based upon current time data
		  sessionId <- sessionId_tmp;
	  }
	  # Assign year_tmp to year_tmp_old to keep the year for the comparison with the next line (if any) 
	  year_tmp_old <- year_tmp;

	    # Move forward one number in the event counter "event_counter"
	    event_counter <- event_counter+1;

	string_event <- paste("\t<event application=\"","Statmedia form","\" action=\"", "Save form (2b)","\" user=\"", studentId ,"\" session=\"",
	  sessionId, "\" time=\"", time_id, "\" time_ms=\"", "\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")

	# Define string description
	  string_desc <- paste("\t\t<description>",	decode_time_id(time_id)[[1]]," - User \'",bb_tmp[[3]],"\' submitted the form with answers on ", decode_time_id(time_id)[[1]], "</description>", sep="")	  
	  
# 	# Write it
	write.table(string_event, file=abs_xmlfile, append=TRUE, 
	row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	#Write desc 
	write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
		row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

# 	# Define string_param1
# 	  string_param1 <- paste("\t\t<param name=\"", bb_tmp[[1]],"_userId\" value=\'", bb_tmp[[3]], "\'/>\n", sep="")

	# Define string_param2
	    # Calculate time_respostes
# 	    time_respostes <- paste(bb_tmp[[4]],bb_tmp[[5]], sep=" ")
# 	    # Change date and time style so that all numbers and followed without separators (neither hyphens, colons or spaces)
# 	    # This is performed here using regular expression, setting the characters to search surrounded by ([]) 
# 	    # I.e., in this case: ([:- ])
# 	    time_respostes <- gsub("([-: ])","",time_respostes)
# 
# 	  string_param2 <- paste("\t\t<param name=\"", bb_tmp[[1]],"_time\" value=\"", time_respostes, "\"/>", sep="")
# 
# 	  # Write both
# 	  write.table(paste(string_param1, string_param2, sep=""), file=abs_xmlfile, append=TRUE, 
# 	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )


      if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
	  write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	} # end of if debug_desc

    },

    ## option = 3 -> Process line where 1st & 2nd values are "Respostes [studentId]".
	# It seems that this line type was used only in Statmedia during 2008, but not in 2009 or 2010
    { 
      # Split the vector by spaces
      bb_tmp <- unlist(strsplit(as.character(aa_tmp), " ",  fixed = TRUE, perl = FALSE))
      # Convert the vector into a data.frame 
      bb_tmp <- data.frame(matrix(bb_tmp, ncol=2, byrow=T))

      # Keep studentID in dd_tmp[[2]] for future use in line type 9 at the test file
      dd_tmp <- bb_tmp

      # Define string_event
	# XXXX Queda per separar action i params del dd_tmp[[6]]

 	    # Move forward one number in the event counter "event_counter"
 	    event_counter <- event_counter+1;
 
 	string_event <- paste("\t<event application=\"","Statmedia form","\" action=\"", "Save form (3)","\" user=\"", studentId,"\" session=\"",
 	  sessionId, "\" time=\"", time_id, "\" time_ms=\"", "\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")

	# Define string description
	string_desc <- paste("\t\t<description>",	decode_time_id(time_id)[[1]]," - User \'",bb_tmp[[2]],"\' submitted the form with answers on ", decode_time_id(time_id)[[1]], "</description>", sep="")
	
	# 	# Write it
	write.table(string_event, file=abs_xmlfile, append=TRUE, 
			row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	#Write desc 
	write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
			row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	
# 	  # Write it
# 	  write.table(paste(string_param1, sep=""), file=abs_xmlfile, append=TRUE, 
# 	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

      if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
	  write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	} # end of if debug_desc

    },

    ## option = 4 -> Process line where 1st value is "Formulari" or "Form"
    { 
      # Split the vector by spaces
      bb_tmp <- unlist(strsplit(as.character(aa_tmp), " ",  fixed = TRUE, perl = FALSE))
      # Convert the vector into a data.frame 
      bb_tmp <- data.frame(matrix(bb_tmp, ncol=3, byrow=T))

#Fixed on Feb 28th, 2011. to avoid having only start event tag in 2008, but also on 2009 or 2010.	  
#		# Patch for traces files from 2008
#		# If 2nd line is line type 4, first line is line type 2, add a start event tag
#		# TODO Shouldn't this be added always (start event tag for line type4, years 2009 and 2010), since converter_09.531.r where all line types generate an event tag?
#		if (line_n == 2 && option_minus_1 == 2) {

			# Move forward one number in the event counter "event_counter"
			event_counter <- event_counter+1;
			# Define the default event_type for this line type
			event_type <- "reactive"; # since it's extra information provided by the application
			
			string_event <- paste("\t<event application=\"","Statmedia form","\" action=\"", "Save form (4)","\" user=\"", studentId ,"\" session=\"",
					sessionId, "\" time=\"", time_id, "\" time_ms=\"", "\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")

#				# Define string desc
#				string_desc <- paste("\t\t<description>",	decode_time_id(time_id)[[1]]," - User \'", studentId ,"\' submitted the form with answers on ", decode_time_id(time_id)[[1]], "</description>", sep="")
							
			# 	# Write it
			write.table(string_event, file=abs_xmlfile, append=TRUE, 
					row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
			
#			# Write string desc
#			write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
#					row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
#			
#		} # disabled on Feb 28th, 2011. See above
	
	# Define string_param1
	  string_param1 <- paste("\t\t<param name=\"", bb_tmp[[1]],"\" value=\"", bb_tmp[[3]], "\"/>", sep="")

	unlist(strsplit(as.character(aa_tmp), " "))[1]
	  # Write it
	  write.table(paste(string_param1, sep=""), file=abs_xmlfile, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	# 8 Feb 2011
	# Defines string description
	string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]], " - User \'", studentId,"\' selected \'",  bb_tmp[[1]],"\' number \'",  bb_tmp[[3]],"\'</description>", sep="")
	# Write it
	write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
			row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

      if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
	  write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	} # end of if debug_desc

    },

    ## option = 5 -> Process line where 1st value is numeric and second is not studentId -> formularis: questions with answers
    { 
      # Split the vector by spaces
      bb_tmp <- unlist(strsplit(as.character(aa_tmp), " ",  fixed = TRUE, perl = FALSE))
      # Convert the vector into a data.frame 
      bb_tmp <- data.frame(matrix(bb_tmp, ncol=2, byrow=T))

	  # Move forward one number in the event counter "event_counter"
	  event_counter <- event_counter+1;
	  # Define the default event_type for this line type
	  event_type <- "active"; 
	  
	  string_event <- paste("\t<event application=\"","Statmedia form","\" action=\"", "Save form (5)","\" user=\"",studentId,"\" session=\"", sessionId, "\" time=\"", time_id, "\" time_ms=\"\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")
	  
	  # Write it
	  write.table(paste(string_event, sep=""), file=abs_xmlfile, append=TRUE, 
			  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	  
	# 8 Feb 2011
	# Define string_param1
	string_param1 <- paste("\t\t<param name=\"question\" value=\"", bb_tmp[[1]], "\"/>", sep="")
	# Write it
	write.table(paste(string_param1, sep=""), file=abs_xmlfile, append=TRUE, 
			row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	
	# Define string_param2
	string_param2 <- paste("\t\t<param name=\"answer\" value=\"", bb_tmp[[2]], "\"/>", sep="")
	# Write it
	write.table(paste(string_param2, sep=""), file=abs_xmlfile, append=TRUE, 
			row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
		
	# Defines string description
	string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]], " - User \'", studentId,"\' answered question \'",  bb_tmp[[1]],"\' with answer \'",  bb_tmp[[2]],"\'</description>", sep="")
	# Write it
	write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
			row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	
# 8 Feb 2011
#	# Saves string description in a string_desc_tmp for later saving in a file, when student pressed on save answers.
#	string_desc_tmp <- paste(string_desc_tmp , "\n\t\t\tUser replied to question \'", bb_tmp[[1]],"\' with answer \'", bb_tmp[[2]], "\'", sep="")

      if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
	  write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	} # end of if debug_desc

  },

    ## option = 6 -> Process line where 1st value is numeric and second is not studentId -> formularis: questions without answers
    { 
				# aa_tmp <- "1 ";
				# Split the vector by spaces
				bb_tmp <- unlist(strsplit(as.character(aa_tmp), " ",  fixed = TRUE, perl = FALSE))
		## Convert the vector into a data.frame 
		#bb_tmp <- data.frame(matrix(bb_tmp, ncol=3, byrow=T))
		
		# Move forward one number in the event counter "event_counter"
		event_counter <- event_counter+1;
		# Define the default event_type for this line type
		event_type <- "reactive"; # since it's extra information provided by the application
		
		string_event <- paste("\t<event application=\"","Statmedia form","\" action=\"", "Save form (6)","\" user=\"",studentId,"\" session=\"", sessionId, "\" time=\"", time_id, "\" time_ms=\"\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")
		
		# Write it
		write.table(paste(string_event, sep=""), file=abs_xmlfile, append=TRUE, 
				row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
		
		
		
		# Define string_param1
		string_param1 <- paste("\t\t<param name=\"question\" value=\"", bb_tmp[[1]], "\"/>", sep="")
		# Write it
		write.table(paste(string_param1, sep=""), file=abs_xmlfile, append=TRUE, 
				row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
		
		# Define string_param2
		string_param2 <- paste("\t\t<param name=\"answer\" value=\"\"/>", sep="")
		# Write it
		write.table(paste(string_param2, sep=""), file=abs_xmlfile, append=TRUE, 
				row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
				
		# Defines string description
		string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]], " - User \'", studentId,"\' answered question \'",  bb_tmp[[1]],"\' with answer \'\'</description>", sep="")
		# Write it
		write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
				row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
		
		if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
			write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
					row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
		} # end of if debug_desc

    },

    ## option = 7 -> Process line where 1st value is numeric and second is not studentId, and third is the grade of the item -> questions with answers and grading, adding by human at the end of the source file
    { 
      # aa_tmp <- "3 0.596 1,00";
	  # Split the vector by spaces
      bb_tmp <- unlist(strsplit(as.character(aa_tmp), " ",  fixed = TRUE, perl = FALSE))
      # Convert the vector into a data.frame 
      bb_tmp <- data.frame(matrix(bb_tmp, ncol=3, byrow=T))

	  # Move forward one number in the event counter "event_counter"
	  event_counter <- event_counter+1;
	  # Define the default event_type for this line type
	  event_type <- "active"; # since it's extra information provided by the application
	  
	  string_event <- paste("\t<event application=\"Grader\" action=\"Grade\" user=\"",studentId,"\" session=\"", sessionId, "\" time=\"", time_id, "\" time_ms=\"\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")
	  
	  # Write it
	  write.table(paste(string_event, sep=""), file=abs_xmlfile, append=TRUE, 
			  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	  
	  
	  
	  # Define string_param1
	  string_param1 <- paste("\t\t<param name=\"question\" value=\"", bb_tmp[[1]], "\"/>", sep="")
	  # Write it
	  write.table(paste(string_param1, sep=""), file=abs_xmlfile, append=TRUE, 
			  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	  
	  # Define string_param2
	  string_param2 <- paste("\t\t<param name=\"answer\" value=\"", bb_tmp[[2]], "\"/>", sep="")
	  # Write it
	  write.table(paste(string_param2, sep=""), file=abs_xmlfile, append=TRUE, 
			  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	  
	  # Define string_param3
	  string_param3 <- paste("\t\t<param name=\"points\" value=\"", bb_tmp[[3]], "\"/>", sep="")
	  # Write it
	  write.table(paste(string_param3, sep=""), file=abs_xmlfile, append=TRUE, 
			  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	  	  
	  # Defines string description
	  string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]], " - User \'", studentId,"\' answered question \'",  bb_tmp[[1]],"\' with answer \'", bb_tmp[[2]], "\' obtaining \'", bb_tmp[[3]],"\' points for this answer</description>", sep="")
	  # Write it
	  write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
			  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	  
	  if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
		  write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
				  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	  } # end of if debug_desc
	  
 },


    ## option = 8 -> Process line where the first value is "Button"
    { 
      # Split the vector by spaces
      bb_tmp <- unlist(strsplit(as.character(aa_tmp), " ",  fixed = TRUE, perl = FALSE))
      # Convert the vector into a data.frame 
      bb_tmp <- data.frame(matrix(bb_tmp, ncol=4, byrow=T))

	  # Move forward one number in the event counter "event_counter"
	  event_counter <- event_counter+1;
	  # Define the default event_type for this line type
	  event_type <- "active"; 
	  
	  string_event <- paste("\t<event application=\"","Statmedia form","\" action=\"", "Save form (8)","\" user=\"",studentId,"\" session=\"", sessionId, "\" time=\"", time_id, "\" time_ms=\"\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")

	  # Write it
	  write.table(paste(string_event, sep=""), file=abs_xmlfile, append=TRUE, 
			  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	  
	# Define string_param1
	  string_param1 <- paste("\t\t<param name=\"", bb_tmp[[2]],"\" value=\"", bb_tmp[[4]], "\"/>", sep="")

	  # Write it
	  write.table(paste(string_param1, sep=""), file=abs_xmlfile, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

#Commented out on Feb 28th, 2011, to fix all description tags in all line (no more string_desc_tmp to avoid rare cases)
#	# for testing, there might be a line type 8 before any other one that would create "string_desc_tmp", so that, just in case, create it if
#	# if it not defined previously
#	if (!exists("string_desc_temp")) {string_desc_temp<-""}
#
#	# Defines string description
#	string_desc_temp <- paste(string_desc_temp, "\n\t\t\tUser pressed on \"", bb_tmp[[4]], "\"", sep="")
#
#	# First of all, close the last description tag from line types 5, 6, 7 & 8.
#	string_desc_tmp <- paste(string_desc_tmp , "\n\t\t</description>", sep="")
#	# Write it
#	write.table(paste(string_desc_tmp, sep=""), file=abs_xmlfile, append=TRUE, 
#	row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

		# Define string description
		string_desc <- paste("\t\t<description>",	decode_time_id(time_id)[[1]]," - User \'", studentId ,"\' pressed on \"", bb_tmp[[4]], "\"", "</description>", sep="")
		
		#Write desc 
		write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
				row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )


	  if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
	    write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
	    row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
		} # end of if debug_desc

    },

    ## option = 9 -> Process line where the first value is "Section":  section number, field number, answer, and grade points. 
    { 
      # Split the vector by spaces
      bb_tmp <- unlist(strsplit(as.character(aa_tmp), " ",  fixed = TRUE, perl = FALSE))
      # Convert the vector into a data.frame 
      bb_tmp <- data.frame(matrix(bb_tmp, ncol=11, byrow=T))

	    # Move forward one number in the event counter "event_counter"
	    event_counter <- event_counter+1;
		# Define the default event_type for this line type
		event_type <- "reactive"; # since it's extra information provided by the application

	  string_event <- paste("\t<event application=\"Grader\" action=\"Grade\" user=\"",studentId,"\" session=\"", sessionId, "\" time=\"", time_id, "\" time_ms=\"\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")
		
	  # Write it
	  write.table(paste(string_event, sep=""), file=abs_xmlfile, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )



	# Define string_param1
	  string_param1 <- paste("\t\t<param name=\"", bb_tmp[[1]],"\" value=\"", bb_tmp[[2]], "\"/>", sep="")
	  # Write it
	  write.table(paste(string_param1, sep=""), file=abs_xmlfile, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	# Define string_param2
	  string_param2 <- paste("\t\t<param name=\"", bb_tmp[[3]],"\" value=\"", bb_tmp[[4]], "\"/>", sep="")
	  # Write it
	  write.table(paste(string_param2, sep=""), file=abs_xmlfile, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	# Define string_param3
	  string_param3 <- paste("\t\t<param name=\"", bb_tmp[[5]]," ",bb_tmp[[6]],"\" value=\"", bb_tmp[[8]], "\"/>", sep="")
	  # Write it
	  write.table(paste(string_param3, sep=""), file=abs_xmlfile, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	# Define string_param4
	  string_param4 <- paste("\t\t<param name=\"", bb_tmp[[9]],"\" value=\"", bb_tmp[[11]], "\"/>", sep="")
	  # Write it
	  write.table(paste(string_param4, sep=""), file=abs_xmlfile, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	# Defines string description
	  string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]], " - User \'", studentId,"\' answered field \'",  bb_tmp[[4]],"\' in form \'",bb_tmp[[2]],"\' with the value \'", bb_tmp[[8]], "\', obtaining \'", bb_tmp[[11]],"\' points for this answer</description>", sep="")
	  # Write it
	  write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

      if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
	    write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
	    row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	} # end of if debug_desc

    },

   ## option = 10.x.0 -> Process normal data line. studentId is the second value, and "Cal" is the text just after the first ";"
    { 
      # line type = 10.1 <- "9 4009 2008-05-19 12:27:04;Cal;Select variables - Variable 1: Grup_B;973"
      # line type = 10.2 <- "29 4009 2008-05-30 10:21:31;Cal;Probabilistic-Output: f(x) = 0.39894 F(x) = 0.5 x = 1.64485 E(X) =0 Var(X)=1 1-F(x) = 0.5;2840"

      # Split the first column in its different values separated by ";", although the result is only a single vector
      bb_tmp <- unlist(strsplit(as.character(aa_tmp), ";",  fixed = TRUE, perl = FALSE))

      # Convert the vector into a data.frame 
      bb_tmp <- data.frame(matrix(bb_tmp, ncol=length(bb_tmp), byrow=T))

      # Split the first column in its different values, although the result is only a single vector
      cc_tmp <- unlist(strsplit(as.character(bb_tmp[[1]]), " ", fixed = TRUE, perl = FALSE))

      # Convert the vector into a data.frame 
      cc_tmp <- data.frame(matrix(cc_tmp, ncol=4, byrow=T))

	# Split the column with the action and params data (bb_tmp[[3]]) in two columns: action , and params. The result is vector
	if ( length(grep("Probabilistic-Output", bb_tmp[[3]])) > 0 ) {
      	      option <- as.real("10.2")
	      bb_tmp2 <- unlist(strsplit(as.character(bb_tmp[[3]]),  ": ", perl = TRUE))
	      # Still needing to split 6 params one by one from something like: 
	      # f(x) = 0.39894 F(x) = 0.5 x = 1.64485 E(X) =0 Var(X)=1 1-F(x) = 0.5
#	      unlist(strsplit(as.character("f(x) = 0.39894 F(x) = 0.5 x = 1.64485 E(X) =0 Var(X)=1 1-F(x) = 0.5"),  "[ =]", perl = TRUE))

	      bb_tmp2b <- unlist(strsplit(as.character(bb_tmp2[[2]]),  "[ =]", perl = TRUE))
	  } else {
	      if ( length(grep("Probabilistic-Change values", bb_tmp[[3]])) > 0 ) {
		    option <- as.real("10.3")
		    bb_tmp2 <- unlist(strsplit(as.character(bb_tmp[[3]]),  ":  ", perl = TRUE))
		    # Still needing to split 4 params one by one from something like: 
		    # Parameters: n (g.l.) = 10 Density Func. at: 0.0 Distrib. Func. at: 0.0 Inv. Distrib. Func.: 0.95
		} else {
		    if ( length(grep("Probabilistic-Change to", bb_tmp[[3]])) > 0 ) {
			option <- as.real("10.4")
			bb_tmp2 <- unlist(strsplit(as.character(bb_tmp[[3]]),  "[:=]", perl = TRUE))

			# Remove empty spaces in param name and value
			if (length(bb_tmp2) > 1) {  # because "Probabilistic-Change to show graph" has only onle value in bb_tmp2
			  bb_tmp2[[2]] <- gsub(" ", "", bb_tmp2[[2]])
			  if (length(bb_tmp2) > 2) { 
			    bb_tmp2[[3]] <- gsub(" ", "", bb_tmp2[[3]]) 
			  }
			}

		    } else {
			if ( length(unlist(strsplit(as.character(bb_tmp[[3]]),  "[:=]", perl = TRUE))) == 1 ) {
			    option <- as.real("10.5")
			  bb_tmp2 <- as.character(bb_tmp[[3]])
			} else {
			    if (  length(grep("Edit Data", bb_tmp[[3]])) > 0 ) {
				option <- as.real("10.6")
				bb_tmp2 <- unlist(strsplit(as.character(bb_tmp[[3]]),  ": ", perl = TRUE))

				bb_tmp2b <- unlist(strsplit(as.character(bb_tmp2[[2]]),  "[ =]", perl = TRUE))

			    } else {
				# In case there are other options not covered before
				option <- as.real("10.1")
				bb_tmp2 <- unlist(strsplit(as.character(bb_tmp[[3]]),  "[:=] ", perl = TRUE))
			    }
			}
		    }
		}
	  }

	  # If a vector of several data, convert it into a data.frame of as many columns as needed
	  if ( length(bb_tmp2) < 2 ) {
		bb_tmp2 <- matrix(bb_tmp2[1:length(bb_tmp2)], ncol=length(bb_tmp2), byrow=T)[[1]]
	      } else {
		bb_tmp2 <- data.frame(matrix(bb_tmp2[1:length(bb_tmp2)], ncol=length(bb_tmp2), byrow=T)) 
	      }
	  # Join the two extra columns for action and param by columns: all 4 new columns from cc, and from the 2nd to the last in aa
	  bb_tmp3 <- cbind(bb_tmp, bb_tmp2)


      # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
      dd_tmp <- cbind(cc_tmp, bb_tmp3[-1])


    
      # Write the next line of the output xml file
      # --------------------------------------------------- <- ini
      # Col titles are as follows
      # 1="seqN", 2="userId", 3="Server_yyyy-mm-dd", 4="Server_hh:mm:ss", 5="Application", 6="Action_i_params", 7="time_ms" 
      # 7="Action", 8="param_value"

      # Calculate the time  number for this event
      time_id <- paste(cc_tmp[[3]],cc_tmp[[4]], sep=" ")
      # Change date and time style so that all numbers and followed without separators (neither hyphens, colons or spaces)
      # This is performed here using regular expression, setting the characters to search surrounded by ([]) 
      # I.e., in this case: ([:- ])
      time_id <- gsub("([-: ])","",time_id)

	  # Define string_event
	  # XXXX Queda per separar action i params del dd_tmp[[6]]
	    
	    # Move forward one number in the event counter "event_counter"
	    event_counter <- event_counter+1;
	    # Define the default event_type for this line type
	    event_type <- "active";

   # Define string_event
	  string_event <- paste("\t<event application=\"",bb_tmp[[2]],"\" action=\"",unlist(strsplit(as.character(dd_tmp[[6]]),":"))[1], "\" user=\"",dd_tmp[[2]],"\" session=\"",
	    sessionId, "\" time=\"", time_id, "\" time_ms=\"",bb_tmp$X4,"\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")

	# Define string_param
		# Rewrite some params in a different way from the action they refer to
		if (bb_tmp2[[1]] == as.character("Load Variable") ) {bb_tmp2[[1]] = "Variable"}
#		if (bb_tmp2[[2]] == as.character("Distribución Normal") ) {bb_tmp2[[2]] = "Normal"}
		if ( length(bb_tmp2) > 1 && length(grep("Distribución", bb_tmp2[[2]])) > 0 ) {bb_tmp2[[2]] = "Normal"}
		if (bb_tmp2[[1]] == as.character("Probabilistic-Change to Select Distribution") ) {bb_tmp2[[1]] = "Distribution selected"}

	if ( option == as.real("10.2") ) {
	      # Use data splitted in 6 params one by one from something like: 
	      # f(x) = 0.39894 F(x) = 0.5 x = 1.64485 E(X) =0 Var(X)=1 1-F(x) = 0.5
		    string_param <- paste("\t\t<param name=\"", bb_tmp2b[[1]],"\" value=\"", bb_tmp2b[[4]], "\"/>", sep="")
		    string_param <- paste(string_param, "\n\t\t<param name=\"", bb_tmp2b[[5]],"\" value=\"", bb_tmp2b[[8]], "\"/>", sep="")
		    string_param <- paste(string_param, "\n\t\t<param name=\"", bb_tmp2b[[9]],"\" value=\"", bb_tmp2b[[12]], "\"/>", sep="")
		    string_param <- paste(string_param, "\n\t\t<param name=\"", bb_tmp2b[[13]],"\" value=\"", bb_tmp2b[[15]], "\"/>", sep="")
		    string_param <- paste(string_param, "\n\t\t<param name=\"", bb_tmp2b[[16]],"\" value=\"", bb_tmp2b[[17]], "\"/>", sep="")
		    string_param <- paste(string_param, "\n\t\t<param name=\"", bb_tmp2b[[18]],"\" value=\"", bb_tmp2b[[21]], "\"/>", sep="")

	      # Define the default event_type for this line type
	      event_type <- "reactive";

	  } else {
	      if ( option == as.real("10.6") ) {
		    # Use data splitted in params one by one from something like: 
		    # Edit Data: Variable = Variable 3 Ndata = 1
		    if ( length(bb_tmp2b) >8 ) {
				string_param <- paste("\t\t<param name=\"", bb_tmp2b[[1]],"\" value=\"", bb_tmp2b[[4]], " ", bb_tmp2b[[5]], "\"/>", sep="")
				string_param <- paste(string_param, "\n\t\t<param name=\"", bb_tmp2b[[6]],"\" value=\"", bb_tmp2b[[9]], "\"/>", sep="")
		    } else {
				string_param <- paste("\t\t<param name=\"", bb_tmp2b[[1]],"\" value=\"", bb_tmp2b[[4]], "\"/>", sep="")
				string_param <- paste(string_param, "\n\t\t<param name=\"", bb_tmp2b[[5]],"\" value=\"", bb_tmp2b[[8]], "\"/>", sep="")
		    }
		} else {
		    if ( option == as.real("10.5") ) {
		      } else {
			  if ( option == as.real("10.4") ) {
				if (length(bb_tmp2) > 1) { # Because "Probabilistic-Change to show graph" produces bb_tmp2 with just one value
				    string_param <- paste("\t\t<param name=\"", bb_tmp2[[1]],"\" value=\"", bb_tmp2[[2]], "\"/>", sep="")
				    # If there is a change in param and a new value is provided, then add it to the description
				    if (length(bb_tmp2) > 2) {
					string_param <- paste(string_param, "\n\t\t<param name=\"New_value\" value=\"", bb_tmp2[[3]], "\"/>", sep="")
				    }
				}
			  } else {
			    string_param <- paste("\t\t<param name=\"", bb_tmp2[[1]],"\" value=\"", bb_tmp2[[2]], "\"/>", sep="")
			      }
		    }
	    }
	}
# 	  # Define old string description
# 	  string_desc <- paste("\t\t<description-old>User \'",dd_tmp[[2]],"\' performed the action \'",dd_tmp[[6]],"\' </description-old>", sep="")

	  # Search for match of each string in vocabulary into action description of that line. If true, the index number (line number in dict.) is returned
	  # or 0 for more than 1 match, or NA for no match at all.
	  dict_match <- NA;
	  ii <- 0;
	  for(ii in 1:dim(get(paste("dict_",floor(option),sep="")))[1]) {
		    search_for <- unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[ii,1]),"[{=]"))[1];
		    search_at <- dd_tmp[[6]];
		    dict_match[[ii]] <- charmatch(search_for, search_at);
		    }
	  # Show the output in human readable format for that match in the log text match
	  text4humans <- get(paste("dict_",floor(option),sep=""))[[2]][which(dict_match == 1)]

	  # Define string description-auto
	  # If there is a change in param and a new value is provided, then add it to the description
 	  if (length(bb_tmp2) > 2) {
 	      string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'",dd_tmp[[2]], "\' ", text4humans, " \'",bb_tmp2[[2]], "\' to \'", bb_tmp2[[3]], "\'</description>", sep="")
 	      } else {
		  if (length(bb_tmp2) == 2) {
			  string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'",dd_tmp[[2]], "\' ", text4humans, ": ",bb_tmp2[[2]],"</description>", sep="")
		      } else {
			  string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'",dd_tmp[[2]], "\' ", text4humans, "</description>", sep="")
		      }
	      }
	  # Check if debugging mode in order to add description-auto-log or not
	  if (debug_desc == 1) {
	    string_desc <- paste(string_desc, "\n\t\t<description-auto-log>search_for = \"", unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[[1]][which(dict_match == 1)]),"[{=]"))[1], "\"; search_at = \"", search_at, "\"; dict_match = \"", which(dict_match == 1), "\"; line type=\"", option ,"\"</description-auto-log>", sep="")
	  }

   # Write Event
    write.table(paste(string_event, sep=""), file=abs_xmlfile, append=TRUE, 
    row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

      	if ( option == as.real("10.5") ) {
	    } else {
		# Write param
		write.table(paste(string_param, sep=""), file=abs_xmlfile, append=TRUE, 
		row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	    }

	# Write desc
	write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
	row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

      # --------------------------------------------------- < end

      if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
	    write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
	    row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	} # end of if debug_desc

  },

   ## option = 11 -> Process normal data line. studentId is the second value, and "Ons" is the text just after the first ";"
    { 

      # line type = 11.1 <- "1 4012 2009-05-31 18:15:21;Ons;1er cop;2073"
      # line type = 11.2 <- "1 4012 2009-05-31 18:19:20;Ons;Change: percentil = 0;2088"
      # line type = 11.3 <- "2 4012 2009-05-31 18:19:20;Ons;Output Descriptive = Grup_A 10 0.587 0.54 0.11 0.0291 0.59 0.65 0.0092 0.0008 0.54 ;2088"
#aa_tmp<-"2 4009 2009-05-31 18:19:20;Ons;Output Descriptive = Grup_A 10 0.587 0.54 0.11 0.0291 0.59 0.65 0.0092 0.0008 0.54 ;2088-11.3";
      # line type = 11.4 <- "1 4009 2009-05-31 18:19:54;Ons;Change to  Confidence Interval ;1187-11.4"

      # Split the first column in its different values separated by ";", although the result is only a single vector
      bb_tmp <- unlist(strsplit(as.character(aa_tmp), ";",  fixed = TRUE, perl = FALSE))

      # Convert the vector into a data.frame 
      bb_tmp <- data.frame(matrix(bb_tmp, ncol=length(bb_tmp), byrow=T))

      # Split the first column in its different values, although the result is only a single vector
      cc_tmp <- unlist(strsplit(as.character(bb_tmp[[1]]), " ", fixed = TRUE, perl = FALSE))

      # Convert the vector into a data.frame 
      cc_tmp <- data.frame(matrix(cc_tmp, ncol=4, byrow=T))

      # Get the values for the column of param name and values
#      bb_tmp2 <- unlist(strsplit(as.character(aa_tmp), ";"))[3]

	if ( length(grep("1er cop", bb_tmp[[3]])) > 0 ) {

	      option <- as.real("11.1")
	      
	  } else { 
	     if ( length(grep("Output ", bb_tmp[[3]])) > 0 ) {
		option <- as.real("11.3")
		# line type = 11.3 <- "2 4012 2009-05-31 18:19:20;Ons;Output Descriptive = Grup_A 10 0.587 0.54 0.11 0.0291 0.59 0.65 0.0092 0.0008 0.54 ;2088"
		bb_tmp2 <- unlist(strsplit(as.character(bb_tmp[[3]]),  "Output ", perl = TRUE))
		# Still needing to split params by an equal sign, from something like: 
		# "Output Descriptive = Grup_A 10 0.587 0.54 0.11 0.0291 0.59 0.65 0.0092 0.0008 0.54 "

		# Split the contents of params by the equal "=" sign
		bb_tmp3 <- unlist(strsplit(as.character(bb_tmp2), " = "))

		# Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
		dd_tmp <- cbind(cc_tmp, unlist(strsplit(as.character(aa_tmp), ";"))[2], t(bb_tmp3))
  #	      dd_tmp <- cbind(cc_tmp, bb_tmp[-1])

		# Define string_param1
		string_param1 <- paste("\t\t<param name=\"", bb_tmp3[[1]],"\" value=\"", bb_tmp3[[2]], "\"/>", sep="")

	      # Search for match of each string in vocabulary into action description of that line. If true, the index number (line number in dict.) is returned
	      # or 0 for more than 1 match, or NA for no match at all.
	      dict_match <- NA;
	      ii <- 0;
	      for(ii in 1:dim(get(paste("dict_",floor(option),sep="")))[1]) {
			search_for <- unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[ii,1]),"[{=]"))[1];
			search_at <- bb_tmp[[3]];
			dict_match[[ii]] <- charmatch(search_for, search_at);
			}
	      # Show the output in human readable format for that match in the log text match
	      text4humans <- get(paste("dict_",floor(option),sep=""))[[2]][which(dict_match == 1)]

	      # Define string description
# 	      string_desc <- paste("\t\t<description-old>Operation in the calculator - Frame of one sample, with Output ", bb_tmp3[[1]], " as: \"", bb_tmp3[[2]],"\"</description-old>", sep="")
	      string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'",dd_tmp[[2]], "\' ", text4humans, ", with the values \'", bb_tmp3[[2]],"\'</description>", sep="")

	  # Check if debugging mode in order to add description-auto-log or not
	  if (debug_desc == 1) {
	    string_desc <- paste(string_desc, "\n\t\t<description-auto-log>search_for = \"", unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[[1]][which(dict_match == 1)]),"[{=]"))[1], "\"; search_at = \"", search_at, "\"; dict_match = \"", which(dict_match == 1), "\"; line type=\"", option ,"\"</description-auto-log>", sep="")
	  }

	    } else {
		if ( length(grep("Change: ", bb_tmp[[3]])) > 0 ) {			
			  option <- as.real("11.2")
			  # line type = 11.2 <- "1 4012 2009-05-31 18:19:20;Ons;Change: percentil = 0;2088"
		      bb_tmp2 <- unlist(strsplit(as.character(bb_tmp[[3]]),  "Change: ", perl = TRUE))
		      # Still needing to split 4 params one by one from something like: 
		      # Parameters: n (g.l.) = 10 Density Func. at: 0.0 Distrib. Func. at: 0.0 Inv. Distrib. Func.: 0.95

		      # Split the contents of params by the equal "=" sign
		      bb_tmp3 <- unlist(strsplit(as.character(bb_tmp2), " = "))

		      # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
		      dd_tmp <- cbind(cc_tmp, unlist(strsplit(as.character(aa_tmp), ";"))[2], t(bb_tmp3))

  #		    # Join the two extra columns for action and param by columns: all 4 new columns from cc, and from the 2nd to the last in aa
  #		    bb_tmp3 <- cbind(bb_tmp, bb_tmp2)

		      # Define string_param1
		      string_param1 <- paste("\t\t<param name=\"", bb_tmp3[[1]],"\" value=\"", bb_tmp3[[2]], "\"/>", sep="")

		      # Search for match of each string in vocabulary into action description of that line. If true, the index number (line number in dict.) is returned
		      # or 0 for more than 1 match, or NA for no match at all.
		      dict_match <- NA;
		      ii <- 0;
		      for(ii in 1:dim(get(paste("dict_",floor(option),sep="")))[1]) {
				search_for <- unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[ii,1]),"[{=]"))[1];
				search_at <- bb_tmp[[3]];
				dict_match[[ii]] <- charmatch(search_for, search_at);
				}
		      # Show the output in human readable format for that match in the log text match
		      text4humans <- get(paste("dict_",floor(option),sep=""))[[2]][which(dict_match == 1)]

		      # Define string description
# 		      string_desc <- paste("\t\t<description-old>Operation in the calculator - Frame of one sample, with change in ", bb_tmp3[[1]], " to be \"", bb_tmp3[[2]],"\"</description-old>", sep="")
		      string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'",dd_tmp[[2]], "\' ", text4humans, ", with the new value as \'", bb_tmp3[[2]],"\'</description>", sep="")

	  # Check if debugging mode in order to add description-auto-log or not
	  if (debug_desc == 1) {
	    string_desc <- paste(string_desc, "\n\t\t<description-auto-log>search_for = \"", unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[[1]][which(dict_match == 1)]),"[{=]"))[1], "\"; search_at = \"", search_at, "\"; dict_match = \"", which(dict_match == 1), "\"; line type=\"", option ,"\"</description-auto-log>", sep="")
	  }

		  } else {
		    option <- as.real("11.4")
		    bb_tmp2 <- unlist(strsplit(as.character(bb_tmp[[3]]),  "[:=] ", perl = TRUE))

		    # Split the contents of params by the equal "=" sign
		    bb_tmp3 <- unlist(strsplit(as.character(bb_tmp2), " = "))

		    dd_tmp <- cbind(cc_tmp, bb_tmp[-1])

		    # Search for match of each string in vocabulary into action description of that line. If true, the index number (line number in dict.) is returned
		    # or 0 for more than 1 match, or NA for no match at all.
		    dict_match <- NA;
		    ii <- 0;
		    for(ii in 1:dim(get(paste("dict_",floor(option),sep="")))[1]) {
			      search_for <- unlist(as.character(get(paste("dict_",floor(option),sep=""))[ii,1]))[1];
			      search_at <- bb_tmp[[3]];
			      dict_match[[ii]] <- charmatch(search_for, search_at);
			      }
		    # Show the output in human readable format for that match in the log text match
		    text4humans <- get(paste("dict_",floor(option),sep=""))[[2]][which(dict_match == 1)]

		    # Define string description
# 		    string_desc <- paste("\t\t<description-old>Operation in the calculator - Frame of one sample, with ", bb_tmp3[[1]],"</description-old>", sep="")
		    string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'",dd_tmp[[2]], "\' ", text4humans, "</description>", sep="")

	  # Check if debugging mode in order to add description-auto-log or not
	  if (debug_desc == 1) {
	    string_desc <- paste(string_desc, "\n\t\t<description-auto-log>search_for = \"", unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[[1]][which(dict_match == 1)]),"[{=]"))[1], "\"; search_at = \"", search_at, "\"; dict_match = \"", which(dict_match == 1), "\"; line type=\"", option ,"\"</description-auto-log>", sep="")
	  }

		  }
	    }
	}

      # Write the next line of the output xml file
      # --------------------------------------------------- <- ini
      # Col titles are as follows
      # 1="seqN", 2="userId", 3="Server_yyyy-mm-dd", 4="Server_hh:mm:ss", 5="Application", 6="Action_i_params", 7="time_ms" 
      # 7="Action", 8="param_value"
      time_id <- paste(cc_tmp[[3]],cc_tmp[[4]], sep=" ")
      # Change date and time style so that all numbers and followed without separators (neither hyphens, colons or spaces)
      # This is performed here using regular expression, setting the characters to search surrounded by ([]) 
      # I.e., in this case: ([:- ])
      time_id <- gsub("([-: ])","",time_id)

      # Process it ...

	    # Move forward one number in the event counter "event_counter"
	    event_counter <- event_counter+1;

	    # Define the default event_type for this line type
	     if ( length(grep("Output", bb_tmp[[3]])) > 0 ) {
		event_type = "reactive";
	     }

#	  string_event <- paste("\t<event application=\"",bb_tmp[[2]],"\" action=\"", bb_tmp[[3]], "\" user=\"",dd_tmp[[2]],"\" session=\"",
#	    sessionId, "\" time=\"", time_id, "\" time_ms=\"",bb_tmp$X4,"\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")
	  string_event <- paste("\t<event application=\"",bb_tmp[[2]],"\" action=\"", unlist(strsplit(as.character(bb_tmp[[3]]),  " = ", perl = TRUE))[[1]], "\" user=\"",dd_tmp[[2]],"\" session=\"",
	    sessionId, "\" time=\"", time_id, "\" time_ms=\"",bb_tmp$X4,"\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")

	  # Write it
	  write.table(paste(string_event, sep=""), file=abs_xmlfile, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )


	      # Write param if needed (11.2 and 11.3)
	      if ( option == as.real("11.2") || option == as.real("11.3") ) {
		  write.table(paste(string_param1, sep=""), file=abs_xmlfile, append=TRUE, 
		  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	      }

	  #Write desc for options different than 14.1
	  if (option != as.real("11.1") ) {

	    # Write desc
	    write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
	    row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	  }

       # --------------------------------------------------- < end

      if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
	    write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
	    row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	} # end of if debug_desc

  },

   ## option = 12 -> Process normal data line. studentId is the second value, and "Tws" is the text just after the first ";"
    { 
      # line type = 12.1 <- "1 4006 2009-05-31 19:06:19;Tws;1er cop;288"
      # line type = 12.2 <- "2 4006 2009-05-31 19:06:19;Tws;Output Descriptive = Grup_A - Grup_B 10 0.08 -0.04 0.26 0.0849 0.8 0.22 0.0268 0.0072 0.08 0.4599 10 0.599 0.0431 10 0.519 0.0635 ;288"

      # Split the first column in its different values separated by ";", although the result is only a single vector
      bb_tmp <- unlist(strsplit(as.character(aa_tmp), ";",  fixed = TRUE, perl = FALSE))

      # Convert the vector into a data.frame 
      bb_tmp <- data.frame(matrix(bb_tmp, ncol=length(bb_tmp), byrow=T))

      # Split the first column in its different values, although the result is only a single vector
      cc_tmp <- unlist(strsplit(as.character(bb_tmp[[1]]), " ", fixed = TRUE, perl = FALSE))

      # Convert the vector into a data.frame 
      cc_tmp <- data.frame(matrix(cc_tmp, ncol=4, byrow=T))

      # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
      dd_tmp <- cbind(cc_tmp, bb_tmp[-1])


      # Get the values for the column of param name and values
      bb_tmp2 <- unlist(strsplit(as.character(aa_tmp), ";"))[3]

      # Look for different subtipes of content
	# 12.1. "1er cop" (2008) or "1r cop" (>2008), and no " = " in the string. And print as is.
	if ( length(grep(" = ", bb_tmp2)) == 0 && length(grep("r cop", bb_tmp2)) == 1) {
	    option <- as.real("12.1")
	    # Do nothing special. bb_tmp2 will be printed "as is" later on.

	    # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa 
	    dd_tmp <- cbind(cc_tmp, bb_tmp[-1])

	  } else {
	    if ( length(grep(" = ", bb_tmp2)) > 0 ) {
	      # 12.2. there is a param name followed by " = " 
	      option <- as.real("12.2")

	      # Convert all " y " for their " & " equivalents 
	      bb_tmp2 <- gsub(" y "," and ",bb_tmp2)

	      bb_tmp3 <- unlist(strsplit(as.character(bb_tmp2), " = "))

	    # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
	    dd_tmp <- cbind(cc_tmp, unlist(strsplit(as.character(aa_tmp), ";"))[2], t(bb_tmp3))

	    }
	  }

      # Process it ...

      # Calculate the time  number for this event
      time_id <- paste(cc_tmp[[3]],cc_tmp[[4]], sep=" ")
      # Change date and time style so that all numbers and followed without separators (neither hyphens, colons or spaces)
      # This is performed here using regular expression, setting the characters to search surrounded by ([]) 
      # I.e., in this case: ([:- ])
      time_id <- gsub("([-: ])","",time_id)

	    # Move forward one number in the event counter "event_counter"
	    event_counter <- event_counter+1;

	    # Define the default event_type for this line type
	     if ( length(grep("Output ", bb_tmp[[3]])) > 0 ) {
		event_type = "reactive";
	     }

#	    string_event <- paste("\t<event application=\"",bb_tmp[[2]],"\" action=\"", bb_tmp[[3]],"\" user=\"",dd_tmp[[2]],"\" session=\"",
#	    sessionId, "\" time=\"", time_id, "\" time_ms=\"",bb_tmp$X4,"\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")
		string_event <- paste("\t<event application=\"",bb_tmp[[2]],"\" action=\"", unlist(strsplit(as.character(bb_tmp[[3]]),  " = ", perl = TRUE))[[1]], "\" user=\"",dd_tmp[[2]],"\" session=\"",
		sessionId, "\" time=\"", time_id, "\" time_ms=\"",bb_tmp$X4,"\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")

	  # Write it
	  write.table(paste(string_event, sep=""), file=abs_xmlfile, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

# 	  # Define string description
# 	  string_desc <- paste("\t\t<description-old>Operation in the calculator - Frame of two samples, with the following results:\"", bb_tmp2[1], ifelse(length(bb_tmp2)>1,paste(" = ", bb_tmp2[2],sep=""),"") ,"\"</description-old>", sep="")

	    #If there are params (options X.2+, write them)
	    if (option == as.real("12.2")) {
		# Define string_param1
		string_param1 <- paste("\t\t<param name=\"", bb_tmp3[1],"\" value=\"", bb_tmp3[2], "\"/>", sep="")

		# Write it
		write.table(paste(string_param1, sep=""), file=abs_xmlfile, append=TRUE, 
		row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

# 		# Define string description
# 		string_desc <- paste("\t\t<description-old>Operation in the calculator - Frame of two samples, with the following results:\"", bb_tmp3[1], ifelse(length(bb_tmp2)>1,paste(" = ", bb_tmp3[2],sep=""),"") ,"\"</description-old>", sep="")

		# Search for match of each string in vocabulary into action description of that line. If true, the index number (line number in dict.) is returned
		# or 0 for more than 1 match, or NA for no match at all.
		dict_match <- NA;
		ii <- 0;
		for(ii in 1:dim(get(paste("dict_",floor(option),sep="")))[1]) {
			  search_for <- unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[ii,1]),"[{=]"))[1];
			  search_at <- bb_tmp[[3]];
			  dict_match[[ii]] <- charmatch(search_for, search_at);
			  }
		# Show the output in human readable format for that match in the log text match
		text4humans <- get(paste("dict_",floor(option),sep=""))[[2]][which(dict_match == 1)]

		string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'",dd_tmp[[2]], "\' ", text4humans, ifelse(option==as.real("12.2"),paste(": ", bb_tmp3[1], " = ", bb_tmp3[2],sep=""),""), "</description>", sep="")

	  # Check if debugging mode in order to add description-auto-log or not
	  if (debug_desc == 1) {
	    string_desc <- paste(string_desc, "\n\t\t<description-auto-log>search_for = \"", unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[[1]][which(dict_match == 1)]),"[{=]"))[1], "\"; search_at = \"", search_at, "\"; dict_match = \"", which(dict_match == 1), "\"; line type=\"", option ,"\"</description-auto-log>", sep="")
	  }

	    }

	  #Write desc for options different than 14.1
	  if (option != as.real("12.1") ) {

	    # Write it
	    write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
	    row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	  }

      # --------------------------------------------------- < end

      if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
	    write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
	    row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	} # end of if debug_desc

  },

   ## option = 13 -> Process normal data line. studentId is the second value, and "Reg" is the text just after the first ";"
    { 
      # line type = 13.1 <- "1 4006 2009-06-01 17:29:33;Reg;1er cop;2069"
      # line type = 13.2 <- "2 4006 2009-06-01 17:29:33;Reg;Output Descens_Dopamina NicotinaDescens_Dopamina Nicotina 0.08 140.481 0.0849 2.085 0.0056 0.0351 0.0014 -0.1207 0.9233  ( -0.0317 ; 0.0346 ) -0.1207  95.0 %  ( -4.7795 ; 4.538 )  ( -4.7841 ; 4.5427 ) ;2069"

      # Split the first column in its different values separated by ";", although the result is only a single vector
      bb_tmp <- unlist(strsplit(as.character(aa_tmp), ";",  fixed = TRUE, perl = FALSE))

      # Convert the vector into a data.frame 
      bb_tmp <- data.frame(matrix(bb_tmp, ncol=length(bb_tmp), byrow=T))

      # Split the first column in its different values, although the result is only a single vector
      cc_tmp <- unlist(strsplit(as.character(bb_tmp[[1]]), " ", fixed = TRUE, perl = FALSE))

      # Convert the vector into a data.frame 
      cc_tmp <- data.frame(matrix(cc_tmp, ncol=4, byrow=T))

      # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
      dd_tmp <- cbind(cc_tmp, bb_tmp[-1])


      # Get the values for the column of param name and values
      bb_tmp2 <- unlist(strsplit(as.character(aa_tmp), ";"))[3]
      # Look for different subtipes of content

	  # Search for match of each string in vocabulary into action description of that line. If true, the index number (line number in dict.) is returned
	  # or 0 for more than 1 match, or NA for no match at all.
	  dict_match <- NA;
	  ii <- 0;
	  for(ii in 1:dim(get(paste("dict_",floor(option),sep="")))[1]) {
		    search_for <- unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[ii,1]),"[{=]"))[1];
		    search_at <- bb_tmp[[3]];
		    dict_match[[ii]] <- charmatch(search_for, search_at);
		    }
	  # Show the output in human readable format for that match in the log text match
	  text4humans <- get(paste("dict_",floor(option),sep=""))[[2]][which(dict_match == 1)]


       # Look for different subtipes of content
	# 13.1. "1er cop" (but no " = " nor "Output" nor "Change" in the string). And print as is.
	if ( length(grep("1er cop", bb_tmp2)) > 0 ) {
	    option <- as.real("13.1")
	    # Do nothing special. bb_tmp2 will be printed "as is" later on.

	    # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa 
	    dd_tmp <- cbind(cc_tmp, bb_tmp[-1])

	  } else {
	    if ( length(grep("Output", bb_tmp2)) > 0 ) {
	      # 13.2. there is "Output " followed by several values 
	      option <- as.real("13.2")
	      bb_tmp3 <- unlist(strsplit(as.character(bb_tmp2), "Output "))

	    # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
	    dd_tmp <- cbind(cc_tmp, unlist(strsplit(as.character(aa_tmp), ";"))[2], t(bb_tmp3[2]))

		# Define string_param1
		string_param1 <- paste("\t\t<param name=\"Output\" value=\"", bb_tmp3[2], "\"/>", sep="")

	    # Define string description
# 	    string_desc <- paste("\t\t<description-old>Operation in the calculator - Frame of regression analysis, with the regression Output as: \"", bb_tmp3[2],"\"</description-old>", sep="")
	    string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'",dd_tmp[[2]], "\' ", text4humans, ifelse(option==as.real("13.2"),paste(": ", bb_tmp3[2], sep=""),""), "</description>", sep="")

	  # Check if debugging mode in order to add description-auto-log or not
	  if (debug_desc == 1) {
	    string_desc <- paste(string_desc, "\n\t\t<description-auto-log>search_for = \"", unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[[1]][which(dict_match == 1)]),"[{=]"))[1], "\"; search_at = \"", search_at, "\"; dict_match = \"", which(dict_match == 1), "\"; line type=\"", option ,"\"</description-auto-log>", sep="")
	  }

		} else {
		  if ( length(grep("Change:", bb_tmp2)) > 0 ) {
		    # 13.3. there is "Change:", such as "7 4009 2008-05-30 10:54:38;Reg;Change: Predic. Value = 149;4770" 
		    option <- as.real("13.3")
		    # split this part: "Change: Predic. Value = 149" by ":" or "=" (so that, it splits in three parts in this example: 
		    #  "Change"          " Predic. Value " " 149" 
		    bb_tmp3 <- unlist(strsplit(as.character(bb_tmp2), "([:=])"))

		  # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
		  dd_tmp <- cbind(cc_tmp, unlist(strsplit(as.character(aa_tmp), ";"))[2], t(bb_tmp3) )

		# Define string_param1
		string_param1 <- paste("\t\t<param name=\"", bb_tmp3[1],"\" value=\"", bb_tmp3[3], "\"/>", sep="")


		    # Define string description for "Predic, value"
		    if ( length(grep("Predic.", bb_tmp2)) > 0 ) { 
# 			    string_desc <- paste("\t\t<description-old>Operation in the calculator - Frame of regression analysis. Change of the value for the prediction to:\"", bb_tmp2[3],"\"</description-old>", sep="")
			    string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'",dd_tmp[[2]], "\' ", text4humans, bb_tmp3[3], "</description>", sep="")

	  # Check if debugging mode in order to add description-auto-log or not
	  if (debug_desc == 1) {
	    string_desc <- paste(string_desc, "\n\t\t<description-auto-log>search_for = \"", unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[[1]][which(dict_match == 1)]),"[{=]"))[1], "\"; search_at = \"", search_at, "\"; dict_match = \"", which(dict_match == 1), "\"; line type=\"", option ,"\"</description-auto-log>", sep="")
	  }

		    }

		    # Define string description for "Confidence level"
		    if ( length(grep("confidence", bb_tmp2)) > 0 ) { 
# 			    string_desc <- paste("\t\t<description-old>Operation in the calculator - Frame of regression analysis. Change of the confidence level to:\"", bb_tmp2[3],"\"</description-old>", sep="")
			    string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'",dd_tmp[[2]], "\' ", text4humans, bb_tmp3[3], "</description>", sep="")

	  # Check if debugging mode in order to add description-auto-log or not
	  if (debug_desc == 1) {
	    string_desc <- paste(string_desc, "\n\t\t<description-auto-log>search_for = \"", unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[[1]][which(dict_match == 1)]),"[{=]"))[1], "\"; search_at = \"", search_at, "\"; dict_match = \"", which(dict_match == 1), "\"; line type=\"", option ,"\"</description-auto-log>", sep="")
	  }

		    }

		  } # end of if "Change:"

		  # Case of "Change to"...
		# 13.4. "1er cop" or "change to" (but no " = " nor "Output" nor "Change" in the string). And print as is.
		if ( length(grep("Change to", bb_tmp2)) > 0 ) {
		    option <- as.real("13.4")

		    # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa 
		    dd_tmp <- cbind(cc_tmp, bb_tmp[-1])

		    # Define string description for "Change to"
# 		    string_desc <- paste("\t\t<description-old>Operation in the calculator - Frame of regression analysis. ", bb_tmp2,"\"</description-old>", sep="")
		    string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'",dd_tmp[[2]], "\' ", text4humans, "</description>", sep="")
	  # Check if debugging mode in order to add description-auto-log or not
	  if (debug_desc == 1) {
	    string_desc <- paste(string_desc, "\n\t\t<description-auto-log>search_for = \"", unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[[1]][which(dict_match == 1)]),"[{=]"))[1], "\"; search_at = \"", search_at, "\"; dict_match = \"", which(dict_match == 1), "\"; line type=\"", option ,"\"</description-auto-log>", sep="")
	  }

		}

		}
	    }

      # Process it ...

      # Calculate the time  number for this event
      time_id <- paste(cc_tmp[[3]],cc_tmp[[4]], sep=" ")
      # Change date and time style so that all numbers and followed without separators (neither hyphens, colons or spaces)
      # This is performed here using regular expression, setting the characters to search surrounded by ([]) 
      # I.e., in this case: ([:- ])
      time_id <- gsub("([-: ])","",time_id)

	    # Move forward one number in the event counter "event_counter"
	    event_counter <- event_counter+1;

	    # Define the default event_type for this line type
	     if ( length(grep("Output ", bb_tmp[[3]])) > 0 ) {
		event_type = "reactive";
	     }

#	    string_event <- paste("\t<event application=\"",bb_tmp[[2]],"\" action=\"", bb_tmp[[3]],"\" user=\"",dd_tmp[[2]],"\" session=\"",
#	    sessionId, "\" time=\"", time_id, "\" time_ms=\"",bb_tmp$X4,"\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")
		string_event <- paste("\t<event application=\"",bb_tmp[[2]],"\" action=\"", unlist(strsplit(as.character(bb_tmp[[3]]),  " = ", perl = TRUE))[[1]], "\" user=\"",dd_tmp[[2]],"\" session=\"",
		sessionId, "\" time=\"", time_id, "\" time_ms=\"",bb_tmp$X4,"\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")

	  # Write it
	  write.table(paste(string_event, sep=""), file=abs_xmlfile, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	    #If there are params (options X.2+, write them)
	    if (option == as.real("13.2") || option == as.real("13.3") ) {

		# Write it
		write.table(paste(string_param1, sep=""), file=abs_xmlfile, append=TRUE, 
		row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	    }

	  #Write desc for options different than 14.1
	  if (option != as.real("13.1") ) {

	    # Write description
	    write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
	    row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	  }

      # --------------------------------------------------- < end

      if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
	    write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
	    row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	} # end of if debug_desc

  },

   ## option = 14 -> Process normal data line. studentId is the second value, and "Prp" is the text just after the first ";"
    { 
      # line type = 14.1 <- "1 4049 2009-05-22 14:32:23;Prp;1er cop;1011"
      # line type = 14.2 <- "2 4049 2009-05-22 14:34:29;Prp;Output 10 5 10 5 0.5 0.5  ( 0.1901 ; 0.8099 )  ( 0.1901 ; 0.8099 ) 95 %  0.5 0 1  ( -0.4383 ; 0.4383 ) ;1101"
      # line type = 14.3 <- "1 4049 2009-05-22 14:34:29;Prp;Change: string1 ={values};1101"
      # line type = 14.4 <- "1 4049 2009-05-22 14:34:29;Prp;Change to string2;1101"

      # Split the first column in its different values separated by ";", although the result is only a single vector
      bb_tmp <- unlist(strsplit(as.character(aa_tmp), ";",  fixed = TRUE, perl = FALSE))

      # Convert the vector into a data.frame 
      bb_tmp <- data.frame(matrix(bb_tmp, ncol=length(bb_tmp), byrow=T))

      # Split the first column in its different values, although the result is only a single vector
      cc_tmp <- unlist(strsplit(as.character(bb_tmp[[1]]), " ", fixed = TRUE, perl = FALSE))

      # Convert the vector into a data.frame 
      cc_tmp <- data.frame(matrix(cc_tmp, ncol=4, byrow=T))

      # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
      dd_tmp <- cbind(cc_tmp, bb_tmp[-1])


      # Get the values for the column of param name and values
      bb_tmp2 <- unlist(strsplit(as.character(aa_tmp), ";"))[3]
      # Look for different subtipes of content

	  # Search for match of each string in vocabulary into action description of that line. If true, the index number (line number in dict.) is returned
	  # or 0 for more than 1 match, or NA for no match at all.
	  dict_match <- NA;
	  ii <- 0;
	  for(ii in 1:dim(get(paste("dict_",floor(option),sep="")))[1]) {
		    search_for <- unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[ii,1]),"[{=]"))[1];
		    search_at <- bb_tmp[[3]];
		    dict_match[[ii]] <- charmatch(search_for, search_at);
		    }
	  # Show the output in human readable format for that match in the log text match
	  text4humans <- get(paste("dict_",floor(option),sep=""))[[2]][which(dict_match == 1)]

       # Look for different subtipes of content
	# 14.1. "1er cop" (but no " = " nor "Output" nor "Change" in the string). And print as is.
	if ( length(grep("1er cop", bb_tmp2)) > 0 ) {
	    option <- as.real("14.1")
	    # Do nothing special. bb_tmp2 will be printed "as is" later on.

	    # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa 
	    dd_tmp <- cbind(cc_tmp, bb_tmp[-1])

	  } else {
	    if ( length(grep("Output", bb_tmp2)) > 0 ) {
	      # 14.2. there is "Output " followed by several values 
	      option <- as.real("14.2")
	      bb_tmp3 <- unlist(strsplit(as.character(bb_tmp2), "Output "))

	    # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
	    dd_tmp <- cbind(cc_tmp, unlist(strsplit(as.character(aa_tmp), ";"))[2], t(bb_tmp3[2]))

		# Define string_param1
		string_param1 <- paste("\t\t<param name=\"Output\" value=\"", bb_tmp3[2], "\"/>", sep="")

	    # Define string description
# 	    string_desc <- paste("\t\t<description-old>Operation in the calculator - Frame of proportion analysis, with Output as: \"", bb_tmp3[2],"\"</description-old>", sep="")
	    string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'",dd_tmp[[2]], "\' ", text4humans, ifelse(option==as.real("14.2"),paste(": ", bb_tmp3[2], sep=""),""), "</description>", sep="")

	  # Check if debugging mode in order to add description-auto-log or not
	  if (debug_desc == 1) {
	    string_desc <- paste(string_desc, "\n\t\t<description-auto-log>search_for = \"", unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[[1]][which(dict_match == 1)]),"[{=]"))[1], "\"; search_at = \"", search_at, "\"; dict_match = \"", which(dict_match == 1), "\"; line type=\"", option ,"\"</description-auto-log>", sep="")
	  }


		} else {
		  if ( length(grep("Change:", bb_tmp2)) > 0 ) {
		    # 14.3. there is "Change:"
		    option <- as.real("14.3")
		    # split this part: "Change: Predic. Value = 149" by ":" or "=" (so that, it splits in three parts in this example: 
		    #  "Change"          " Predic. Value " " 149" 
		    bb_tmp3 <- unlist(strsplit(as.character(bb_tmp2), "([:=])"))

		  # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
		  dd_tmp <- cbind(cc_tmp, unlist(strsplit(as.character(aa_tmp), ";"))[2], t(bb_tmp3) )

		    # Define string description for "values"
		    if ( length(grep("values", bb_tmp2)) > 0 ) { 
# 			    string_desc <- paste("\t\t<description-old>Operation in the calculator - Frame of regression analysis. Change of the value for the prediction to:\"", bb_tmp2[3],"\"</description-old>", sep="")

			    # Define string_param1
			    string_param1 <- paste("\t\t<param name=\"Values\" value=\"", bb_tmp3[3], "\"/>", sep="")

			    string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'",dd_tmp[[2]], "\' ", text4humans, ifelse(option==as.real("14.3"),paste(": ", bb_tmp3[3],sep=""),""), "</description>", sep="")
	  # Check if debugging mode in order to add description-auto-log or not
	  if (debug_desc == 1) {
	    string_desc <- paste(string_desc, "\n\t\t<description-auto-log>search_for = \"", unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[[1]][which(dict_match == 1)]),"[{=]"))[1], "\"; search_at = \"", search_at, "\"; dict_match = \"", which(dict_match == 1), "\"; line type=\"", option ,"\"</description-auto-log>", sep="")
	  }

		    }


		  } # end of if "Change:"

		  # Case of "Change to"...
		# 14.4. "1er cop" or "change to" (but no " = " nor "Output" nor "Change" in the string). And print as is.
		if ( length(grep("Change to", bb_tmp2)) > 0 ) {
		    option <- as.real("14.4")

		    # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa 
		    dd_tmp <- cbind(cc_tmp, bb_tmp[-1])

# 		    # Define string_param1
# 		    string_param1 <- paste("\t\t<param name=\"Change to\" value=\"", bb_tmp3[2], "\"/>", sep="")

		    # Define string description for "Change to"
# 		    string_desc <- paste("\t\t<description-old>Operation in the calculator - Frame of proportion analysis. ", bb_tmp2,"\"</description-old>", sep="")
		    string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'",dd_tmp[[2]], "\' ", text4humans, "\'</description>", sep="")

	  # Check if debugging mode in order to add description-auto-log or not
	  if (debug_desc == 1) {
	    string_desc <- paste(string_desc, "\n\t\t<description-auto-log>search_for = \"", unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[[1]][which(dict_match == 1)]),"[{=]"))[1], "\"; search_at = \"", search_at, "\"; dict_match = \"", which(dict_match == 1), "\"; line type=\"", option ,"\"</description-auto-log>", sep="")
	  }

		}

		}
	    }


      # Process it ...

      # Calculate the time  number for this event
      time_id <- paste(cc_tmp[[3]],cc_tmp[[4]], sep=" ")
      # Change date and time style so that all numbers and followed without separators (neither hyphens, colons or spaces)
      # This is performed here using regular expression, setting the characters to search surrounded by ([]) 
      # I.e., in this case: ([:- ])
      time_id <- gsub("([-: ])","",time_id)

	    # Move forward one number in the event counter "event_counter"
	    event_counter <- event_counter+1;

	    # Define the default event_type for this line type
	     if ( length(grep("Output ", bb_tmp[[3]])) > 0 ) {
		event_type = "reactive";
	     }

	  string_event <- paste("\t<event application=\"",bb_tmp[[2]],"\" action=\"Proportion analysis Output\" user=\"",dd_tmp[[2]],"\" session=\"",
	    sessionId, "\" time=\"", time_id, "\" time_ms=\"",bb_tmp$X4,"\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")
		
	  # Write it
	  write.table(paste(string_event, sep=""), file=abs_xmlfile, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )


	    #If there are params (options X.2+, write them)
	    if (option == as.real("14.2") || option == as.real("14.3") ) {

		# Write it
		write.table(paste(string_param1, sep=""), file=abs_xmlfile, append=TRUE, 
		row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	    }

	  #Write desc for options different than 14.1
	  if (option != as.real("14.1") ) {

	    # Write description
	    write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
	    row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	  }

      # --------------------------------------------------- < end

      if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
	    write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
	    row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	} # end of if debug_desc

  },

   ## option = 15 -> Process normal data line. studentId is the second value, and "Jic" is the text just after the first ";"
    { 

      # line type = 15.1 <- "1 4068 2009-05-26 16:21:04;Jic;1er cop;1257"
      # line type = 15.2 <- "2 4068 2009-05-26 16:21:04;Jic;Change: classes = 3;1263"

      # Split the first column in its different values separated by ";", although the result is only a single vector
      bb_tmp <- unlist(strsplit(as.character(aa_tmp), ";",  fixed = TRUE, perl = FALSE))

      # Convert the vector into a data.frame 
      bb_tmp <- data.frame(matrix(bb_tmp, ncol=length(bb_tmp), byrow=T))

      # Split the first column in its different values, although the result is only a single vector
      cc_tmp <- unlist(strsplit(as.character(bb_tmp[[1]]), " ", fixed = TRUE, perl = FALSE))

      # Convert the vector into a data.frame 
      cc_tmp <- data.frame(matrix(cc_tmp, ncol=4, byrow=T))

      # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
      dd_tmp <- cbind(cc_tmp, bb_tmp[-1])

      # Get the values for the column of param name and values
      bb_tmp2 <- unlist(strsplit(as.character(aa_tmp), ";"))[3]

      # Look for different subtipes of content
	if ( length(grep("1er cop", bb_tmp[[3]])) > 0 ) {

	      option <- as.real("15.1")
	      
	    } else {
		if ( length(grep("Change: ", bb_tmp[[3]])) > 0 ) {
		      option <- as.real("15.2")
		      bb_tmp2 <- unlist(strsplit(as.character(bb_tmp[[3]]),  "Change: ", perl = TRUE))

		      # Split the contents of params by the equal "=" sign
		      bb_tmp3 <- unlist(strsplit(as.character(bb_tmp2), " = "))

		      # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
		      dd_tmp <- cbind(cc_tmp, unlist(strsplit(as.character(aa_tmp), ";"))[2], t(bb_tmp3))

  #		    # Join the two extra columns for action and param by columns: all 4 new columns from cc, and from the 2nd to the last in aa
  #		    bb_tmp3 <- cbind(bb_tmp, bb_tmp2)

		if ( length(bb_tmp3) < 2 ) {
			bb_tmp3 <- cbind(bb_tmp3,  "### missing ###");
		}
			
		      # Define string_param1
		      string_param1 <- paste("\t\t<param name=\"", bb_tmp3[[1]],"\" value=\"", bb_tmp3[[2]], "\"/>", sep="")

		      # Search for match of each string in vocabulary into action description of that line. If true, the index number (line number in dict.) is returned
		      # or 0 for more than 1 match, or NA for no match at all.
		      dict_match <- NA;
		      ii <- 0;
		      for(ii in 1:dim(get(paste("dict_",floor(option),sep="")))[1]) {
				search_for <- unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[ii,1]),"[{=]"))[1];
				search_at <- bb_tmp[[3]];
				dict_match[[ii]] <- charmatch(search_for, search_at);
				}
		      # Show the output in human readable format for that match in the log text match
		      text4humans <- get(paste("dict_",floor(option),sep=""))[[2]][which(dict_match == 1)]

		      # Define string description
# 		      string_desc <- paste("\t\t<description-old>Operation in the calculator - Frame of one sample, with change in ", bb_tmp3[[1]], " to be \"", bb_tmp3[[2]],"\"</description-old>", sep="")
		      string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'",dd_tmp[[2]], "\' ", text4humans, " \'", bb_tmp3[[2]],"\'</description>", sep="")
	  # Check if debugging mode in order to add description-auto-log or not
	  if (debug_desc == 1) {
	    string_desc <- paste(string_desc, "\n\t\t<description-auto-log>search_for = \"", unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[[1]][which(dict_match == 1)]),"[{=]"))[1], "\"; search_at = \"", search_at, "\"; dict_match = \"", which(dict_match == 1), "\"; line type=\"", option ,"\"</description-auto-log>", sep="")
	  }

		  }
	    } # end if "1r cop" (15.1)

      # Process it ...

      # Calculate the time  number for this event
      time_id <- paste(cc_tmp[[3]],cc_tmp[[4]], sep=" ")
      # Change date and time style so that all numbers and followed without separators (neither hyphens, colons or spaces)
      # This is performed here using regular expression, setting the characters to search surrounded by ([]) 
      # I.e., in this case: ([:- ])
      time_id <- gsub("([-: ])","",time_id)

	    # Move forward one number in the event counter "event_counter"
	    event_counter <- event_counter+1;

	    # Define the default event_type for this line type
	     if ( length(grep("Output ", bb_tmp[[3]])) > 0 ) {
		event_type = "reactive";
	     }

	  string_event <- paste("\t<event application=\"",bb_tmp[[2]],"\" action=\"Khi-square analysis\" user=\"",dd_tmp[[2]],"\" session=\"",
	    sessionId, "\" time=\"", time_id, "\" time_ms=\"",bb_tmp$X4,"\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")
		
	  # Write it
	  write.table(paste(string_event, sep=""), file=abs_xmlfile, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )


	      # Write param if needed (15.2)
	      if ( option == as.real("15.2") ) {
		  write.table(paste(string_param1, sep=""), file=abs_xmlfile, append=TRUE, 
		  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	      }

	  #Write desc for options different than 14.1
	  if (option != as.real("15.1") ) {

	    # Write desc
	    write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
	    row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	  }

      # --------------------------------------------------- < end

      if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
	    write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
	    row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	} # end of if debug_desc

  },

   ## option = 16 -> Process normal data line. studentId is the second value, and "Ji2" is the text just after the first ";"
    { 

      # line type = 16.1 <- "1 4068 2009-05-26 16:21:39;Ji2;1er cop;1269"
      # line type = 16.2 <- "2 4068 2009-05-26 16:21:39;Ji2;Change: columns = 3;1273"

      # Split the first column in its different values separated by ";", although the result is only a single vector
      bb_tmp <- unlist(strsplit(as.character(aa_tmp), ";",  fixed = TRUE, perl = FALSE))

      # Convert the vector into a data.frame 
      bb_tmp <- data.frame(matrix(bb_tmp, ncol=length(bb_tmp), byrow=T))

      # Split the first column in its different values, although the result is only a single vector
      cc_tmp <- unlist(strsplit(as.character(bb_tmp[[1]]), " ", fixed = TRUE, perl = FALSE))

      # Convert the vector into a data.frame 
      cc_tmp <- data.frame(matrix(cc_tmp, ncol=4, byrow=T))

      # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
      dd_tmp <- cbind(cc_tmp, bb_tmp[-1])

      # Get the values for the column of param name and values
      bb_tmp2 <- unlist(strsplit(as.character(aa_tmp), ";"))[3]

      # Look for different subtipes of content
	if ( length(grep("1er cop", bb_tmp[[3]])) > 0 ) {

	      option <- as.real("16.1")
	      
	    } else {
		if ( length(grep("Change: ", bb_tmp[[3]])) > 0 ) {
		      option <- as.real("16.2")
		      bb_tmp2 <- unlist(strsplit(as.character(bb_tmp[[3]]),  "Change: ", perl = TRUE))

		      # Split the contents of params by the equal "=" sign
		      bb_tmp3 <- unlist(strsplit(as.character(bb_tmp2), " = "))

		      # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
		      dd_tmp <- cbind(cc_tmp, unlist(strsplit(as.character(aa_tmp), ";"))[2], t(bb_tmp3))

  #		    # Join the two extra columns for action and param by columns: all 4 new columns from cc, and from the 2nd to the last in aa
  #		    bb_tmp3 <- cbind(bb_tmp, bb_tmp2)

		      # Define string_param1
		      string_param1 <- paste("\t\t<param name=\"", bb_tmp3[[1]],"\" value=\"", bb_tmp3[[2]], "\"/>", sep="")

		      # Search for match of each string in vocabulary into action description of that line. If true, the index number (line number in dict.) is returned
		      # or 0 for more than 1 match, or NA for no match at all.
		      dict_match <- NA;
		      ii <- 0;
		      for(ii in 1:dim(get(paste("dict_",floor(option),sep="")))[1]) {
				search_for <- unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[ii,1]),"[{=]"))[1];
				search_at <- bb_tmp[[3]];
				dict_match[[ii]] <- charmatch(search_for, search_at);
				}
		      # Show the output in human readable format for that match in the log text match
		      text4humans <- get(paste("dict_",floor(option),sep=""))[[2]][which(dict_match == 1)]

		      # Define string description
# 		      string_desc <- paste("\t\t<description-old>Operation in the calculator - Frame of one sample, with change in ", bb_tmp3[[1]], " to be \"", bb_tmp3[[2]],"\"</description-old>", sep="")
		      string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'",dd_tmp[[2]], "\' ", text4humans, " \'", bb_tmp3[[2]],"\'</description>", sep="")

	  # Check if debugging mode in order to add description-auto-log or not
	  if (debug_desc == 1) {
	    string_desc <- paste(string_desc, "\n\t\t<description-auto-log>search_for = \"", unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[[1]][which(dict_match == 1)]),"[{=]"))[1], "\"; search_at = \"", search_at, "\"; dict_match = \"", which(dict_match == 1), "\"; line type=\"", option ,"\"</description-auto-log>", sep="")
	  }

		  }
	    } # end if "1r cop" (16.1)

      # Process it ...

      # Calculate the time  number for this event
      time_id <- paste(cc_tmp[[3]],cc_tmp[[4]], sep=" ")
      # Change date and time style so that all numbers and followed without separators (neither hyphens, colons or spaces)
      # This is performed here using regular expression, setting the characters to search surrounded by ([]) 
      # I.e., in this case: ([:- ])
      time_id <- gsub("([-: ])","",time_id)

	    # Move forward one number in the event counter "event_counter"
	    event_counter <- event_counter+1;

	    # Define the default event_type for this line type
	     if ( length(grep("Output ", bb_tmp[[3]])) > 0 ) {
		event_type = "reactive";
	     }

	  string_event <- paste("\t<event application=\"",bb_tmp[[2]],"\" action=\"Contingency table analysis\" user=\"",dd_tmp[[2]],"\" session=\"",
	    sessionId, "\" time=\"", time_id, "\" time_ms=\"",bb_tmp$X4,"\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")
		
	  # Write it
	  write.table(paste(string_event, sep=""), file=abs_xmlfile, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )


	      # Write param if needed (16.2)
	      if ( option == as.real("16.2") ) {
		  write.table(paste(string_param1, sep=""), file=abs_xmlfile, append=TRUE, 
		  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	      }

	  #Write desc for options different than 16.1
	  if (option != as.real("16.1") ) {

	    # Write desc
	    write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
	    row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	  }

      # --------------------------------------------------- < end

      if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
	    write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
	    row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	} # end of if debug_desc

  },

   ## option = 17 -> Process normal data line. studentId is the second value, and "Tab" is the text just after the first ";"
    { 
      # line type = 17.1   <- "1 4009 2009-05-29 12:11:25;Tab;par scroll99;493-17.1"
      # line type = 17.2   <- "1 4009 2009-05-29 12:11:25;Tab;java.awt.event.ItemEvent[ITEM_STATE_CHANGED,item=Variable discreta. Núm. classes = valors diferents (màx. 25),stateChange=SELECTED] on checkbox0;493-17.2"

      # Split the first column in its different values separated by ";", although the result is only a single vector
      bb_tmp <- unlist(strsplit(as.character(aa_tmp), ";",  fixed = TRUE, perl = FALSE))

      # Convert the vector into a data.frame 
      bb_tmp <- data.frame(matrix(bb_tmp, ncol=length(bb_tmp), byrow=T))

      # Split the first column in its different values, although the result is only a single vector
      cc_tmp <- unlist(strsplit(as.character(bb_tmp[[1]]), " ",  fixed = TRUE, perl = FALSE))

      # Convert the vector into a data.frame 
      cc_tmp <- data.frame(matrix(cc_tmp, ncol=4, byrow=T))

      # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
      dd_tmp <- cbind(cc_tmp, bb_tmp[-1])

      # Get the values for the column of param name and values
      bb_tmp2 <- unlist(strsplit(as.character(aa_tmp), ";"))[3]

      # Look for different subtipes of content
	if ( length(grep("par scroll", bb_tmp[[3]])) > 0 ) {

	      # line type = 17.1   <- "1 4009 2009-05-29 12:11:25;Tab;par scroll99;493-17.1"
	      option <- as.real("17.1")
	      
		      bb_tmp2 <- unlist(strsplit(as.character(bb_tmp[[3]]),  "par scroll", perl = TRUE))

# 		      # Split the contents of params by the equal "=" sign
# 		      bb_tmp3 <- unlist(strsplit(as.character(bb_tmp2), " = "))
# 
# 		      # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
# 		      dd_tmp <- cbind(cc_tmp, unlist(strsplit(as.character(aa_tmp), ";"))[2], t(bb_tmp3))
# 
#   #		    # Join the two extra columns for action and param by columns: all 4 new columns from cc, and from the 2nd to the last in aa
#   #		    bb_tmp3 <- cbind(bb_tmp, bb_tmp2)

		      # Define string_param1
		      string_param1 <- paste("\t\t<param name=\"Par_scroll\" value=\"", bb_tmp2[[2]], "\"/>", sep="")

		      # Search for match of each string in vocabulary into action description of that line. If true, the index number (line number in dict.) is returned
		      # or 0 for more than 1 match, or NA for no match at all.
		      dict_match <- NA;
		      ii <- 0;
		      for(ii in 1:dim(get(paste("dict_",floor(option),sep="")))[1]) {
				search_for <- unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[ii,1]),"[{=]"))[1];
				search_at <- bb_tmp[[3]];
				dict_match[[ii]] <- charmatch(search_for, search_at);
				}
		      # Show the output in human readable format for that match in the log text match
		      text4humans <- get(paste("dict_",floor(option),sep=""))[[2]][which(dict_match == 1)]

		      # Define string description
		      string_desc <- paste("\t\t<description>User \'",dd_tmp[[2]], "\' ", text4humans, ": \'", bb_tmp2[[2]],"\'</description>", sep="")

	  # Check if debugging mode in order to add description-auto-log or not
	  if (debug_desc == 1) {
	    string_desc <- paste(string_desc, "\n\t\t<description-auto-log>search_for = \"", unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[[1]][which(dict_match == 1)]),"[{=]"))[1], "\"; search_at = \"", search_at, "\"; dict_match = \"", which(dict_match == 1), "\"; line type=\"", option ,"\"</description-auto-log>", sep="")
	  }

	    } else {
		if ( length(grep("java.awt.", bb_tmp[[3]])) > 0 ) {
		      # line type = 17.2   <- "1 4009 2009-05-29 12:11:25;Tab;java.awt.event.ItemEvent[ITEM_STATE_CHANGED,item=Variable discreta. Núm. classes = valors diferents (màx. 25),stateChange=SELECTED] on checkbox0;493-17.2"
		      option <- as.real("17.2")
		      bb_tmp2 <- unlist(strsplit(as.character(bb_tmp[[3]]),  "java.awt.event.ItemEvent[ITEM_STATE_CHANGED,item=Variable ", fixed = TRUE))

		      # Split the contents of params by the equal "=" sign
		      bb_tmp3 <- unlist(strsplit(as.character(bb_tmp2), " = "))

		      # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
		      dd_tmp <- cbind(cc_tmp, unlist(strsplit(as.character(aa_tmp), ";"))[2], t(bb_tmp3))

  #		    # Join the two extra columns for action and param by columns: all 4 new columns from cc, and from the 2nd to the last in aa
  #		    bb_tmp3 <- cbind(bb_tmp, bb_tmp2)

		      # Define string_param1
		      string_param1 <- paste("\t\t<param name=\"Variable\" value=\"", bb_tmp3[[1]], " = ", bb_tmp3[[2]], "\"/>", sep="")

		      # Search for match of each string in vocabulary into action description of that line. If true, the index number (line number in dict.) is returned
		      # or 0 for more than 1 match, or NA for no match at all.
		      dict_match <- NA;
		      ii <- 0;
		      for(ii in 1:dim(get(paste("dict_",floor(option),sep="")))[1]) {
				search_for <- unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[ii,1]),"[{=]"))[1];
				search_at <- bb_tmp[[3]];
				dict_match[[ii]] <- charmatch(search_for, search_at);
				}
		      # Show the output in human readable format for that match in the log text match
		      text4humans <- get(paste("dict_",floor(option),sep=""))[[2]][which(dict_match == 1)]

		      # Define string description
# 		      string_desc <- paste("\t\t<description-old>Operation in the calculator - Frame of one sample, with change in ", bb_tmp3[[1]], " to be \"", bb_tmp3[[2]],"\"</description-old>", sep="")
		      string_desc <- paste("\t\t<description>User \'",dd_tmp[[2]], "\' ", text4humans, ". New variable: \'", bb_tmp3[[1]], " = ", bb_tmp3[[2]],"\'</description>", sep="")

	  # Check if debugging mode in order to add description-auto-log or not
	  if (debug_desc == 1) {
	    string_desc <- paste(string_desc, "\n\t\t<description-auto-log>search_for = \"", unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[[1]][which(dict_match == 1)]),"[{=]"))[1], "\"; search_at = \"", search_at, "\"; dict_match = \"", which(dict_match == 1), "\"; line type=\"", option ,"\"</description-auto-log>", sep="")
	  }

		  } # end else (17.2)
	    } # end if 17.1

      # Process it ...

      # Calculate the time  number for this event
      time_id <- paste(cc_tmp[[3]],cc_tmp[[4]], sep=" ")
      # Change date and time style so that all numbers and followed without separators (neither hyphens, colons or spaces)
      # This is performed here using regular expression, setting the characters to search surrounded by ([]) 
      # I.e., in this case: ([:- ])
      time_id <- gsub("([-: ])","",time_id)

	    # Move forward one number in the event counter "event_counter"
	    event_counter <- event_counter+1;

	    # Define the default event_type for this line type
	     if ( length(grep("Output ", bb_tmp[[3]])) > 0 ) {
		event_type = "reactive";
	     }

	  string_event <- paste("\t<event application=\"",bb_tmp[[2]],"\" action=\"Building frequency tables\" user=\"",dd_tmp[[2]],"\" session=\"",
	    sessionId, "\" time=\"", time_id, "\" time_ms=\"",bb_tmp$X4,"\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")
		
	  # Write it
	  write.table(paste(string_event, sep=""), file=abs_xmlfile, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )


	  write.table(paste(string_param1, sep=""), file=abs_xmlfile, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

	  # Write desc
	  write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )


      # --------------------------------------------------- < end

      if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
	    write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
	    row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	} # end of if debug_desc

  },

  ############################################################################
  ## option = 18 -> Process normal data line. studentId is the second value, and "But" is the text just after the first ";"
  { 
	  
	  # line type = 18.1 <- aa_tmp <- "1 4111 2010-05-25 18:13:50;But;Statmedia I;11"
	  # line type = 18.2 <- aa_tmp  <- "1 4111 2010-05-25 18:13:50;But;Statmedia II;11"
	  
	  # Split the first column in its different values separated by ";", although the result is only a single vector
	  bb_tmp <- unlist(strsplit(as.character(aa_tmp), ";",  fixed = TRUE, perl = FALSE))
	  
	  # Convert the vector into a data.frame 
	  bb_tmp <- data.frame(matrix(bb_tmp, ncol=length(bb_tmp), byrow=T))
	  
	  # Split the first column in its different values, although the result is only a single vector
	  cc_tmp <- unlist(strsplit(as.character(bb_tmp[[1]]), " ", fixed = TRUE, perl = FALSE))
	  
	  # Convert the vector into a data.frame 
	  cc_tmp <- data.frame(matrix(cc_tmp, ncol=4, byrow=T))
	  
	  # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
	  dd_tmp <- cbind(cc_tmp, bb_tmp[-1])
	  
	  # Get the values for the column of param name and values
	  bb_tmp2 <- unlist(strsplit(as.character(aa_tmp), ";"))[3]
	  
	  # Look for different subtypes of content
	  if ( length(grep("Statmedia II", bb_tmp[[3]])) > 0 ) {
		  
		  option <- as.real("18.2")
		  
	  } else {
		  if ( length(grep("Statmedia I", bb_tmp[[3]])) > 0 ) {
			  option <- as.real("18.1")
		  }
	  }
	  
	  # In either case, 18.1 or 18.2, do the same...
	  bb_tmp2 <- unlist(strsplit(as.character(bb_tmp[[3]]),  " ", perl = TRUE))
	  
	  ## Split the contents of params by the equal "=" sign
		  #bb_tmp3 <- unlist(strsplit(as.character(bb_tmp2), " = "))
	  #In this case of line type 18.x, bb_tmp2 = bb_temp3
	  bb_tmp3 <- bb_tmp2;

	  # Join the two sets of values by columns: all 4 new columns from cc, and from the 2nd to the last in aa
	  dd_tmp <- cbind(cc_tmp, unlist(strsplit(as.character(aa_tmp), ";"))[2], t(bb_tmp3))
	  
	  #		    # Join the two extra columns for action and param by columns: all 4 new columns from cc, and from the 2nd to the last in aa
	  #		    bb_tmp3 <- cbind(bb_tmp, bb_tmp2)
	  
	  # Define string_param1
	  string_param1 <- paste("\t\t<param name=\"", bb_tmp3[[1]],"\" value=\"", bb_tmp3[[2]], "\"/>", sep="")
	  
	  # Search for match of each string in vocabulary into action description of that line. If true, the index number (line number in dict.) is returned
	  # or 0 for more than 1 match, or NA for no match at all.
	  dict_match <- NA;
	  ii <- 0;
	  for(ii in 1:dim(get(paste("dict_",floor(option),sep="")))[1]) {
		  search_for <- unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[ii,1]),"[{=]"))[1];
		  search_at <- bb_tmp[[3]];
		  dict_match[[ii]] <- charmatch(search_for, search_at);
	  }
	  # Show the output in human readable format for that match in the log text match
	  text4humans <- get(paste("dict_",floor(option),sep=""))[[2]][which(dict_match == 1)]
	  
	  # Define string description
	  string_desc <- paste("\t\t<description>", decode_time_id(time_id)[[1]]," - User \'",dd_tmp[[2]], "\' ", text4humans, " \'", bb_tmp3[[2]],"\'</description>", sep="")
	  
	  # Check if debugging mode in order to add description-auto-log or not
	  if (debug_desc == 1) {
		  string_desc <- paste(string_desc, "\n\t\t<description-auto-log>search_for = \"", unlist(strsplit(as.character(get(paste("dict_",floor(option),sep=""))[[1]][which(dict_match == 1)]),"[{=]"))[1], "\"; search_at = \"", search_at, "\"; dict_match = \"", which(dict_match == 1), "\"; line type=\"", option ,"\"</description-auto-log>", sep="")
			  
	  }
	  
	  # Process it ...
	  
	  # Calculate the time  number for this event
	  time_id <- paste(cc_tmp[[3]],cc_tmp[[4]], sep=" ")
	  # Change date and time style so that all numbers and followed without separators (neither hyphens, colons or spaces)
	  # This is performed here using regular expression, setting the characters to search surrounded by ([]) 
	  # I.e., in this case: ([:- ])
	  time_id <- gsub("([-: ])","",time_id)
	  
	  # Move forward one number in the event counter "event_counter"
	  event_counter <- event_counter+1;
	  
	  # Define the default event_type for this line type
	  if ( length(grep("Output ", bb_tmp[[3]])) > 0 ) {
		  event_type = "reactive";
	  }
	  
	  string_event <- paste("\t<event application=\"",bb_tmp[[2]],"\" action=\"Button\" user=\"",dd_tmp[[2]],"\" session=\"",
			  sessionId, "\" time=\"", time_id, "\" time_ms=\"",bb_tmp$X4,"\" type=\"", event_type ,"\" number=\"", event_counter, "\">", sep="")
	  
	  # Write it
	  write.table(paste(string_event, sep=""), file=abs_xmlfile, append=TRUE, 
			  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	  
	  
	  # Write param 
	  write.table(paste(string_param1, sep=""), file=abs_xmlfile, append=TRUE, 
			  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	  
	  #Write desc 
	  write.table(paste(string_desc, sep=""), file=abs_xmlfile, append=TRUE, 
			  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
		  
  
	  # --------------------------------------------------- < end
	  
	  if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
		  write.table(paste(line_n, " line type = ", option, " <- \"", aa_tmp, "\"", sep=""), file=log_conversion, append=TRUE, 
				  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	  } # end of if debug_desc
	  
  },
  
  ############################################################################
    ## option = 99 -> None of the above
    { 
      option <- 99

      if (debug_desc == 1) {	# Write the line number for logging and debugging purposes
	  # Write it
	  write.table(paste(line_n, " XXXX *** WATCH OUT *** XXXX - ",converter_r_script," didn't identify the line type, which contains: ", aa_tmp, sep=""), file=log_conversion, append=TRUE, 
	  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	} # end of if debug_desc

		# Add conversion script version to description for loging purposes
		string_unknown <- paste("\t\t<!-- XXXX *** WATCH OUT *** XXXX Line ", line_n," has an unknown type, which contains: ", aa_tmp," -->", sep="")
		
		# Write it to xml file
		write.table(paste("\n", string_unknown, sep=""), file=abs_xmlfile, append=TRUE, 
				row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
				
		# Print on R console also
		unknown_msg <- paste("Line ", line_n," in ", converter_path_to_output_files, conversionfile0, ".txt has an unknown type.\n", sep="");
		cat(unknown_msg);
		
		# Print on file also
		unknown_report_filename <- paste(converter_path_to_output_files, "00_unknown_file_types_in_", conversionfile0, ".txt",sep="");
		file.create(unknown_report_filename);
		write.table(unknown_msg, file=unknown_report_filename, append=TRUE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape");
		write.table(paste("Run in this file set: \n", conversion_file_list_name, "\n", sep=""), file=unknown_report_filename, append=TRUE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape");
		
		# Record the missmatch in an array of missmatch_list
		unknown_list <- rbind(unknown_list, unknown_msg);
		
    }

  ) # End of swith case


  } # end of for control flow: end of lines in the source file
  ## End of loop for processing from the 2nd to the last line of the source cleaned file
  close(con)

  # Write the final </event> tag
  write.table("\t</event>", file=abs_xmlfile, append=TRUE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape"  )

  # Write the final </log> tag
  write.table("</log>", file=paste(converter_path_to_output_files, conversionfile0, ".xml", sep=""),append=TRUE, 
  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )

  ## Delete the cleaned files if in debug mode
  if (debug_desc != 1) {
    system(paste("rm ",converter_path_to_output_files, conversionfile_clean1, ".txt", sep=""), TRUE)
    system(paste("rm ",converter_path_to_output_files, conversionfile_clean2, ".txt", sep=""), TRUE)
    system(paste("rm ",converter_path_to_output_files, conversionfile_clean3, ".txt", sep=""), TRUE)
  }

  	#########################################################################
	## Check for missmatches between <event> and </event> pairs of tags
	#########################################################################
	#if (debug_desc != 0) { # Check always for that, not only when in debug mode, otherwise problems will show up later, and everything will be worse than if analized and fixed earlier
	  # Initialize variables, just in case
	  xml_read <- NULL;
	  tag_missmatch <- NULL;
	  string_missmatch <- NULL;
	  
	  # Do the missmatch checking
	  xml_read <- paste(readLines(abs_xmlfile), "\n", collapse="")
	  tag_missmatch <- gregexpr("<event[^>]*?[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?<event|</event[^>]*?[^>]*?>(?:[^<]*?<param[^>]*?>|[^<]*?<description>[^<]*?</description>)*?[^<]*?</event",xml_read)
	  matched_string <- substr(xml_read, unlist(tag_missmatch)[1], unlist(tag_missmatch)[1]+unlist(attr(tag_missmatch[[1]], "match.length"))[1])
	  
	  if (unlist(tag_missmatch) > 0) {
		  
		  # Add conversion script version to description for loging purposes
		  string_missmatch <- paste("\t\t<!-- XXXX ", length(tag_missmatch), " Event Tag/s missmatch XXXX - Run 'Kodos' or 'XML Copy editor' or others to find where, and fix the regression bug properly... -->", sep="")
		  
		  # Write it to xml file
		  write.table(paste("\n", string_missmatch, sep=""), file=abs_xmlfile, append=TRUE, 
				  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
		  
		  if (debug_desc == 1) {
			  # Write it to log file
			  write.table(paste("\n", string_missmatch, sep=""), file=log_conversion, append=TRUE, 
					  row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
		  }
		  
		  # Print on R console also
		  cat("\n-------------------------------------\n");
		  missmatch_msg <- paste(length(tag_missmatch), " missmatch/es in ", abs_xmlfile, ", starting in position ", unlist(tag_missmatch)[1],"\n", sep="");
		  cat(missmatch_msg);
		  cat(paste("\n", matched_string, sep=""))
		  
		  # Print on file also
		  missmatch_report_filename <- paste(converter_path_to_output_files, "00_", tag_missmatch,"_missmatches_in_", conversionfile0, ".xml.txt",sep="");
		  file.create(missmatch_report_filename);
		  write.table(paste("\n-------------------------------------\n", length(tag_missmatch), " missmatch/es in ", abs_xmlfile, ", starting in position ", unlist(tag_missmatch)[1], "\n", sep=""), file=missmatch_report_filename, append=TRUE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape");
		  write.table(paste("Run in this file set: \n", conversion_file_list_name, "\n", sep=""), file=missmatch_report_filename, append=TRUE, row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape");
		  
		  # Record the missmatch in an array of missmatch_list
		  missmatch_list <- rbind(missmatch_list, missmatch_msg);
	  }
	#} # end of former check for debug_desc to be 1; currently, checking for tag mismatches is run always
	#########################################################################

} # end of processing that file from the list of files to convert

	# When in local mode, show in the console the file number (out of max files to report on) and its name
	cat(paste("Finished.\n", sep=""),sep="");

# Print the list of tag missmatches at the R console and in the file with the "conversiomn file list"
if (length(missmatch_list) > 0) {
	cat("\nXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
	cat("XXX Some EVENT TAG/S MISSMATCH in the xml file/s generated XXXX\n");
	cat("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
	cat("(Tip: Run 'Kodos' or 'XML Copy editor' or others to find where, and fix the regression bug properly)\n\n");
	cat(paste("Missmatches in ", length(missmatch_list), " files out of ", length(conversion_file_list), ".\n\n", sep=""));
	cat(missmatch_list);
	cat(paste("\n\nMissmatches in ", length(missmatch_list), " files out of ", length(conversion_file_list), ".\n", sep=""));
	# Print on file conversion_file_list_name also
	write.table(paste("\n\nMissmatches in ", length(missmatch_list), " files out of ", length(conversion_file_list), ".\n\n", sep=""), file=conversion_file_list_name, append=TRUE, 
			row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	write.table(paste(missmatch_list, sep=""), file=conversion_file_list_name, append=TRUE, 
			row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	
}

if (length(unknown_list) > 0) {
	cat("\n=====================================================================\n");
	cat("=== Some UNKNOWN LINE TYPES were identified in the source file/s ====\n");
	cat("=====================================================================\n");
	cat(unknown_list);
	# Print on file conversion_file_list_name also
	write.table(paste(unknown_list, sep=""), file=conversion_file_list_name, append=TRUE, 
			row.names=F, quote = F, sep=" ", dec = ".", col.names=F, qmethod="escape" )
	
}

## Delete the file with the report on files converted if not in debug mode and no missmatches found at all
if (debug_desc != 1 && length(missmatch_list) == 0 && length(unknown_list) == 0) {
	system(paste("rm ", conversion_file_list_name, sep=""), TRUE)
}
	
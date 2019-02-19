####################################################################
## location_milestone.r (temporarily here; later on their own r script files)..
##  updated for reporter_01.03.r
####################################################################
# updated to show all matches for each regexp, finally! (January 2011)

matched_string <-""; # Initialize again  

# Adapt this code for more than one match of milestone_id in the xml file
for (ll in 1:length(unlist(location_tmp))) { 
	# ll<-1;
	# unlist(location_tmp)[ll]
	# Fetch the values for the array location
	matched_string <- substr(xml_r, unlist(location_tmp)[ll], unlist(location_tmp)[ll]+unlist(attr(location_tmp[[1]], "match.length"))[ll])
	
	if (unlist(location_tmp)[ll] > 0) {   
		
		matched_string2 <-""; # Initialize again
		session_id <-""; # Initialize again
		action_id <-""; # Initialize again
		
		# Divide the string in pieces splitted by the two characters: \"
		matched_string2 <- strsplit(matched_string, "\"", fixed=TRUE );
		
		# *** Fetch action_id ***
		# This following command returns an array of "-1" values except for the one containing the " number="
		location_number <- gregexpr(" number=", matched_string2[[1]]);
		
		# Assign to action_id the first occurrence of "number" for that action (if there are more than one event trapped from the regexpr, only the first one is saved).
		action_id <- matched_string2[[1]][(which(unlist(location_number)=="1")+1)][[1]]
		## format action_id so that it contains zeros to the left until it becomes a 5 character string, for better ordering while sortedin external programs
		action_id <- sprintf("%05.0f", as.integer(action_id));
		
		# *** Fetch session_id ***
		# This following command returns an array of "-1" values except for the one containing the " session="
		location_session <- gregexpr(" session=", matched_string2[[1]]);
		# add to session_id the session number for the first of the "number=" for that action.
		session_id <- matched_string2[[1]][(which(unlist(location_session)=="1")+1)][[1]]
		
# length(action_id)
# jj
# ii
#test_aa <- "0";
		# Loop needed for cases where there are more than one match for that regexp
		##      for (jj in 1:length(action_id)) { 
		# jj=jj+1
		#		test_aa <- "1";
		# Dummy counter for location rows: to convert Session_id into the right number/code at the right position in location matrix
		ii <- ii+1;
		
		#		location[ii,] <-   c(action_id[jj], milestone_id, milestone_label, unlist(location_tmp)[jj], attr(location_tmp[[1]], "match.length")[jj], session_id[jj]);	
		
		# convert the location matrix into a rbind process. Session is added twice to keep one for debugging after it's been renamed to integer numbers (1, 2 3...)
		# Session_id is recoded to match current id being used in session_list
		session_code <- session_list[which(session_id[1]==session_list[,2]),1]
		
		# when match on session label (session_list[2]), get session id (session_list[1]) and add replace value of Session_label
#		location <- rbind(location, c(action_id[jj], milestone_id, milestone_label, unlist(location_tmp)[jj], attr(location_tmp[[1]], "match.length")[jj], session_id[jj], session_code));	
		location <- rbind(location, c(action_id, milestone_id, milestone_label[as.numeric(milestone_id)], unlist(location_tmp)[ll], attr(location_tmp[[1]], "match.length")[ll], session_id, session_code));	
		
		#		#		print(paste(action_id[jj], milestone_id, milestone_label, unlist(location_tmp)[jj], attr(location_tmp[[1]], "match.length")[jj], session_id[jj], session_id[jj], sep= " | "))
		#		#location[ii,] <-   c(action_id[jj], milestone_id, milestone_label, unlist(location_tmp)[jj], attr(location_tmp[[1]], "match.length")[jj], I(session_id[jj]));	# Changed last session_if surrounded by I() to avoid changing it's type into factor. See https://stat.ethz.ch/pipermail/r-help/2000-July/007595.html
		#		location[ii,7] <- session_list[which(location[ii,6]==session_list[,2]),1]
		
		# c(action_id[jj], milestone_id, unlist(location_tmp)[jj], attr(location_tmp[[1]], "match.length")[jj], session_id[jj]);	
		# location[ii,]
		# location[1:8,]
#		} # end of for jj
	} # end of if
} # end of for loop for number of location_tmp matches for that milestone_id
	
####################################################################

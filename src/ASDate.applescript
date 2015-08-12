property astext : script "com.kraigparkinson/ASText"

property DATE_DELIM : "#"

property TIMESTAMP_MASK : "YYYY-MM-DDTHH:MM:SS-ZZZZ"
property DELIMS : {"-", "T", ":"}

on parseTimestamp(timestamp)
	local parsedDate
	
	if (validTimestamp(timestamp)) then
		set tsElements to astext's getTextElements(timestamp, {"-", "T"})
		set theYear to item 1 in tsElements
		set theMonth to item 2 in tsElements
		set theDay to item 3 in tsElements
		set theTime to item 4 in tsElements
		set theTimeZone to item 5 in tsElements
		
		set parsedDate to offsetTime(date (theMonth & "/" & theDay & "/" & theYear & ", " & theTime), timezoneToOffset(theTimeZone))
	else
		set parsedDate to null
	end if
	
	return parsedDate
end parseTimestamp

on timezoneToOffset(timezone)
	local theOffset
	if (length of timezone = 4) then
		set theOffset to (timezone as integer) / 100
	else
		set theOffset to time to GMT
	end if
end timezoneToOffset

on offsetTime(theDate, theOffset)
	return theDate
end offsetTime

on validTimestamp(timestamp)
	local isValid
	
	set hasDateAndTime to (count of astext's getTextElements(timestamp, "T")) = 2
	set isCorrectLength to length of timestamp is equal to length of TIMESTAMP_MASK
	
	if (hasDateAndTime) and (isCorrectLength) then
		set isValid to true
	else
		set isValid to false
	end if
	
	return isValid
end validTimestamp

(*
	OF doesn't like the YYYY-MM-DDTHH:MM:SS-ZONE format.  
	It doens't know what to do with seconds or the time zone, and doens't know how to parse the T in the middle. 
	Instead it needs you to say 'YYYY-MM-DD at HH:MM' 
	*)
on reformatDateTimeStampToOF(supposedDateTimeStamp)
	set reformattedDateTimeStamp to supposedDateTimeStamp
	
	-- Check that the format of the string matches what I'm expecting
	set prevTIDs to text item delimiters of AppleScript
	try
		set text item delimiters of AppleScript to "T"
		
		if (length of first text item of supposedDateTimeStamp is equal to 10) then --length of date stamp
			set supposedDateTimeStampElements to every text item of supposedDateTimeStamp
			
			if (count of supposedDateTimeStampElements) is equal to 2 then
				-- This just shows us there's a 'T' character, need to dive deeper
				
				set supposedDateStamp to first text item of supposedDateTimeStampElements
				set supposedTimeStamp to second text item of supposedDateTimeStampElements
				
				--Check if first element looks like a date stamp
				
				set text item delimiters of AppleScript to "-"
				set supposedDateStampElements to every text item of supposedDateStamp
				
				if (count of supposedDateStampElements) is equal to 3 then
					set theYear to text item 1 of supposedDateStampElements
					set theMonth to text item 2 of supposedDateStampElements
					set theDay to text item 3 of supposedDateStampElements
					
					if length of theYear is equal to 4 and length of theMonth is equal to 2 and length of theDay is equal to 2 then
						--We might have a date! Should do more validation here...
						--Now check the time...							
						set text item delimiters of AppleScript to ":"
						set supposedTimeStampElements to every text item of supposedTimeStamp
						
						if (count of supposedTimeStampElements) is equal to 3 then
							--We might have a date time stamp!
							-- Let's go do stuff to it.
							
							
							set reformattedDateTimeStamp to astext's replaceChars(supposedDateTimeStamp, "T", " at ")
							set reformattedDateTimeStamp to trimTimezone(reformattedDateTimeStamp)
							set reformattedDateTimeStamp to trimSeconds(reformattedDateTimeStamp)
							
							
						end if
					end if
				end if
			end if
		end if
		set AppleScript's text item delimiters to prevTIDs
	on error
		set AppleScript's text item delimiters to prevTIDs
	end try
	
	return reformattedDateTimeStamp
	
	
end reformatDateTimeStampToOF


on tidyTaskName(unparsedTaskName)
	set parsedTaskName to "no processing whatsoever"
	
	set prevTIDs to text item delimiters of AppleScript
	try
		set text item delimiters of AppleScript to DATE_DELIM
		
		-- Find dates
		set taskNameElements to every text item of unparsedTaskName
		set AppleScript's text item delimiters to prevTIDs
		
		if (count of taskNameElements) is 1 then (* Likely no date found *)
			set parsedTaskName to item 1 of taskNameElements
		else if (count of taskNameElements) is 2 then (* Treat the second item like a due date *)
			set taskName to item 1 of taskNameElements
			
			set dueDateAndPossiblyMore to item 2 of taskNameElements
			set dueDateTimeStamp to (characters 1 thru 24 of dueDateAndPossiblyMore) as string
			set remainder to ""
			
			if length of dueDateAndPossiblyMore is greater than 24 then
				set remainder to (characters 25 thru -1 of dueDateAndPossiblyMore) as string
			end if
			
			set parsedTaskName to taskName & DATE_DELIM & reformatDateTimeStampToOF(dueDateTimeStamp) & remainder
			
		else if (count of taskNameElements) is 3 then
			set taskName to item 1 of taskNameElements
			set deferDateTimeStamp to (characters 1 thru 24 of item 2 of taskNameElements) as string
			
			set dueDateAndPossiblyMore to item 3 of taskNameElements
			set dueDateTimeStamp to (characters 1 thru 24 of dueDateAndPossiblyMore) as string
			
			set remainder to ""
			
			if length of dueDateAndPossiblyMore is greater than 24 then
				set remainder to (characters 25 thru -1 of dueDateAndPossiblyMore) as string
			end if
			
			set parsedTaskName to taskName & DATE_DELIM & reformatDateTimeStampToOF(deferDateTimeStamp) & " " & DATE_DELIM & reformatDateTimeStampToOF(dueDateTimeStamp) & remainder
		else if (count of taskNameElements) is 4 then
			
		else if (count of taskNameElements) is 5 then
			
		else
			
		end if
		
		
		
	on error msg number num
		set AppleScript's text item delimiters to prevTIDs
		error msg number num
		
	end try
	
	return parsedTaskName
end tidyTaskName

on trimTimezone(dateTimeString)
	return astext's replaceChars(dateTimeString, "-0600", "")
end trimTimezone

on trimSeconds(dateTimeString)
	set prevTIDs to text item delimiters of AppleScript
	try
		set text item delimiters of AppleScript to ":"
		
		set theDateAndHour to text item 1 of dateTimeString
		set theMinutes to text item 2 of dateTimeString
		
		--reconstruct the date 
		set dateTimeString to theDateAndHour & ":" & theMinutes
		
		set AppleScript's text item delimiters to prevTIDs
	on error
		set AppleScript's text item delimiters to prevTIDs
	end try
	
	return dateTimeString
end trimSeconds

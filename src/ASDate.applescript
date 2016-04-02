property textutil : script "com.kraigparkinson/ASText"

property DATE_DELIM : "#"

property TIMESTAMP_MASK : "YYYY-MM-DDTHH:MM:SS-ZZZZ"
property DELIMS : {"-", "T", ":"}

property DAYS_OF_WEEK : {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}
property TIME_DELIM : space & "at" & space

script CalendarDate
	property MIDNIGHT : "12:00:00AM"
	property theDate : missing value
	
	on make new CalendarDate with data dateValue as date given overridetime:timeText : missing value
		if (dateValue is missing value) then error "Can't create CalendarDate with missing value."
		
		copy CalendarDate to newDate
		tell newDate to reset()
		if (timeText is not missing value) then set dateValue to date timeText of dateValue
		 
		tell newDate to initializeDate(dateValue)
		
		if (not newDate's initialized()) then error "Could not make new CalendarDate with " & dateValue & " with overridetime" & timeText
		return newDate
	end make
	
	on reset()
		set theDate to missing value
	end reset
	
	on initialized()
		return theDate is not missing value
	end initialized
			
	on verifyInitalization()
		if (not initialized()) then error "CalendarDate instance not initialized."
	end verifyInitalization
	
	on create on dateValue as date at aTime as text : missing value
		if (dateValue is missing value) then error "Can't create CalendarDate with missing value."
		
		set newDate to make new CalendarDate with data dateValue given overridetime:aTime
		
		if (not newDate's initialized()) then error "Could not create CalendarDate " & dateValue & " at " & aTime
		return newDate
	end create 
	
	on today at timeText as text : "12:00:00AM"
		if (timeText is missing value) then error "Handlers not using default time as expected."
			
		set newDate to create on current date at timeText
		return newDate
	end today
	
	on yesterday at timeText as text : "12:00:00AM"
		set newDate to (my today at timeText)'s previous()
		return newDate
	end yesterday
	
	on tomorrow at timeText as text : "12:00:00AM" 
		set newDate to (my today at timeText)'s next()
		return newDate
	end tomorrow
	
	on parse from dateText as text at defaultTimeText : "12:00:00AM"
		local newDate --Type is CalendarDate
		local timeText
		
		if (dateText contains TIME_DELIM)
			set dateTextElements to textUtil's getTextElements(dateText, TIME_DELIM)
			if (count of dateTextElements is not 2) then error "Incomplete date and time string: " & dateText

			set dateText to first item in dateTextElements
			set timeText to second item in dateTextElements			
		else --Might contain implicit time elements, might not.
			-- May have implicit time elements due to auto-generated text, need to find those
			set dateTextElements to textutil's getTextElements(dateText, space)
			set timeText to missing value
			set dateText to ""
	
			repeat with anItem in dateTextElements
				ignoring case
					if (anItem contains ":") then --Assumes the AM/PM is right on it
						set timeText to anItem
					else
						if dateText equals ""
							set dateText to anItem --reconstruct date text
						else
							set dateText to dateText & space & anItem --reconstruct date text
						end
					end 
				end ignoring
			end repeat
			
			if (timeText is missing value) then 
				set timeText to defaultTimeText
			end 
		end 
	
		ignoring case
			-- today
			if (textContainsToday(dateText)) then 
				set newDate to today at timeText
			-- tomorrow
			else if (textContainsTomorrow(dateText)) then
				set newDate to tomorrow at timeText
			-- yesterday
			else if (textContainsYesterday(dateText)) then
				set newDate to yesterday at timeText
			-- Check for next weekdays	
			else if (dateText begins with "next ") then
				set newDate to (today at timeText)'s nextWeekday(textToWeekday(text 6 thru (length of dateText) of dateText))
			-- Check for last weekdays
			else if (dateText begins with "last ") then
				set newDate to (today at timeText)'s lastWeekday(textToWeekday(text 6 thru (length of dateText) of dateText))
			-- Check for regular weekdays
			else if (textContainsWeekday(dateText))
				set newDate to (today at timeText)
				set theWeekday to weekday of newDate's asDate()
				if theWeekday is not textToWeekday(dateText) then
					set newDate to newDate's nextWeekday(textToWeekday(dateText))
				end if
			else if (textIsIncrement(dateText)) 
				set newDate to (today at timeText)'s increment by textToDateIncrement(dateText)
			else 
				set newDate to create on date dateText at timeText
			end if
		end ignoring		
		
		if (newDate is missing value) then error "Date not created from text: " & dateText
		return newDate	
	end parse
	
	on initializeDate(dateValue as date)
		if theDate is not missing value then error "Date already set."
		set theDate to dateValue
	end initializeDate
	
	on increment by numDays
		verifyInitalization()		
		set newDate to create on (theDate + numDays * days)
		return newDate
	end next
	
	on next()
		return increment by 1
	end next
	
	on previous()
		return increment by -1
	end previous
	
	on asDate()
		return theDate
	end asDate
		
	-- From http://www.leancrew.com/all-this/2012/09/eight-days-a-week/
	on nextWeekday(theWeekday)
		verifyInitalization()
		
		if (theWeekday is not in {Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday}) then error "Invalid weekday " & theWeekday

		set myWeekday to weekday of theDate
		
		if myWeekday is theWeekday then
			set d to 7
		else
			set d to (7 + theWeekday - myWeekday) mod 7
		end if
		
		set newDate to (create on theDate)'s increment by d
		return newDate
	end nextWeekday
	
	-- From http://www.leancrew.com/all-this/2012/09/eight-days-a-week/
	on lastWeekday(theWeekday)
		verifyInitalization()
		
		if (theDate is missing value) then error "CalendarDate not initialized properly."
		if (theWeekday is not in {Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday}) then error "Invalid weekday " & theWeekday
		
		set myWeekday to weekday of theDate
		if myWeekday is theWeekday then
			set d to 7
		else
			set d to ((myWeekday as integer) - (theWeekday as integer) + 7) mod 7
		end if
		
		return (create on theDate)'s increment by -d
	end lastWeekday
	
	on textIncludesTime(dateText)
		-- May have implicit time elements due to auto-generated text, need to find those
		set dateTextElements to textutil's getTextElements(dateText, space)
		set timeText to missing value
	
		repeat with anItem in dateTextElements
			if (anItem contains ":") then set timeText to anItem	
		end repeat
	
		return timeText is not missing value
	end textIncludesTime
	
	on textContainsToday(dateText)
		ignoring case, white space
			return dateText contains "today"
		end ignoring
	end textContainsToday

	on textContainsTomorrow(dateText)
		ignoring case, white space
			return dateText contains "tom"
		end ignoring
	end textContainsTomorrow

	on textContainsYesterday(dateText)
		ignoring case, white space
			return dateText contains "yesterday"
		end ignoring	
	end textContainsYesterday
	
	on textContainsWeekday(dateText)
		ignoring case		
			repeat with theDay in DAYS_OF_WEEK
				if (dateText contains theDay) then return true
			end repeat		
		end ignoring
	
		return false
	end textContainsWeekday
	
	on textIsIncrement(dateText)
		ignoring case
			return ((dateText begins with "+") or (dateText begins with "-"))
		end ignoring
	end textIsIncrement

	on textContainsWeekdayModifiers(dateText)
		ignoring case
			return (dateText starts with "next") or (dateText starts with "last")
		end ignoring
	end textContainsWeekdayModifiers

	on textIsAWeekday(dateText)
		set theWeekdays to DAYS_OF_WEEK
		set validWeekday to false
	
		ignoring case
			set validWeekday to dateText is in DAYS_OF_WEEK
		end ignoring
	
		return validWeekday
	end textIsAWeekday

end script

(*
	pre: incrText ends with {"d", "w"}
	post: result is integer
*)
on textToDateIncrement(incrText)
	if (incrText is null or incrText is missing value or incrText is "") then error "Invalid date increment " & incrText & "."
	if (get first character of incrText) is not in {"+", "-"} then error "Invalid date increment " & incrText & "."
	if (get last character of incrText) is not in {"d", "w"} then error "Invalid date increment " & incrText & "."
	
	local theIncrement
	local timeUnitMultiplier
	
	--Assume there are some qualifiers here
	set endingIndex to (length of incrText) - 1
	
	--parse multiplier
	if (incrText ends with "d") then
		set timeUnitMultiplier to 1
	else if (incrText ends with "w") then
		set timeUnitMultiplier to 7
	else
		set timeUnitMultiplier to 1
		set endingIndex to length of incrText
	end if
	
	--Determine sign and value
	if (incrText begins with "+") then
		set startingIndex to 2
		set theIncrement to text startingIndex thru endingIndex of incrText as integer
	else if (incrText begins with "-") then
		set startingIndex to 2
		set theIncrement to text startingIndex thru endingIndex of incrText as integer
		set theIncrement to -1 * theIncrement
	else
		set startingIndex to 1
		set theIncrement to text startingIndex thru endingIndex of incrText as integer
	end if
	
	set theIncrement to theIncrement * timeUnitMultiplier
	
	return theIncrement
end 

(*
	pre: weekdayText is in {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"} (ignore case)
	post: result is in {Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday}
*)
on textToWeekday(weekdayText as text)
	ignoring case, white space
		if (weekdayText is not in DAYS_OF_WEEK) then error "Invalid day of week " & weekdayText & "."

		if (weekdayText is "monday") then
			return Monday
		else if (weekdayText is "tuesday") then
			return Tuesday
		else if (weekdayText is "wednesday") then
			return Wednesday
		else if (weekdayText is "thursday") then
			return Thursday
		else if (weekdayText is "friday") then
			return Friday
		else if (weekdayText is "saturday") then
			return Saturday
		else if (weekdayText is "sunday") then
			return Sunday
		end if
	end ignoring	
end textToWeekday

on parseTimestamp(timestamp)
	local parsedDate
	
	if (validTimestamp(timestamp)) then
		set tsElements to textutil's getTextElements(timestamp, {"T"})
		set dateElements to textutil's getTextElements(first item in tsElements, "-")
		set timeElement to second item in tsElements
		
		set theYear to item 1 in dateElements
		set theMonth to item 2 in dateElements
		set theDay to item 3 in dateElements
		
		set theTime to text 1 thru 8 in timeElement
		set theTimeZone to text 9 thru 13 in timeElement
		
		set parsedDate to offsetTime(date (theMonth & "/" & theDay & "/" & theYear & " at " & convertTo12Hour(theTime)), timezoneToOffset(theTimeZone))
	else
		set parsedDate to null
	end if
	
	return parsedDate
end parseTimestamp

on convertTo12Hour(timestamp)
	set timeelements to textutil's getTextElements(timestamp, ":")
	set theHours to item 1 in timeelements as integer
	set theMinutes to item 2 in timeelements
	set theSeconds to item 3 in timeelements
	
	local theAMPM
	
	if (theHours > 12) then
		set theHours to theHours - 12
		set theAMPM to "PM"
	else
		set theAMPM to "AM"
	end if
	
	set timestamp to (theHours as text) & ":" & theMinutes & ":" & theSeconds & space & theAMPM
	
	return timestamp
end convertTo12Hour

on timezoneToOffset(timezone)
	local theOffset
	
	if (length of timezone = 5) then
		set theOffset to (timezone as integer) / 100
	else
		set theOffset to (time to GMT) / hours
	end if
end timezoneToOffset

on offsetTime(theDate, theOffsetHours)
	set localOffset to (time to GMT) / hours
	
	--doesn't account for Daylight Savings; may actually be -7.0.	
	set theDifference to (localOffset - theOffsetHours)
	
	return theDate + (theDifference * hours)
end offsetTime

on validTimestamp(timestamp)
	local isValid
	
	set hasDateAndTime to (count of textutil's getTextElements(timestamp, "T")) = 2
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
							
							
							set reformattedDateTimeStamp to textutil's replaceChars(supposedDateTimeStamp, "T", " at ")
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


on trimTimezone(dateTimeString)
	return textutil's replaceChars(dateTimeString, "-0600", "")
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

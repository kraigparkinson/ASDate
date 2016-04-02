(*!
	@header dateutil
		dateutil self tests.
	@abstract License: GNU GPL, see COPYING for details.
	@author Kraig Parkinson
	@copyright 2015 kraigparkinson
*)

property dateutil : script "com.kraigparkinson/ASDate"

property parent : script "com.lifepillar/ASUnit"
property suite : makeTestSuite("OF Date Parsing")
--autorun(suite)

my autorun(suite)

script |Format Dates|
	property parent : TestSet(me)
	
	on setUp()
	end setUp
	
	on tearDown()
	end tearDown
	
	script |timezone to offset|
		property parent : UnitTest(me)
		set systemGMTOffset to time to GMT
		
		shouldEqual(-6, (systemGMTOffset / hours))
		shouldEqual(-6, dateutil's timezoneToOffset("-0600"))
		shouldEqual(6, dateutil's timezoneToOffset("+0600"))
		--		shouldEqual(6.5, dateutil's timezoneToOffset("0630"))
		
	end script
	
	script |parse timestamp|
		property parent : UnitTest(me)
		
		set theMonth to "08"
		set theDay to "10"
		set theYear to "2015"
		--		set theTime to "23:11:58"
		set theTime to "11:11:58 PM"
		(*		
		shouldEqual(date "Saturday, August 8, 2015 at 11:11:00 PM", date ("08/09/2015 at 23:11"))
		shouldEqual(date "Sunday, August 9, 2015 at 11:11:00 PM", date ("08/09/2015 at 11:11 PM"))
		shouldEqual(date "Monday, August 10, 2015 at 11:11:58 PM", date ("08/10/2015 at 11:11:58 PM"))
*)
		
		shouldEqual(date "Tuesday, August 11, 2015 at 11:11:58 PM", dateutil's parseTimestamp("2015-08-11T23:11:58-0600"))
		shouldEqual(date "Wednesday, August 12, 2015 at 11:11:58 PM", dateutil's parseTimestamp("2015-08-13T00:11:58-0500"))
		
	end script
	
	script |convert time to 12-hour|
		property parent : UnitTest(me)
		
		shouldEqual("11:12:13 AM", dateutil's convertTo12Hour("11:12:13"))
		shouldEqual("11:12:13 PM", dateutil's convertTo12Hour("23:12:13"))
		
	end script
	
	script |offset time|
		property parent : UnitTest(me)
		
		set expectedDate to date "Monday, August 10, 2015 at 11:12:13 PM"
		
		shouldEqual(expectedDate, dateutil's offsetTime(date "Monday, August 10, 2015 at 11:12:13 PM", -6))
		shouldEqual(expectedDate, dateutil's offsetTime(date "Tuesday, August 11, 2015 at 12:12:13 AM", -5))
	end script
	
	
	script |valid timestamp|
		property parent : UnitTest(me)
		
		should(dateutil's validTimestamp("2015-08-11T23:11:58-0600"), "'2015-08-11T23:11:58-0600' not parsed as valid timestamp as it should")
		refute(dateutil's validTimestamp("2015-08-11T23:11:58-06000"), "timestamp too long")
		refute(dateutil's validTimestamp("2015-08-11T23:11:58-060"), "timestamp too short")
		refute(dateutil's validTimestamp("2015-08-11, 23:11:58-0600"), "timestamp has no T")
		
		refute(dateutil's validTimestamp("2015-08-11T23:11:58"), "timestamp has no timezone")
	end script
	
	script |make pretty dates for OF without timezones and seconds|
		property parent : UnitTest(me)
		
		tell dateutil
			my shouldEqual("", reformatDateTimeStampToOF(""))
			--shouldEqual("STOP", reformatDateTimeStampToOF("STOP"))
			my shouldEqual("2015-06-19", reformatDateTimeStampToOF("2015-06-19"))
			my shouldEqual("17:25:39-0600", reformatDateTimeStampToOF("17:25:39-0600"))
			my shouldEqual("2015-06-19 at 17:25", reformatDateTimeStampToOF("2015-06-19T17:25:39-0600"))
		end tell
	end script
	
	script |can trim seconds from dates|
		property parent : UnitTest(me)
		
		tell dateutil
			my shouldEqual("", trimSeconds(""))
			my shouldEqual("17:25", trimSeconds("17:25"))
			my shouldEqual("17:25", trimSeconds("17:25:39"))
			my shouldEqual("2015-06-19T17:25", trimSeconds("2015-06-19T17:25:39"))
			my shouldEqual("2015-06-19T17:30", trimSeconds("2015-06-19T17:30:39"))
		end tell
	end script
	
	script |can trim time zones from dates|
		property parent : UnitTest(me)
		
		tell dateutil
			
			my shouldEqual("", trimTimeZone(""))
			my shouldEqual("2015-06-19T17:25:39", trimTimeZone("2015-06-19T17:25:39-0600"))
		end tell
	end script
		
	script |create on a date|
		property parent : UnitTest(me)
		
		set todaysDate to current date
		set todaysDate to date "12:00:00AM" of todaysDate
		
		tell dateutil's CalendarDate
			my assertEqual(todaysDate, (create on todaysDate)'s asDate())
			my assertEqual(date "08:00AM" of todaysDate, (create on todaysDate at "8:00:00AM")'s asDate())
		end tell 
	end script
	
	
	on testCalendarDateFactoryWorks(expectedDate, actualCalendarDate)
		assertEqual(true, actualCalendarDate's initialized())
		assertEqual(expectedDate, actualCalendarDate's asDate())
	end testCalendarDateFactoryWorks
	
	script |today|
		property parent : UnitTest(me)
		
		set todaysDate to current date		
		
		-- Alternate test code		
		tell dateutil's CalendarDate
--			my testCalendarDateFactoryWorks(date "12:00AM" of todaysDate, (today))
			my testCalendarDateFactoryWorks(date "1:00AM" of todaysDate, (today at "1:00AM"))
		end tell
	end script

	script |yesterday|
		property parent : UnitTest(me)
		
		set expectedDate to current date - 1 * days
		
		tell dateutil's CalendarDate
--			my testCalendarDateFactoryWorks(date "12:00AM" of expectedDate, yesterday)
			my testCalendarDateFactoryWorks(date "1:00AM" of expectedDate, yesterday at "1:00AM")
		end tell
	end script
	
		
	script |tomorrow|
		property parent : UnitTest(me)
		
		local expectedDAte
		
		set expectedDate to current date
		set expectedDate to date "12:00:00AM" of expectedDate
		set expectedDate to expectedDate + 1 * days		

		tell dateutil's CalendarDate
--			my testCalendarDateFactoryWorks(expectedDate, tomorrow)
			my testCalendarDateFactoryWorks(expectedDate, tomorrow at "12:00:00AM")
		end tell
	end script
	
	script |next|
		property parent : UnitTest(me)
		
		set originalDate to date "2015-09-18 12:00:00AM"
		set expectedDate to originalDate + 1 * days		
		
		my assertEqual(expectedDate, (dateutil's CalendarDate's create on originalDate)'s next()'s asDate())
	end script

	script |previous|
		property parent : UnitTest(me)
		
		set originalDate to date "2015-09-18 12:00:00AM"
		set expectedDate to originalDate - 1 * days		
		
		my assertEqual(expectedDate, (dateutil's CalendarDate's create on originalDate)'s previous()'s asDate())
	end script	

	on testDatesEqual(expectedCalendarDate, testDateString)
		shouldEqual(expectedCalendarDate's asDate(), (dateutil's CalendarDate's parse from testDateString by "5:00:00PM")'s asDate())
	end testDatesEqual
	
	script |increment by|
		property parent : UnitTest(me)
		
		set originalDate to date "2015-05-01 12:00:00AM"
				
		tell dateutil's CalendarDate
			set actualOriginalDate to create on originalDate at "12:00AM"
			set actualFollowingDate to actualOriginalDate's increment by 0
		
			my shouldEqual(originalDate, actualOriginalDate's asDate())
			my shouldEqual(originalDate, actualFollowingDate's asDate())

			set actualFollowingDate to actualOriginalDate's increment by 1
			
			my shouldEqual(originalDate, actualOriginalDate's asDate())
			my shouldEqual(originalDate + 1 * days, actualFollowingDate's asDate())
		end tell
	end script
	
	on testParseFromText(expected, testDateString, defaultTimeText)
		tell dateutil's CalendarDate
			my shouldEqual(expected's asDate(), (parse from testDateString at defaultTimeText)'s asDate())
		end tell
	end testParseFromText
	
	script |parse from date increments|
		property parent : UnitTest(me)
		
		tell dateutil's CalendarDate
			my testParseFromText(today at "12:00:00AM", "+0d at 12:00:00AM", "05:00:00PM")
			my testParseFromText(today at "04:00:00PM", "+0d at 04:00:00PM", "05:00:00PM")
			my testParseFromText(today at "05:00:00PM", "+0d", "05:00:00PM")
			my testParseFromText(tomorrow at "12:00:00AM", "+1d at 12:00:00AM", "05:00:00PM")
			my testParseFromText(tomorrow at "04:00:00PM", "+1d at 4:00PM", "05:00:00PM")
			my testParseFromText((today at "05:00:00PM")'s increment by 7, "+1w", "05:00:00PM")
		end tell
		
	end script
	
	script |parse from exact dates|
		property parent : UnitTest(me)
		
		tell dateutil's CalendarDate
			set todaysDate to current date
			set todaysDate to date "12:00:00AM" of todaysDate
			
			my assertEqual(date "08:00AM" of todaysDate, (parse from "today at 08:00AM" at "12:00PM")'s asDate())

			my testParseFromText(today at "8:00:00AM", "today", "8:00:00AM")			
			my testParseFromText(create on date "2015-08-18 12:00:00AM", "2015-08-18", "12:00:00AM")
			my testParseFromText(create on date "2015-08-19 8:00:00AM", "2015-08-19 8:00:00AM", "12:00:00AM")
			my testParseFromText(create on date "2015-08-18 12:00:00AM", "2015-08-18 12:00:00AM", "08:00:00AM")
		end tell
	end script

	script |parse from day of week|
		property parent : UnitTest(me)
		
		tell dateutil's CalendarDate
			my testParseFromText(today at "8:00:00AM", "monday", "8:00:00AM")			
			my shouldEqual((today at "8:00:00AM")'s asDate(), (parse from "monday" at "8:00:00AM")'s asDate())
			my shouldEqual((tomorrow at "8:00:00AM")'s asDate(), (parse from "tuesday" at "8:00:00AM")'s asDate())
--			my testParseFromText(aMon at "8:00:00AM", "monday", "8:00:00AM")			
		end tell
	end script

	
	script |text to date increment|
		property parent : UnitTest(me)
		
		tell dateutil
			my shouldEqual(1, textToDateIncrement("+1d"))
			my shouldEqual(-1, textToDateIncrement("-1d"))
			my shouldEqual(7, textToDateIncrement("+1w"))
			my shouldEqual(14, textToDateIncrement("+2w"))
		end tell
		
		testDateIncrementFails("")
		testDateIncrementFails("1d")
		testDateIncrementFails("+1m")
	end script
	
	on testDateIncrementFails(incrText)
		try
			dateutil's textToDateIncrement(incrText)
		on error message
			shouldEqual("Invalid date increment " & incrText & ".", message)
		end		
	end testDateIncrementFails
	
	
	on testParseDayOfWeek(expectedDate, dateString) 
		tell dateutil
			my shouldEqual(expectedDate's asDate(), (dateutil's CalendarDate's parse from dateString)'s asDate())		
		end tell
	end testParseDayOfWeek
	
	script |parse next weekdays|	
		property parent : UnitTest(me)
	
		set aTue to (dateutil's CalendarDate's create on date "2016-03-01 12:00:00AM") 
		set aWed to (dateutil's CalendarDate's create on date "2016-03-02 12:00:00AM") 
		set aThu to (dateutil's CalendarDate's create on date "2016-03-03 12:00:00AM") 
		set aFri to (dateutil's CalendarDate's create on date "2016-03-04 12:00:00AM") 
		set aSat to (dateutil's CalendarDate's create on date "2016-03-05 12:00:00AM") 
		set aSun to (dateutil's CalendarDate's create on date "2016-03-06 12:00:00AM") 
		set aMon to (dateutil's CalendarDate's create on date "2016-03-07 12:00:00AM") 
		set nTue to (dateutil's CalendarDate's create on date "2016-03-08 12:00:00AM") 
	
		shouldEqual(aWed's asDate(), aTue's nextWeekday(Wednesday)'s asDate())
		shouldEqual(aThu's asDate(), aTue's nextWeekday(Thursday)'s asDate())
		shouldEqual(aFri's asDate(), aTue's nextWeekday(Friday)'s asDate())
		shouldEqual(aSat's asDate(), aTue's nextWeekday(Saturday)'s asDate())
		shouldEqual(aSun's asDate(), aTue's nextWeekday(Sunday)'s asDate())
		shouldEqual(aMon's asDate(), aTue's nextWeekday(Monday)'s asDate())
		shouldEqual(nTue's asDate(), aTue's nextWeekday(Tuesday)'s asDate())
		
	end script
	
	script |parse last weekdays|
		property parent : UnitTest(me)

		set lTue to (dateutil's CalendarDate's create on date "2016-03-01 12:00:00AM") 
		set lWed to (dateutil's CalendarDate's create on date "2016-03-02 12:00:00AM") 
		set lThu to (dateutil's CalendarDate's create on date "2016-03-03 12:00:00AM") 
		set lFri to (dateutil's CalendarDate's create on date "2016-03-04 12:00:00AM") 
		set lSat to (dateutil's CalendarDate's create on date "2016-03-05 12:00:00AM") 
		set lSun to (dateutil's CalendarDate's create on date "2016-03-06 12:00:00AM") 
		set lMon to (dateutil's CalendarDate's create on date "2016-03-07 12:00:00AM") 
		set aTue to (dateutil's CalendarDate's create on date "2016-03-08 12:00:00AM") 
	
		shouldEqual(lMon's asDate(), aTue's lastWeekday(Monday)'s asDate())
		shouldEqual(lSun's asDate(), aTue's lastWeekday(Sunday)'s asDate())
		shouldEqual(lSat's asDate(), aTue's lastWeekday(Saturday)'s asDate())
		shouldEqual(lFri's asDate(), aTue's lastWeekday(Friday)'s asDate())
		shouldEqual(lThu's asDate(), aTue's lastWeekday(Thursday)'s asDate())
		shouldEqual(lWed's asDate(), aTue's lastWeekday(Wednesday)'s asDate())
		shouldEqual(lTue's asDate(), aTue's lastWeekday(Tuesday)'s asDate())

	end script
	
	script |is a weekday|
		property parent : UnitTest(me)

		tell dateutil's CalendarDate
			my should(textIsAWeekday("monday"), "monday")
			my should(textIsAWeekday("tuesday"), "tuesday")
			my should(textIsAWeekday("wednesday"), "wednesday")
			my should(textIsAWeekday("thursday"), "thursday")
			my should(textIsAWeekday("friday"), "friday")
			my should(textIsAWeekday("saturday"), "saturday")
			my should(textIsAWeekday("sunday"), "sunday")
		end tell
	end script

	script |contains weekday|
		property parent : UnitTest(me)

		tell dateutil's CalendarDate
			my should(textContainsWeekday("monday"), "monday")
			my should(textContainsWeekday("tuesday"), "tuesday")
			my should(textContainsWeekday("wednesday"), "wednesday")
			my should(textContainsWeekday("thursday"), "thursday")
			my should(textContainsWeekday("friday"), "friday")
			my should(textContainsWeekday("saturday"), "saturday")
			my should(textContainsWeekday("sunday"), "sunday")
			my refute(textContainsWeekday("notaday"), "notaday")
		end tell
	end script

	script |parse weekday|
		property parent : UnitTest(me)

		tell dateutil's CalendarDate
			my shouldEqual(Monday, textToWeekday("monday"))
			my shouldEqual(Tuesday, textToWeekday("tuesday"))
			my shouldEqual(Wednesday, textToWeekday("wednesday"))
			my shouldEqual(Thursday, textToWeekday("thursday"))
			my shouldEqual(Friday, textToWeekday("friday"))
			my shouldEqual(Saturday, textToWeekday("saturday"))
			my shouldEqual(Sunday, textToWeekday("sunday"))
		end tell
		
		testParseWeekdayFails("notaday")
		testParseWeekdayFails("next wednesday at 5:00pm")
			
	end script

	on testParseWeekdayFails(testValue) 
		try
			dateutil's CalendarDate's textToWeekday(testValue)
			fail("Error not raised.")
		on error message
			shouldEqual("Invalid day of week " & testValue & ".", message)
		end
	end testParseWeekdayFails
	
	script |contains weekday modifiers|
		property parent : UnitTest(me)
		
		tell dateutil's CalendarDate
			my should(textContainsWeekdayModifiers("next"), "next")
			my should(textContainsWeekdayModifiers("last"), "last")
			my should(textContainsWeekdayModifiers("last wednesday"), "last")
			
			my refute(textContainsWeekdayModifiers("some"), "some")
			my refute(textContainsWeekdayModifiers("wednesday"), "wednesday")
		end tell
		
	
	end script 
	
	script |text includes time|
		property parent : UnitTest(me)
		
		should(dateutil's CalendarDate's textIncludesTime("Sep 18, 2015 08:00AM"), "Text should include time.")
		should(dateutil's CalendarDate's textIncludesTime("2015-09-19 08:00AM"), "Text should include time.")
		should(dateutil's CalendarDate's textIncludesTime("2015-05-24 1:00PM"), "Should be true")
		refute(dateutil's CalendarDate's textIncludesTime("2015-05-24"), "Should be false")		
	end script
	
	on testNextWeekdayAbsolute(originalDate, expectedDateText, theWeekday)
		shouldEqual(date expectedDateText, (dateutil's CalendarDate's create on originalDate)'s nextWeekday(theWeekday)'s asDate())		
	end testNextWeekdayAbsolute

	script |next weekday absolute|
		property parent : UnitTest(me)
		
		set originalDate to date "Saturday, Sep 19, 2015 08:00:00AM"
		
		testNextWeekdayAbsolute(originalDate, "Sunday, Sep 20, 2015 08:00AM", Sunday)		
		testNextWeekdayAbsolute(originalDate, "Monday, Sep 21, 2015 08:00AM", Monday)		
		testNextWeekdayAbsolute(originalDate, "Tuesday, Sep 22, 2015 08:00AM", Tuesday)		
		testNextWeekdayAbsolute(originalDate, "Wednesday, Sep 23, 2015 08:00AM", Wednesday)		
		testNextWeekdayAbsolute(originalDate, "Thursday, Sep 24, 2015 08:00AM", Thursday)		
		testNextWeekdayAbsolute(originalDate, "Friday, Sep 25, 2015 08:00AM", Friday)		
		testNextWeekdayAbsolute(originalDate, "Saturday, Sep 26, 2015 08:00AM", Saturday)		
	end script

	on testLastWeekdayAbsolute(originalDate, expectedDateText, theWeekday)
		shouldEqual(date expectedDateText, (dateutil's CalendarDate's create on originalDate)'s lastWeekday(theWeekday)'s asDate())		
	end testLastWeekdayAbsolute

	script |last weekday absolute|
		property parent : UnitTest(me)
		
		set originalDate to date "Saturday, Sep 19, 2015 08:00:00AM"
		
		testLastWeekdayAbsolute(originalDate, "Friday, Sep 18, 2015 08:00AM", Friday)		
		testLastWeekdayAbsolute(originalDate, "Thursday, Sep 17, 2015 08:00AM", Thursday)		
		testLastWeekdayAbsolute(originalDate, "Wednesday, Sep 16, 2015 08:00AM", Wednesday)		
		testLastWeekdayAbsolute(originalDate, "Tuesday, Sep 15, 2015 08:00AM", Tuesday)		
		testLastWeekdayAbsolute(originalDate, "Monday, Sep 14, 2015 08:00AM", Monday)		
		testLastWeekdayAbsolute(originalDate, "Sunday, Sep 13, 2015 08:00AM", Sunday)		
		testLastWeekdayAbsolute(originalDate, "Saturday, Sep 12, 2015 08:00AM", Saturday)		
	end script
	
	
end script

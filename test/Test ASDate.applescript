(*!
	@header ASDate
		ASDate self tests.
	@abstract License: GNU GPL, see COPYING for details.
	@author Kraig Parkinson
	@copyright 2015 kraigparkinson
*)

property ASDate : script "com.kraigparkinson/ASDate"
use ASUnit : script "com.lifepillar/ASUnit"

property parent : ASUnit
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
		
		shouldEqual(6, ASDate's timezoneToOffset("0600"))
		--		shouldEqual(6.5, ASDate's timezoneToOffset("0630"))
		
	end script
	
	script |parse timestamp|
		property parent : UnitTest(me)
		
		set theMonth to "08"
		set theDay to "10"
		set theYear to "2015"
		set theTime to "23:11:58"
		
		shouldEqual(date "Monday, August 10, 2015 at 11:11:58 PM", date (theMonth & "/" & theDay & "/" & theYear & ", " & theTime))
		
		shouldEqual(date "Tuesday, August 11, 2015 at 11:11:58 PM", ASDate's parseTimestamp("2015-08-11T23:11:58-0600"))
		shouldEqual(date "Wednesday, August 12, 2015 at 12:11:58 AM", ASDate's parseTimestamp("2015-08-11T23:11:58-0700"))
		
	end script
	
	script |valid timestamp|
		property parent : UnitTest(me)
		
		should(ASDate's validTimestamp("2015-08-11T23:11:58-0600"), "'2015-08-11T23:11:58-0600' not parsed as valid timestamp as it should")
		refute(ASDate's validTimestamp("2015-08-11T23:11:58-06000"), "timestamp too long")
		refute(ASDate's validTimestamp("2015-08-11T23:11:58-060"), "timestamp too short")
		refute(ASDate's validTimestamp("2015-08-11, 23:11:58-0600"), "timestamp has no T")
		
		refute(ASDate's validTimestamp("2015-08-11T23:11:58"), "timestamp has no timezone")
	end script
	
	script |make pretty dates for OF without timezones and seconds|
		property parent : UnitTest(me)
		
		tell ASDate
			my shouldEqual("", reformatDateTimeStampToOF(""))
			--shouldEqual("STOP", reformatDateTimeStampToOF("STOP"))
			my shouldEqual("2015-06-19", reformatDateTimeStampToOF("2015-06-19"))
			my shouldEqual("17:25:39-0600", reformatDateTimeStampToOF("17:25:39-0600"))
			my shouldEqual("2015-06-19 at 17:25", reformatDateTimeStampToOF("2015-06-19T17:25:39-0600"))
		end tell
	end script
	
	script |can trim seconds from dates|
		property parent : UnitTest(me)
		
		tell ASDate
			my shouldEqual("", trimSeconds(""))
			my shouldEqual("17:25", trimSeconds("17:25"))
			my shouldEqual("17:25", trimSeconds("17:25:39"))
			my shouldEqual("2015-06-19T17:25", trimSeconds("2015-06-19T17:25:39"))
			my shouldEqual("2015-06-19T17:30", trimSeconds("2015-06-19T17:30:39"))
		end tell
	end script
	
	script |can trim time zones from dates|
		property parent : UnitTest(me)
		
		tell ASDate
			
			my shouldEqual("", trimTimeZone(""))
			my shouldEqual("2015-06-19T17:25:39", trimTimeZone("2015-06-19T17:25:39-0600"))
		end tell
	end script
	
	script |parse tasks without dates|
		property parent : UnitTest(me)
		
		tell ASDate
			
			my shouldEqual("Uncanny", tidyTaskName("Uncanny"))
			my shouldEqual("Uncanny $5m", tidyTaskName("Uncanny $5m"))
			my shouldEqual("Topical thing", tidyTaskName("Topical thing"))
			my shouldEqual("IATA project", tidyTaskName("IATA project"))
			
			my shouldEqual("Uncanny @Hygiene $5m", tidyTaskName("Uncanny @Hygiene $5m"))
			my shouldEqual("Uncanny set-up @Hygiene", tidyTaskName("Uncanny set-up @Hygiene"))
		end tell
	end script
	
	script |parse tasks with just Due Dates|
		property parent : UnitTest(me)
		
		tell ASDate
			
			my shouldEqual("Uncanny #2015-06-19 at 17:25", tidyTaskName("Uncanny #2015-06-19T17:25:39-0600"))
			my shouldEqual("Uncanny #2015-07-19 at 17:25 $5", tidyTaskName("Uncanny #2015-07-19T17:25:39-0600 $5"))
		end tell
	end script
	
	script |parse tasks with no subject and a due date|
		property parent : UnitTest(me)
		
		tell ASDate
			my shouldEqual("#2015-05-19 at 17:25", tidyTaskName("#2015-05-19T17:25:39-0600"))
		end tell
	end script
	
	script |parse tasks with hyphenated task names|
		property parent : UnitTest(me)
		
		tell ASDate
			
			my shouldEqual("Uncanny worlds-of-wonder #2015-06-19 at 17:25", tidyTaskName("Uncanny worlds-of-wonder #2015-06-19T17:25:39-0600"))
			my shouldEqual("Uncanny worlds-of-wonder #2015-06-19 at 00:00 #2015-06-20 at 17:00", tidyTaskName("Uncanny worlds-of-wonder #2015-06-19T00:00:39-0600 #2015-06-20T17:00:22-0600"))
		end tell
	end script
	
	script |parse tasks with due and defer dates|
		property parent : UnitTest(me)
		
		tell ASDate
			my shouldEqual("Uncanny #2015-06-19 at 17:25 #2015-06-21 at 17:00", tidyTaskName("Uncanny #2015-06-19T17:25:39-0600 #2015-06-21T17:00:00-0600"))
			my shouldEqual("Uncanny #2015-06-19 at 17:25 #2015-06-21 at 17:00 $5m", tidyTaskName("Uncanny #2015-06-19T17:25:39-0600 #2015-06-21T17:00:00-0600 $5m"))
		end tell
	end script
	
	script |parse tasks with Due Dates and Contexts|
		property parent : UnitTest(me)
		
		tell ASDate
			
			my shouldEqual("Uncanny @Hygiene #2015-06-19 at 17:25", tidyTaskName("Uncanny @Hygiene #2015-06-19T17:25:39-0600"))
			my shouldEqual("Uncanny @Hygiene #2015-06-19 at 17:25 #2015-06-20 at 17:00 $5m", tidyTaskName("Uncanny @Hygiene #2015-06-19T17:25:39-0600 #2015-06-20T17:00:39-0600 $5m"))
			my shouldEqual("Foo @Hygiene #2015-06-22 at 00:19 #2015-06-22 at 00:19 $5m", tidyTaskName("Foo @Hygiene #2015-06-22T00:19:43-0600 #2015-06-22T00:19:51-0600 $5m"))
		end tell
	end script
	
	
end script

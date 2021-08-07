@IsTest
private class CRIC_RapidAPIServiceTest {
	@TestSetup
	static void setup() {
		List<Cricket_Settings__c> configList = new List<Cricket_Settings__c>();

		Cricket_Settings__c host = new Cricket_Settings__c();
		host.name = 'CRIC_RAPID_API_HOST';
		host.value__c = 'dev132-cricket-live-scores-v1.p.rapidapi.com';
		configList.add(host);

		Cricket_Settings__c key = new Cricket_Settings__c();
		key.name = 'CRIC_RAPID_API_KEY';
		key.value__c = 'test1234keyhahaha';
		configList.add(key);

		Cricket_Settings__c url = new Cricket_Settings__c();
		url.name = 'CRIC_URL';
		url.value__c = 'http://test.com';
		configList.add(url);

		insert configList;
	}

	@IsTest
	static void shouldBuildHeadersWithHostAndKey() {
		Map<String, String> headers = CRIC_RapidAPIService.buildHeaders();

		System.assert(
			headers.get('X-RapidAPI-Host') ==
			'dev132-cricket-live-scores-v1.p.rapidapi.com',
			'X-RapidAPI-Host header is not set correctly'
		);
		System.assert(
			headers.get('X-RapidAPI-Key') == 'test1234keyhahaha',
			'X-RapidAPI-Key header is not set correctly'
		);
	}

	@IsTest
	static void shouldBuildScoreForFirstInnings() {
		String json = '{"meta":{"hasFullScorecard":true,"hasCompleted":false,"hasCommentary":true,"hasGraph":true,"hasPlayerProfile":true,"hasWagonWheel":true,"currentBattingTeam":7,"series":{"id":2181,"name":"ICC Men\'s Cricket World Cup 2019"},"currentRunRate":"5.52","matchName":"Match 7","matchType":"ODI","venueName":"Sophia Gardens Cardiff","currentInningsId":1,"currentDay":1},"matchDetail":{"teamBatting":{"score":"8-182","isBatting":true,"id":7,"name":"Sri Lanka Men","shortName":"SL","logoUrl":"https://www.cricket.com.au/-/media/Logos/Teams/International/Sri%20Lanka.ashx","backgroundImageUrl":"https://www.cricket.com.au/-/media/Logos/Teams/Team-Backgrounds/International/SL.ashx"},"teamBowling":{"score":"-","isBatting":false,"id":95,"name":"AFG","shortName":"AFG","logoUrl":"https://www.cricket.com.au/-/media/Logos/Teams/International/Afghanistan.ashx","backgroundImageUrl":"https://www.cricket.com.au/-/media/AFG.ashx"},"overs":[],"umpires":{"firstUmpire":{"name":"Llong, N J"},"secondUmpire":{"name":"Wilson, P"},"thirdUmpire":{"name":"Tucker, R J"},"referee":{"name":"Pycroft, A J"}},"matchSummary":{"id":43650,"matchTypeId":2,"statisticsProvider":"Opta Sports","series":{"id":2181,"name":"Men\'s ODI World Cup 2019","shieldImageUrl":"https://www.cricket.com.au/-/media/Logos/Series/2019/series-CWC19.ashx"},"name":"Match 7","status":"LIVE","venue":{"name":"Sophia Gardens, Cardiff","location":"","latitude":"","longitude":"","antisocialPhoneNumber":""},"homeTeam":{"isBatting":false,"id":95,"name":"Afghanistan Men","shortName":"AFG","logoUrl":"https://www.cricket.com.au/-/media/Logos/Teams/International/Afghanistan.ashx","backgroundImageUrl":"https://www.cricket.com.au/-/media/AFG.ashx","teamColour":"#344DC3"},"awayTeam":{"isBatting":true,"id":7,"name":"Sri Lanka Men","shortName":"SL","logoUrl":"https://www.cricket.com.au/-/media/Logos/Teams/International/Sri%20Lanka.ashx","backgroundImageUrl":"https://www.cricket.com.au/-/media/Logos/Teams/Team-Backgrounds/International/SL.ashx","teamColour":"#082AA2"},"currentMatchState":"LIVE - Rain Delay: SLA 8-182","isMultiDay":false,"matchSummaryText":"Rain Delay: SLA 8-182","scores":{"homeScore":"","homeOvers":"","awayScore":"8-182","awayOvers":"33.0"},"liveStreams":[],"isLive":false,"currentInningId":1,"isMatchDrawn":false,"isMatchAbandoned":false,"startDateTime":"2019-06-04T09:30:00Z","endDateTime":"2019-06-04T17:15:00Z","localStartDate":"4 June 2019","localStartTime":"10:30 AM","isWomensMatch":false,"cmsMatchType":"ODI","cmsMatchAssociatedType":"ODI","cmsMatchVenueStartDateTime":"","cmsMatchVenueEndDateTime":"","cmsMatchStartDate":"2019-06-04 10:30:00Z","cmsMatchEndDate":"2019-06-04 23:59","gamedayStatus":"","isGamedayEnabled":false,"removeMatch":false},"tossMessage":"Afghanistan won the toss and elected to bowl.","innings":[{"id":1,"teamId":7,"isDeclared":false,"name":"1st Inn Sri Lanka ","shortName":"SL","wickets":"8","runs":"182","score":"8-182","overs":"33.0"}],"currentBatters":[{"name":"Lasith Malinga","runs":"0","ballsFaced":"4","isFacing":true,"strikeRate":"0.00","id":3178},{"name":"Suranga Lakmal","runs":"2","ballsFaced":"4","isFacing":false,"strikeRate":"50.00","id":4290}],"bowler":{"name":"Dawlat Zadran","wickets":"1","runsAgainst":"19","bowlerOver":"4.0","economy":"4.75","strikeRate":"0.00","id":5136}},"status":200,"poweredBy":"dev132"}';
		String expectedScore = 'SL 8-182 33.0 ov (Lasith Malinga 0*, Suranga Lakmal 2, Dawlat Zadran 1-19) vs AFG - Rain Delay: SLA 8-182';
		System.assertEquals(
			expectedScore,
			CRIC_RapidAPIService.extractScoreFromResponse(json),
			'Score is not extracted correctly'
		);
	}

	@IsTest
	static void shouldBuildScoreForSecondInnings() {
		String json = '{"meta":{"hasFullScorecard":true,"hasCompleted":false,"hasCommentary":true,"hasGraph":true,"hasPlayerProfile":true,"hasWagonWheel":true,"currentBattingTeam":95,"series":{"id":2181,"name":"ICC Men\'s Cricket World Cup 2019"},"requiredRunRate":"4.27","currentRunRate":"6.34","matchName":"Match 7","matchType":"ODI","venueName":"Sophia Gardens Cardiff","currentInningsId":2,"currentDay":1},"matchDetail":{"teamBatting":{"score":"1-37","isBatting":true,"id":95,"name":"Afghanistan Men","shortName":"AFG","logoUrl":"https://www.cricket.com.au/-/media/Logos/Teams/International/Afghanistan.ashx","backgroundImageUrl":"https://www.cricket.com.au/-/media/AFG.ashx"},"teamBowling":{"score":"201","isBatting":false,"id":7,"name":"SL","shortName":"SL","logoUrl":"https://www.cricket.com.au/-/media/Logos/Teams/International/Sri%20Lanka.ashx","backgroundImageUrl":"https://www.cricket.com.au/-/media/Logos/Teams/Team-Backgrounds/International/SL.ashx"},"overs":[],"umpires":{"firstUmpire":{"name":"Llong, N J"},"secondUmpire":{"name":"Wilson, P"},"thirdUmpire":{"name":"Tucker, R J"},"referee":{"name":"Pycroft, A J"}},"matchSummary":{"id":43650,"matchTypeId":2,"statisticsProvider":"Opta Sports","series":{"id":2181,"name":"Men\'s ODI World Cup 2019","shieldImageUrl":"https://www.cricket.com.au/-/media/Logos/Series/2019/series-CWC19.ashx"},"name":"Match 7","status":"LIVE","venue":{"name":"Sophia Gardens, Cardiff","location":"","latitude":"","longitude":"","antisocialPhoneNumber":""},"homeTeam":{"isBatting":true,"id":95,"name":"Afghanistan Men","shortName":"AFG","logoUrl":"https://www.cricket.com.au/-/media/Logos/Teams/International/Afghanistan.ashx","backgroundImageUrl":"https://www.cricket.com.au/-/media/AFG.ashx","teamColour":"#344DC3"},"awayTeam":{"isBatting":false,"id":7,"name":"Sri Lanka Men","shortName":"SL","logoUrl":"https://www.cricket.com.au/-/media/Logos/Teams/International/Sri%20Lanka.ashx","backgroundImageUrl":"https://www.cricket.com.au/-/media/Logos/Teams/Team-Backgrounds/International/SL.ashx","teamColour":"#082AA2"},"currentMatchState":"LIVE - Live: AFG need 150 runs off 211 balls(D/L Method)","isMultiDay":false,"matchSummaryText":"Live: AFG need 150 runs off 211 balls(D/L Method)","scores":{"homeScore":"1-37","homeOvers":"5.5","awayScore":"201","awayOvers":"36.5"},"liveStreams":[],"isLive":false,"currentInningId":2,"isMatchDrawn":false,"isMatchAbandoned":false,"startDateTime":"2019-06-04T09:30:00Z","endDateTime":"2019-06-04T17:15:00Z","localStartDate":"4 June 2019","localStartTime":"10:30 AM","isWomensMatch":false,"cmsMatchType":"ODI","cmsMatchAssociatedType":"ODI","cmsMatchVenueStartDateTime":"","cmsMatchVenueEndDateTime":"","cmsMatchStartDate":"2019-06-04 10:30:00Z","cmsMatchEndDate":"2019-06-04 23:59","gamedayStatus":"","isGamedayEnabled":false,"removeMatch":false},"tossMessage":"Afghanistan won the toss and elected to bowl.","innings":[{"id":1,"teamId":7,"isDeclared":false,"name":"1st Inn Sri Lanka ","shortName":"SL","wickets":"10","runs":"201","score":"201","overs":"36.5"},{"id":2,"teamId":95,"isDeclared":false,"name":"1st Inn Afghanistan ","shortName":"AFG","wickets":"1","runs":"37","score":"1-37","overs":"5.5"}],"currentBatters":[{"name":"Rahmat Shah","runs":"1","ballsFaced":"3","isFacing":false,"strikeRate":"33.33","id":5745},{"name":"Hazratullah Zazai","runs":"27","ballsFaced":"20","isFacing":true,"strikeRate":"135.00","id":10844}],"bowler":{"name":"Isuru Udana","wickets":"0","runsAgainst":"3","bowlerOver":"0.5","economy":"3.60","strikeRate":"0.00","id":4490}},"status":200,"poweredBy":"dev132"}';
		String expectedScore = 'AFG 1-37 5.5 ov (Rahmat Shah 1, Hazratullah Zazai 27*, Isuru Udana 0-3) vs SL 201 36.5 ov - Live: AFG need 150 runs off 211 balls(D/L Method)';
		System.assertEquals(
			expectedScore,
			CRIC_RapidAPIService.extractScoreFromResponse(json)
		);
	}
}

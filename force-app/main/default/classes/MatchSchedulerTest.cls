@IsTest
private class MatchSchedulerTest {
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
		url.name = 'CRIC_MATCHES_URL';
		url.value__c = 'http://test.com';
		configList.add(url);

		Cricket_Settings__c seriesId = new Cricket_Settings__c();
		seriesId.name = 'CRIC_SERIES_ID';
		seriesId.value__c = '2181';
		configList.add(seriesId);

		Cricket_Settings__c matchId = new Cricket_Settings__c();
		matchId.name = 'CRIC_MATCH_ID';
		matchId.value__c = '';
		configList.add(matchId);

		insert configList;
	}

	@IsTest
	static void shouldCallAPIWhenScheduled() {
		// Given
		// Throw exception so that cric_match_id custom setting isn't created/updated.
		HttpCalloutMock mock = new HttpCalloutMock(200)
			.whenUrlContains('/matches.php')
			.throwException();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, mock);
		// When
		MatchScheduler sch = new MatchScheduler();
		System.schedule('test match id fetch', '0 0 0 3 9 ? 2028', sch);
		Test.stopTest();
		System.assert(
			String.isBlank(
				Cricket_Settings__c.getAll().get('CRIC_MATCH_ID').value__c
			),
			'should not have updated the match id custom setting'
		);
	}
}

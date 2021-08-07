public without sharing class CRIC_MatchHelper {
	public static final String MATCHES_URL = CRIC_Utils.getCricketSetting(
		'CRIC_MATCHES_URL'
	);

	@future(callout=true)
	public static void populateMatchIds() {
		List<String> matchIds = CRIC_MatchHelper.getMatchIds(Date.today());
		System.debug(
			LoggingLevel.INFO,
			'populateMatchIds> matchIds :' + matchIds
		);
		if (matchIds != null && !matchIds.isEmpty()) {
			String commaSeparatedMatchIds = String.join(matchIds, ',');
			Map<String, Cricket_Settings__c> orgConfigMap = Cricket_Settings__c.getAll();
			Cricket_Settings__c matchConfig = orgConfigMap.get(
				CRIC_LiveScoreService.CUSTOM_SETTING_CRIC_MATCH_ID
			);
			matchConfig.Value__c = commaSeparatedMatchIds;
			if (
				Schema.sObjectType.Cricket_Settings__c.fields.Value__c.isUpdateable()
			) {
				update matchConfig;
			}
		}
	}

	public static List<String> getMatchIds(Date whenDate) {
		try {
			String responseJSON = CRIC_CalloutHelper.doGet(MATCHES_URL);
			String seriesId = CRIC_Utils.getCricketSetting('CRIC_SERIES_ID');
			return extractMatchIds(
				responseJSON,
				Integer.valueOf(seriesId),
				whenDate
			);
		} catch (Exception ex) {
			return null;
		}
	}

	// Fetch match ids of those matches that are on the same day as "whenDate"
	private static List<String> extractMatchIds(
		String responseJSON,
		Integer seriesId,
		Date whenDate
	) {
		List<String> matchIds = new List<String>();

		Map<String, Object> responseObjMap = (Map<String, Object>) JSON.deserializeUntyped(
			responseJSON
		);
		Map<String, Object> matchListObj = (Map<String, Object>) responseObjMap.get(
			'matchList'
		);
		List<Object> matches = (List<Object>) matchListObj.get('matches');

		for (Object matchObj : matches) {
			Map<String, Object> matchObjMap = (Map<String, Object>) matchObj;
			Integer matchId = (Integer) matchObjMap.get('id');
			Integer seriesIdInResponse = getSeriesId(matchObjMap);
			if (seriesId != seriesIdInResponse) {
				continue;
			}

			// Check if this match is on same day as "whenDate"
			if (isMatchOnSameDay(matchObjMap, whenDate)) {
				matchIds.add(String.valueOf(matchId));
			}
		}
		return matchIds;
	}

	private static Integer getSeriesId(Map<String, Object> matchObjMap) {
		Map<String, Object> seriesMap = (Map<String, Object>) matchObjMap.get(
			'series'
		);
		return (Integer) seriesMap.get('id');
	}

	private static Boolean isMatchOnSameDay(
		Map<String, Object> matchObjMap,
		Date whenDate
	) {
		String matchDateStr = (String) matchObjMap.get('startDateTime');
		Date matchDate = Date.valueOf(matchDateStr);
		return whenDate.isSameDay(matchDate);
	}
}

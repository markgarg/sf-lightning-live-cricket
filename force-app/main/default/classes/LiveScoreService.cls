public with sharing class LiveScoreService {
	public static final String CUSTOM_SETTING_CRIC_MATCH_ID = 'CRIC_MATCH_ID';
	public static final String CUSTOM_SETTING_CRIC_SERIES_ID = 'CRIC_SERIES_ID';
	public static final String CACHE_KEY_TEMPLATE = 'CRIC{0}';

	@AuraEnabled
	public static List<String> getLiveScore() {
		String matchIdCommaSeparated = Utils.getCricketSetting(
			CUSTOM_SETTING_CRIC_MATCH_ID
		);
		String seriesId = Utils.getCricketSetting(
			CUSTOM_SETTING_CRIC_SERIES_ID
		);

		List<String> matchIds = matchIdCommaSeparated.split(',');
		Boolean scoreDoesntExist = false;
		List<String> scores = new List<String>();
		for (String matchId : matchIds) {
			String key = getCacheKey(matchId);
			if (!Cache.Org.contains(key)) {
				scoreDoesntExist = true;
				break;
			}
			scores.add((String) Cache.Org.get(key));
		}
		if (scoreDoesntExist) {
			scores.clear();
			scores.addAll(fetchLiveScoreFromAPI(seriesId, matchIds));
		}

		return scores;
	}

	public static List<String> fetchLiveScoreFromAPI(
		final String seriesId,
		final List<String> matchIds
	) {
		List<String> scores = new List<String>();

		for (String matchId : matchIds) {
			String liveScore = RapidAPILiveScoreService.fetchLiveScoreFromAPI(
				seriesId,
				matchId
			);
			scores.add(liveScore);

			if (String.isNotBlank(liveScore)) {
				// Also add to cache
				String key = getCacheKey(matchId);
				System.debug(
					LoggingLevel.INFO,
					'Putting ' +
					liveScore +
					' in ' +
					key +
					' of cache'
				);
				Cache.org.put(key, liveScore, 300);
			}
		}

		return scores;
	}

	private static String getCacheKey(String matchId) {
		return String.format(CACHE_KEY_TEMPLATE, new List<String>{ matchId });
	}

	public class LiveScoreForMatch {
		public String de;
		public String si;
		public String matchId;
	}

	public class CalloutHelperException extends Exception {
	}
}

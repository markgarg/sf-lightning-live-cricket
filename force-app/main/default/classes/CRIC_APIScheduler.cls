public class CRIC_APIScheduler implements Queueable, Database.AllowsCallouts {
	public static final String CUSTOM_SETTING_CRIC_SLEEP_MILLIS = 'CRIC_SLEEP_MILLIS';

	public void execute(QueueableContext sc) {
		String matchIdCommaSeparated = CRIC_Utils.getCricketSetting(
			CRIC_LiveScoreService.CUSTOM_SETTING_CRIC_MATCH_ID
		);
		String seriesId = CRIC_Utils.getCricketSetting(
			CRIC_LiveScoreService.CUSTOM_SETTING_CRIC_SERIES_ID
		);

		List<String> matchIds = matchIdCommaSeparated.split(',');
		CRIC_LiveScoreService.fetchLiveScoreFromAPI(seriesId, matchIds);
		String sleepTimeMillis = CRIC_Utils.getCricketSetting(
			CUSTOM_SETTING_CRIC_SLEEP_MILLIS
		);
		sleep(Long.valueOf(sleepTimeMillis));
		System.enqueueJob(new CRIC_APIScheduler());
	}

	public static void sleep(Long milliSeconds) {
		Long timeDiff = 0;
		DateTime firstTime = System.now();
		do {
			timeDiff = System.now().getTime() - firstTime.getTime();
		} while (timeDiff <= milliSeconds);
	}
}

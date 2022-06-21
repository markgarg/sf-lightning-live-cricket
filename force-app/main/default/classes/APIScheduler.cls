public class APIScheduler implements Queueable, Database.AllowsCallouts {
	public static final String CUSTOM_SETTING_CRIC_SLEEP_MILLIS = 'CRIC_SLEEP_MILLIS';

	public void execute(QueueableContext sc) {
		String matchIdCommaSeparated = Utils.getCricketSetting(
			LiveScoreService.CUSTOM_SETTING_CRIC_MATCH_ID
		);
		String seriesId = Utils.getCricketSetting(
			LiveScoreService.CUSTOM_SETTING_CRIC_SERIES_ID
		);

		List<String> matchIds = matchIdCommaSeparated.split(',');
		LiveScoreService.fetchLiveScoreFromAPI(seriesId, matchIds);
		String sleepTimeMillis = Utils.getCricketSetting(
			CUSTOM_SETTING_CRIC_SLEEP_MILLIS
		);
		sleep(Long.valueOf(sleepTimeMillis));
		System.enqueueJob(new APIScheduler());
	}

	public static void sleep(Long milliSeconds) {
		Long timeDiff = 0;
		DateTime firstTime = System.now();
		do {
			timeDiff = System.now().getTime() - firstTime.getTime();
		} while (timeDiff <= milliSeconds);
	}
}

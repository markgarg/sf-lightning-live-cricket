global class CRIC_MatchScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		CRIC_MatchHelper.populateMatchIds();
	}
}

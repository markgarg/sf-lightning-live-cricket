global class MatchScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		MatchHelper.populateMatchIds();
	}
}

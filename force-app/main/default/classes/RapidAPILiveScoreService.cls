public without sharing class RapidAPILiveScoreService {
	public static final String URL = Utils.getCricketSetting('CRIC_URL');
	public static final String SCORE_TEMPLATE = '{0} {1} ({2}, {3}) vs {4}{5} - {6}';
	public static final String SCORE_TEMPLATE_UPCOMING = '{0} vs {1} - {2}';
	public static final String MATCH_STATUS_UPCOMING = 'UPCOMING';

	public static String fetchLiveScoreFromAPI(
		final String seriesId,
		final String matchId
	) {
		String liveScoreURL = String.format(
			URL,
			new List<String>{ seriesId, matchId }
		);
		String responseJSON = CalloutHelper.doGet(liveScoreURL);

		return extractScoreFromResponse(responseJSON);
	}

	public static String extractScoreFromResponse(String jsonResponse) {
		try {
			RapidAPIResponse rapidAPIResponse = (RapidAPIResponse) JSON.deserialize(
				jsonResponse,
				RapidAPIResponse.class
			);
			Team homeTeam = rapidAPIResponse.matchDetail.matchSummary.homeTeam;
			Team awayTeam = rapidAPIResponse.matchDetail.matchSummary.awayTeam;

			if (
				MATCH_STATUS_UPCOMING.equalsIgnoreCase(
					rapidAPIResponse.matchDetail.matchSummary.status
				)
			) {
				return String.format(
					SCORE_TEMPLATE_UPCOMING,
					new List<String>{
						homeTeam.shortName,
						awayTeam.shortName,
						MATCH_STATUS_UPCOMING
					}
				);
			}
			Team teamThatsBatting = homeTeam.isBatting ? homeTeam : awayTeam;
			Team teamThatsBowling = homeTeam.isBatting ? awayTeam : homeTeam;
			Boolean isHomeTeamBatting = homeTeam.isBatting;

			String currentBattingScore = getBattingScore(
				rapidAPIResponse.matchDetail.matchSummary.scores,
				isHomeTeamBatting
			);
			String bowlingScore = getBattingScore(
				rapidAPIResponse.matchDetail.matchSummary.scores,
				!isHomeTeamBatting
			);
			if (String.isNotBlank(bowlingScore)) {
				bowlingScore = ' ' + bowlingScore;
			}

			String batsmenScore = getCurrentBatsmenScore(
				rapidAPIResponse.matchDetail.currentBatters
			);
			String bowlerStats = getCurrentBowlerStats(
				rapidAPIResponse.matchDetail.bowler
			);
			System.debug('bowlingScore :' + bowlingScore + ':::');
			System.debug(
				'rapidAPIResponse.matchDetail.matchSummary.matchSummaryText :' +
				rapidAPIResponse.matchDetail.matchSummary.matchSummaryText
			);
			String score = String.format(
				SCORE_TEMPLATE,
				new List<String>{
					teamThatsBatting.shortName,
					currentBattingScore,
					batsmenScore,
					bowlerStats,
					teamThatsBowling.shortName,
					bowlingScore,
					rapidAPIResponse.matchDetail.matchSummary.matchSummaryText
				}
			);
			System.debug('score :' + score);
			return score.trim();
		} catch (Exception ex) {
			System.debug(LoggingLevel.INFO, 'exception ex:' + ex);
			System.debug(LoggingLevel.INFO, ex.getStackTraceString());
		}
		return null;
	}

	private static String getBattingScore(
		Scores scores,
		Boolean isHomeTeamBatting
	) {
		if (scores == null) {
			return '';
		}
		String battingScoreTemplate = '{0} {1} ov';
		String score;
		String overs;
		if (isHomeTeamBatting) {
			score = scores.homeScore;
			overs = scores.homeOvers;
		} else {
			score = scores.awayScore;
			overs = scores.awayOvers;
		}
		return String.isBlank(score)
			? ''
			: String.format(
					battingScoreTemplate,
					new List<String>{ score, overs }
			  );
	}

	private static String getCurrentBatsmenScore(
		List<CurrentBatter> currentBatters
	) {
		String batsmenScore = '';

		for (CurrentBatter batsman : currentBatters) {
			if (String.isNotBlank(batsmenScore)) {
				batsmenScore += ', ';
			}
			batsmenScore += batsman.name + ' ';
			batsmenScore += batsman.runs;
			batsmenScore += batsman.isFacing ? '*' : '';
		}

		return batsmenScore;
	}

	private static String getCurrentBowlerStats(Bowler bowler) {
		return String.format(
			'{0} {1}-{2}',
			new List<String>{ bowler.name, bowler.wickets, bowler.runsAgainst }
		);
	}

	public class RapidAPIResponse {
		public MatchDetail matchDetail;
	}

	public class MatchDetail {
		public MatchSummary matchSummary;
		public List<CurrentBatter> currentBatters;
		public Bowler bowler;
	}

	public class MatchSummary {
		public Team homeTeam;
		public Team awayTeam;
		public Scores scores;
		public String matchSummaryText;
		public String status;
	}

	public class Team {
		public Boolean isBatting;
		public String shortName;
	}

	public class Scores {
		public String homeScore;
		public String homeOvers;
		public String awayScore;
		public String awayOvers;
	}

	public class CurrentBatter {
		public String name;
		public String runs;
		public Boolean isFacing;
	}

	public class Bowler {
		public String name;
		public String wickets;
		public String runsAgainst;
	}
}

public without sharing class CRIC_RapidAPIService {
	public static final String URL = CRIC_Utils.getCricketSetting('CRIC_URL');
	public static final String SCORE_TEMPLATE = '{0} {1} ({2}, {3}) vs {4}{5} - {6}';
	public static final String CUSTOM_SETTING_CRIC_RAPID_API_HOST = 'CRIC_RAPID_API_HOST';
	public static final String CUSTOM_SETTING_CRIC_RAPID_API_KEY = 'CRIC_RAPID_API_KEY';

	public static String fetchLiveScoreFromAPI(
		final String seriesId,
		final String matchId
	) {
		String liveScoreURL = String.format(
			URL,
			new List<String>{ seriesId, matchId }
		);
		Map<String, String> headers = buildHeaders();

		HttpResponse response = CRIC_CalloutHelper.makeHTTPCallout(
			liveScoreURL,
			'GET',
			headers,
			null
		);
		System.debug(LoggingLevel.INFO, 'response :' + response.getBody());
		if (response.getStatusCode() / 100 == 4) {
			throw new CRIC_CalloutHelperException(
				'Callout failed - ' + response.getBody()
			);
		}

		return extractScoreFromResponse(response.getBody());
	}

	public static String extractScoreFromResponse(String jsonResponse) {
		try {
			RapidAPIResponse rapidAPIResponse = (RapidAPIResponse) JSON.deserialize(
				jsonResponse,
				RapidAPIResponse.class
			);
			Team homeTeam = rapidAPIResponse.matchDetail.matchSummary.homeTeam;
			Team awayTeam = rapidAPIResponse.matchDetail.matchSummary.awayTeam;

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
		}
		return null;
	}

	private static String getBattingScore(
		Scores scores,
		Boolean isHomeTeamBatting
	) {
		String battingScoreTemplate = '{0} {1} ov';
		String score, overs;
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

	@TestVisible
	private static Map<String, String> buildHeaders() {
		String rapidAPIHost = CRIC_Utils.getCricketSetting(
			CUSTOM_SETTING_CRIC_RAPID_API_HOST
		);
		String rapidAPIKey = CRIC_Utils.getCricketSetting(
			CUSTOM_SETTING_CRIC_RAPID_API_KEY
		);
		Map<String, String> headers = new Map<String, String>();
		headers.put('X-RapidAPI-Host', rapidAPIHost); //'dev132-cricket-live-scores-v1.p.rapidapi.com');
		headers.put('X-RapidAPI-Key', rapidAPIKey); //'db22a0d764msh13fe99049a0a1eep1af391jsn57f2f81848b1');

		return headers;
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

	public class CRIC_CalloutHelperException extends Exception {
	}
}

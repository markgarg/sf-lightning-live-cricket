@SuppressWarnings('PMD.ExcessiveParameterList')
public class CRIC_CalloutHelper {
	public static final String CUSTOM_SETTING_CRIC_RAPID_API_HOST = 'CRIC_RAPID_API_HOST';
	public static final String CUSTOM_SETTING_CRIC_RAPID_API_KEY = 'CRIC_RAPID_API_KEY';

	public static String doGet(String url) {
		Map<String, String> headers = buildHeaders();

		HttpResponse response = makeHTTPCallout(url, 'GET', headers, null);
		if (response.getStatusCode() / 100 == 4) {
			throw new CRIC_CalloutHelperException(
				'Callout failed - ' + response.getBody()
			);
		}
		return response.getBody();
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
		headers.put('X-RapidAPI-Host', rapidAPIHost);
		headers.put('X-RapidAPI-Key', rapidAPIKey);

		return headers;
	}

	public static HttpResponse makeHTTPCallout(
		final String url,
		final String method,
		final Map<String, String> headers,
		final String body
	) {
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(url);
		req.setMethod(method);

		if (headers != null) {
			for (String key : headers.keyset()) {
				req.setHeader(key, headers.get(key));
			}
		}
		if (String.isNotBlank(body)) {
			req.setBody(body);
		}

		HttpResponse res = h.send(req);
		return res;
	}

	public class CRIC_CalloutHelperException extends Exception {
	}
}

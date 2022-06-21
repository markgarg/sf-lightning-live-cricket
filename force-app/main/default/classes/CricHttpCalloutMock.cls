@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class CricHttpCalloutMock implements HttpCalloutMock {
	public Integer statusCode { get; set; }
	public String body { get; set; }
	public Map<String, String> headers { get; set; }
	private Map<String, String> responseConditionMap;
	private Map<String, StatusBody> responseStatusCodeConditionMap;
	private String httpMethod;
	private String status;
	private String urlContains;
	private Boolean throwExceptionOnRespond = false;
	public HttpRequest request { get; set; }
	private String requestURLShouldContain;
	private String requestBodyShouldContain;

	public CricHttpCalloutMock(Integer statusCode) {
		this(null, statusCode, '', '', new Map<String, String>());
	}

	public CricHttpCalloutMock(
		String httpMethod,
		Integer statusCode,
		String status,
		String body,
		Map<String, String> headers
	) {
		this.httpMethod = httpMethod;
		this.statusCode = statusCode;
		this.status = status;
		this.body = body;
		this.headers = headers;
		this.responseConditionMap = new Map<String, String>();
		this.responseStatusCodeConditionMap = new Map<String, StatusBody>();
	}

	public CricHttpCalloutMock whenUrlContains(String urlContains) {
		this.urlContains = urlContains;
		return this;
	}

	public CricHttpCalloutMock respondWith(Integer statusCode, String body) {
		this.statusCode = statusCode;
		if (String.isNotBlank(this.urlContains)) {
			this.responseStatusCodeConditionMap.put(
				this.urlContains,
				new StatusBody(statusCode, body)
			);
		} else {
			this.body = body;
		}
		return this;
	}

	public CricHttpCalloutMock respondWith(String body) {
		if (String.IsNotBlank(urlContains)) {
			responseConditionMap.put(urlContains, body);
		} else {
			this.body = body;
		}
		return this;
	}

	public CricHttpCalloutMock throwException() {
		throwExceptionOnRespond = true;
		return this;
	}

	public String getResponseBody(HTTPRequest request) {
		for (String key : responseConditionMap.keySet()) {
			if (
				request.getEndpoint().contains(key) ||
				request.getBody().contains(key)
			) {
				return responseConditionMap.get(key);
			}
		}
		return this.body;
	}

	public StatusBody getResponseStatusCodeBody(HTTPRequest request) {
		for (String key : responseStatusCodeConditionMap.keySet()) {
			if (
				request.getEndpoint().contains(key) ||
				request.getBody().contains(key)
			) {
				return responseStatusCodeConditionMap.get(key);
			}
		}
		return null;
	}

	public String getRequestHeader(String key) {
		return this.request.getHeader(key);
	}

	public CricHttpCalloutMock checkIfURLContains(
		String requestURLShouldContain
	) {
		this.requestURLShouldContain = requestURLShouldContain;
		return this;
	}

	public HTTPResponse respond(HTTPRequest httpRequest) {
		request = httpRequest;
		HttpResponse response = new HttpResponse();
		Integer tempStatusCode = this.statusCode;

		String tempBody;
		System.debug(
			LoggingLevel.INFO,
			'respond> responseStatusCodeConditionMap :' +
			responseStatusCodeConditionMap
		);
		if (!responseStatusCodeConditionMap.isEmpty()) {
			StatusBody sb = getResponseStatusCodeBody(request);
			System.debug(LoggingLevel.INFO, 'respond> sb :' + sb);
			tempStatusCode = sb.statusCode;
			tempBody = sb.body;
		} else {
			tempBody = getResponseBody(request);
		}
		System.debug(
			LoggingLevel.INFO,
			'respond> tempStatusCode :' + tempStatusCode
		);
		System.debug(LoggingLevel.INFO, 'respond> tempBody :' + tempBody);
		response.setStatusCode(tempStatusCode);
		response.setStatus(this.status);
		response.setBody(tempBody);

		if (headers != null) {
			for (String header : headers.keySet()) {
				String value = headers.get(header);
				response.setHeader(header, value);
			}
		}

		if (String.isNotBlank(this.requestURLShouldContain)) {
			System.debug(
				LoggingLevel.INFO,
				'requestURLShouldContain >' + requestURLShouldContain
			);
			System.debug(
				LoggingLevel.INFO,
				'request.getEndpoint() >' + request.getEndpoint()
			);
			System.assert(
				request.getEndpoint().contains(this.requestURLShouldContain),
				'request endpoint should contain the expected URL'
			);
		}

		if (throwExceptionOnRespond) {
			throw new CalloutHelper.CalloutHelperException('Test');
		}

		return response;
	}

	public class StatusBody {
		public String body;
		public Integer statusCode;

		public StatusBody(Integer sc, String b) {
			this.statusCode = sc;
			this.body = b;
		}
	}
}

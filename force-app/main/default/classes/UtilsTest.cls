@isTest
private class UtilsTest {
	@isTest
	static void shouldReturnNullIfNoKeyPresent() {
		String shouldBeNull = Utils.getCricketSetting(
			'noKeyExistsWIthThisName'
		);
		System.assert(
			shouldBeNull == null,
			'should be null when no key exists'
		);
	}

	@isTest
	static void shouldReturnValueIfKeyPresent() {
		insert new Cricket_Settings__c(Name = 'foo', Value__c = 'bar');

		String value = Utils.getCricketSetting('foo');

		System.assert(
			value.equals('bar'),
			'should return correct value when key exists'
		);
	}
}

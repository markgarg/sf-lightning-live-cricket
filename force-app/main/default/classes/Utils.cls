public without sharing class Utils {
	public static String getCricketSetting(String key) {
		Map<String, Cricket_Settings__c> settings = Cricket_Settings__c.getAll();
		return settings?.containsKey(key) ? settings.get(key).Value__c : null;
	}
}

({
	doInit: function (component, event, helper) {
		const getUserRoleName = component.get("c.getUserRoleName");
		// Set up the callback
		var self = this;
		helper.fetchScore(component, helper);
		//execute fetchScore() again after 10 sec each
		const intervalId = window.setInterval(
			$A.getCallback(function () {
				try {
					helper.fetchScore(component, helper);
				} catch (err) {
					console.error(err);
					// Remove the refresh on error
					window.clearInterval(intervalId);
				}
			}),
			10000
		);
	}
});

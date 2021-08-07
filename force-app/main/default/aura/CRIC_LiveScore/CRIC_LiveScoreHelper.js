({
	fetchScore: function (component, helper) {
		const action = component.get("c.getLiveScore");
		// Set up the callback
		var self = this;
		action.setCallback(this, function (response) {
			// Checking the server response state
			const state = response.getState();
			if (state === "SUCCESS") {
				// Process server success response
				const scores = response.getReturnValue();
				component.set("v.liveScores", scores);
			}
		});
		$A.enqueueAction(action);
	}
});

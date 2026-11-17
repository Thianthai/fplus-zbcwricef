sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"com/fplus/bc/zbcwricef/test/integration/pages/WricefMasterList.gen",
	"com/fplus/bc/zbcwricef/test/integration/pages/WricefMasterObjectPage.gen"
], function (JourneyRunner, WricefMasterListGenerated, WricefMasterObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('com/fplus/bc/zbcwricef') + '/test/flp.html#app-preview',
        pages: {
			onTheWricefMasterListGenerated: WricefMasterListGenerated,
			onTheWricefMasterObjectPageGenerated: WricefMasterObjectPageGenerated
        },
        async: true
    });

    return runner;
});


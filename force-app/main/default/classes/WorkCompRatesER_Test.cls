@IsTest
private class WorkCompRatesER_Test {
	@IsTest static void parseJson() {
		String json = '{"CLIENTID":"900028","DATALIST":[{"STATE":"CA","WCCODE":"1000","WCRATE":0},{"STATE":"CA","WCCODE":"1803","WCRATE":11.7527},{"STATE":"CA","WCCODE":"5027","WCRATE":14.428},{"STATE":"CA","WCCODE":"5028","WCRATE":8.758},{"STATE":"CA","WCCODE":"5348","WCRATE":7.3072},{"STATE":"CA","WCCODE":"8227","WCRATE":8.5317},{"STATE":"CA","WCCODE":"8742","WCRATE":0.7321},{"STATE":"CA","WCCODE":"8810","WCRATE":0.6522},{"STATE":"NV","WCCODE":"1000","WCRATE":0},{"STATE":"NV","WCCODE":"1803","WCRATE":7.171},{"STATE":"NV","WCCODE":"5022","WCRATE":5.897},{"STATE":"NV","WCCODE":"5348","WCRATE":4.91},{"STATE":"NV","WCCODE":"8227","WCRATE":9.033},{"STATE":"NV","WCCODE":"8742","WCRATE":0.9},{"STATE":"NV","WCCODE":"8810","WCRATE":0.337}]}';
		WorkCompRatesER obj = WorkCompRatesER.parse(json);

		Assert.isTrue(obj.CLIENTID == '900028');
		Assert.isTrue(obj.DATALIST.size() == 15);
		Assert.isTrue(obj.DATALIST[0].State == 'CA');
		Assert.isTrue(obj.DATALIST[0].WCCODE == '1000');
		Assert.isTrue(obj.DATALIST[0].WCRATE == 0);
		Assert.isTrue(obj.DATALIST[0].DESCRIPTION == null);

		Assert.isTrue(obj.DATALIST[14].State == 'NV');
		Assert.isTrue(obj.DATALIST[14].WCCODE == '8810');
		Assert.isTrue(obj.DATALIST[14].WCRATE == 0.337);
	}
}
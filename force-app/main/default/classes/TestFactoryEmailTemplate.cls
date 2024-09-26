@isTest
public without sharing class TestFactoryEmailTemplate {

    public static EmailTemplate makeTemplate(String name) {
		return makeTemplate(name, null);
    }

    public static EmailTemplate makeTemplate(String name, Map<String,Object> fldMap) {
        EmailTemplate template;

		template = new EmailTemplate(
			isActive = true,
			Name = name,
			DeveloperName = 'TestTemplate_' + name,
			TemplateType = 'custom',
			FolderId = UserInfo.getUserId(),
			Subject = 'TEST EMAIL',
			HtmlValue =
				'<!DOCTYPE html><html>' +
				' <head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />' +
				'  <meta name="viewport" content="width=device-width, initialscale=1.0" />' +
				'  <meta http-equiv="X-UA-Compatible" content="IE=edge" />' +
				'  <style type="text/css">@media screen and (max-width: 480px) {slot[style] {margin-right: 0 !important;}.columnDiv {margin-right: 0 !important;}}@media screen and (min-width: 480px) {slot[style] {margin-bottom: 0 !important;}.columnDiv {margin-bottom: 0 !important;}}</style>  <style type="text/css">@media screen and (max-width: 480px) {.contentbuilderBaseColumnRow .columnCell {display:inline-block;width:100%}}</style>  <style type="text/css">.contentpageDefaultEmailTemplatePageTemplate .contentRoot {width: 600px;}@media only screen and (max-width: 480px) {.contentpageDefaultEmailTemplatePageTemplate .contentRoot {width: 320px;}}</style>' +
				'  </head> ' +
				' <body>Email To: {{{Recipient.Name}}}</body>' +
				'</html>'
		);

		if (fldMap != null) {
            template = (EmailTemplate) TestFactory.assignFields(fldMap, template);
        }

		return template;
    }

    public static EmailTemplate createTemplate(String name, Map<String,Object> fldMap) {
        EmailTemplate template = makeTemplate(name, fldMap);
        insert template;
        return template;
    }

    public static EmailTemplate createTemplate(String name) {
        EmailTemplate template = makeTemplate(name);
        insert template;
        return template;
    }
}
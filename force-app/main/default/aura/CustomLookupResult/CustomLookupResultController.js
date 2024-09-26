({
    doInit : function(component, event, helper) {
        var currentArticleUrl = window.location.href;
        var articleId = helper.getURLParameter('id');

        if (articleId != null) {
            console.log('article Id -->', articleId );
            component.set("v.articleId", articleId);
        }
    }
})
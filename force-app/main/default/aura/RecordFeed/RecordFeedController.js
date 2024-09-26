({
doInit : function(cmp,helper) {
    var currentArticleUrl = window.location.href;
    var articleId = helper.getURLParameter('id');
    $A.createComponent(
        "forceChatter:feed",
        {
            "type": "Record",
            "subjectId": articleId
        },
        function(recordFeed){
            //Add the new button to the body array
            if (cmp.isValid()) {
                var body = cmp.get("v.body");
                body.push(recordFeed);
                cmp.set("v.body", body);
            }
        }
    );
   },
 })
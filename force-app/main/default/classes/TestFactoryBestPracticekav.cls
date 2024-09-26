@isTest
public class TestFactoryBestPracticekav {
    /**
	 * @description createPracticeKav creates a new Best Practice Knowledge article version record in the database.
     * @param  title    Title of the Best Practice Knowledge article version
     * @param  summary  Summary of the Best Practice Knowledge article version
     * @param  urlName  UrlName of the Best Practice Knowledge article version
	 * @param  fldMap   additional field values for the Best Practice Knowledge article version
	 * @return Best_Practice__kav
	 */
	 public static Best_Practice__kav createPracticeKav( String title, String summary, String UrlName, Map<String, Object> fldMap) {
        Best_Practice__kav testpractice = makePracticeKav(title, summary, UrlName, fldMap);
        insert testpractice;
        return testpractice;
    }
    /**
	 * @description makePracticeKav makes a new Best Practice Knowledge article version record in the database.
	 * @param  title    Title of the Best Practice Knowledge article version
     * @param  summary  Summary of the Best Practice Knowledge article version
     * @param  urlName  UrlName of the Best Practice Knowledge article version
     * @param  fldMap   additional field values for the Best Practice Knowledge article version
	 * @return Best_Practice__kav
	 */
	 public static Best_Practice__kav makePracticeKav(String title, String summary, String UrlName, Map<String, Object> fldMap) {        
        Best_Practice__kav testpractice = new Best_Practice__kav(Title = title, Summary = summary, UrlName = urlName);
        if (fldMap != null) {
            testpractice = (Best_Practice__kav) TestFactory.assignFields(fldMap, testpractice);
        }
        return testpractice;
    }

}
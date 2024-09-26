/**
 * @description TestFactoryNote contains methods to create test Note.
 */
@isTest
public class TestFactoryNote {
    /**
	 * @description createNote create a Note in the database.
	 * @param  idParent   parent Id For Note
	 * @param  title     title For Note    
	 * @param  body     body For Note
	 * @param  fldMap 	additional field values for the Note
	 * @return Note
	 */
    public static Note createNote(Id idParent, String title, String body, Map<String, Object> fldMap){
        Note note = makeNote(idParent, title, body, fldMap);
        insert note;
        return note;
    }

    /**
	 * @description makeNote makes a Note in the database.
	 * @param  idParent   parent Id For Note
	 * @param  title     title For Note    
	 * @param  body     body For Note
	 * @param  fldMap 	additional field values for the Note
	 * @return Note
	 */
    public static Note makeNote(Id idParent, String title, String body, Map<String, Object> fldMap){
        Note note = new Note(
            ParentId = idParent,
            Title = title,
            Body = body
        );
        if(fldMap != null) {
			note = (Note) TestFactory.assignFields(fldMap, note);
		}
		return note;
    }
}
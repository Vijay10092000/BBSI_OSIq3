/*******************************************************************
 * Custom controller for the "Custom Iterator Component" AllorNothingPageBlock.vfc
 * Determines if a list should be rendered.
 *******************************************************************/
public with sharing class AllOrNothingController
{
    // the list to decide upon rendering
    public List<Sobject> values {get; set;}
    
    
    // should the list be rendered?  Returns true if the list has 
    // any values, otherwise false
    public Boolean getRender()
    {
        //system.debug('In GetRender!!');
        //system.debug('In GetRender values!!' + values);
        return (null!=values && !values.isEmpty());
    }
}
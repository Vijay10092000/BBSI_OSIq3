/**
 * @description Option holds information for an option in a picklist.
 */
public class Option implements Comparable {
	@AuraEnabled
	public String value;

	@AuraEnabled
	public String label;

	@AuraEnabled
	public Boolean selected;

	@AuraEnabled
	public Boolean required;

	/**
	 * @description Option constructor.  Value is used as label and selected is false.
	 * @param  value    value of option
	 */
	public Option(String value) {
		this.value = value;
		this.label = value;
		this.selected = false;
		this.required = false;
	}

	/**
	 * @description Option constructor.  Value is used as label.
	 * @param  value    value of option
	 * @param  selected Is option selected?
	 */
	public Option(String value, Boolean selected) {
		this.value = value;
		this.label = value;
		this.selected = selected;
	}

	/**
	 * @description Option constructor
	 * @param  value    value of option
	 * @param  label    label of option
	 * @param  selected Is option selected?
	 */
	public Option(String value, String label, Boolean selected) {
		this.value = value;
		this.label = label;
		this.selected = selected;
	}

	/**
	 * @description compareTo determines if this Option is before, same or after
	 * the given one.  Only the label is compared.
	 * @param  that  Option comparing
	 * @return negative if this is before that, 0 if same, positive if this is after that.
	 */
	public Integer compareTo(Object that) {
		Option t = (Option) that;
		return this.label.compareTo(t.label);
	}
}
public without sharing class WorkCompPolicyCodeRate 
{
	public List<DATA> DATALIST { get; set; }

	public class DATA 
	{
		public String WcPolicy { get; set; }
		public String State { get; set; }
		public String Code { get; set; }
		public Decimal Rate { get; set; }
	}
}
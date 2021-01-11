namespace OrderEntryPlanner.Components
{
	public class Event
	{
		public string id { get; set; }
		public string idOrderEntry { get; set; }
		public string title { get; set; }
		public string start { get; set; }
		public string end { get; set; }
        public string paziente { get; set; }
        public string regime { get; set; }
        public string priorita { get; set; }
        public string color { get; set; }
        public string borderColor { get; set; }
        public bool dataEditable { get; set; } = false;
    }
}
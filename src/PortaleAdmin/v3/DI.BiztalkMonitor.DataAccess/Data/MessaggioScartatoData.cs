using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Text;
using System.Xml.Linq;

namespace DI.BiztalkMonitor.DataAccess.Data
{
    public class MessaggioScartatoData
    {
        [DefaultValueAttribute(typeof(Guid), "{00000000-0000-0000-0000-000000000000}")]
        public Guid Id { get; set; } //(uniqueidentifier, not null)
        [Required]
        public DateTime DataMessaggio { get; set; } //(datetime, not null)
        [Required]
        [MaxLength(256)]
        public string NomeOrchestrazione { get; set; } //(varchar(256), not null)
        [MaxLength(64)]
        public string VersioneOrchestrazione { get; set; } //(varchar(64), null)
        [MaxLength(512)]
        public string DescrizioneErrore { get; set; } //(varchar(512), null)
        public DateTime DataModifica { get; set; } //(datetime, null)
        [MaxLength(64)]
        public string UtenteModifica { get; set; } //(varchar(64), null)
        [Required]
        public int IdStato { get; set; } //(int, not null)
        public XElement MessaggioOrchestrazione { get; set; } //(XML(.), null)
        [MaxLength(16)]
        public string DescrizioneStato { get; set; } //(varchar(16), null)
        [MaxLength(1024)]
        public string Note { get; set; } //(varchar(1024), null)
    }
}

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace DI.BiztalkMonitor.DataAccess.Data
{
        public class PortalAdminConfigurazioniData
        {
            [Required]
            [MaxLength(128)]
            public string Sessione { get; set; } //(varchar(128), not null)
            [Required]
            [MaxLength(64)]
            public string Chiave { get; set; } //(varchar(64), not null)
            [MaxLength(128)]
            public string Descrizione { get; set; } //(varchar(128), null)
            [MaxLength(1024)]
            public string ValoreString { get; set; } //(varchar(1024), null)
            public bool ValoreBoolean { get; set; } //(bit, null)
        }

}

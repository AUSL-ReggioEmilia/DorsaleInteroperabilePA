using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace DI.BiztalkMonitor.DataAccess.Data
{
    public class MessaggioScartatoStatoData
    {
            public int Id { get; set; } //(int, not null)
            [MaxLength(16)]
            public string Descrizione { get; set; } //(varchar(16), null)
    }
}

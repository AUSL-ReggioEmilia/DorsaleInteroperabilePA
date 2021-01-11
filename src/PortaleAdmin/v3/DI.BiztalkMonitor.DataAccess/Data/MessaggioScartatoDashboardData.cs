using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace DI.BiztalkMonitor.DataAccess.Data
{
    public class MessaggioScartatoDashboardData
    {
        public int NumeroMessaggiScartati { get; set; } //(int, null)
        [Required]
        [MaxLength(256)]
        public string NomeOrchestrazione { get; set; } //(varchar(256), not null)
        [MaxLength(64)]
        public string VersioneOrchestrazione { get; set; } //(varchar(64), null)

    }
}

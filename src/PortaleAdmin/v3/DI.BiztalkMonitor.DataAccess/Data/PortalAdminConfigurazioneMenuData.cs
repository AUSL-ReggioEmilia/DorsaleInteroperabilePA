using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace DI.BiztalkMonitor.DataAccess.Data
{
    public class PortalAdminConfigurazioneMenuData
    {
        public int Id { get; set; } //(int, not null)
        [Required]
        [MaxLength(100)]
        public string Titolo { get; set; } //(varchar(100), not null)
        [Required]
        [MaxLength(200)]
        public string Url { get; set; } //(varchar(200), not null)
        [Required]
        public int Ordine { get; set; } //(int, not null)
        [MaxLength(50)]
        public string RuoloLettura { get; set; } //(varchar(50), null)
    }
}

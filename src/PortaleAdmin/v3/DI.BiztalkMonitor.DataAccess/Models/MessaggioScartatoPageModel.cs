using DI.BiztalkMonitor.DataAccess.Data;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Text;
using System.Xml.Linq;

namespace DI.BiztalkMonitor.DataAccess.Models
{
    public class MessaggioScartatoPageModel
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
        /// <summary>
        /// Indica se lo la DescrizioneErrore è attualmente in anteprima o scritta per esteso
        /// </summary>
        public bool DescrizioneErroreIsPreview { get; set; } = true;

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


        //Property solo del PageModel
        public bool Checked { get; set; } = false;

        public bool IsNotClosed { get => IdStato != 2; }


        public static MessaggioScartatoPageModel CreateMessaggioScartatoPageModel(MessaggioScartatoData messaggio)
        {
            //
            // Crea MessaggioScartatoPageModel da MessaggioScartatoData
            //

            if (messaggio == null)
            {
                return null;
            }

            return new MessaggioScartatoPageModel()
            {
                Id = messaggio.Id,
                DataMessaggio = messaggio.DataMessaggio,
                NomeOrchestrazione = messaggio.NomeOrchestrazione,
                VersioneOrchestrazione = messaggio.VersioneOrchestrazione,
                DescrizioneErrore = messaggio.DescrizioneErrore,
                DataModifica = messaggio.DataModifica,
                UtenteModifica = messaggio.UtenteModifica,
                IdStato = messaggio.IdStato,
                MessaggioOrchestrazione = messaggio.MessaggioOrchestrazione,
                DescrizioneStato = messaggio.DescrizioneStato,
                Note = messaggio.Note
            };
        }

        public static List<MessaggioScartatoPageModel> CreateMessaggioScartatoPageModels(List<MessaggioScartatoData> messaggi)
        {
            //
            // Crea lista di MessaggioScartatoPageModel da lista di MessaggioScartatoData
            //
            if (messaggi == null)
            {
                return null;
            }

            List<MessaggioScartatoPageModel> retList = new List<MessaggioScartatoPageModel>();

            foreach (var item in messaggi)
            {
                retList.Add(CreateMessaggioScartatoPageModel(item));
            }
            return retList;
        }
    }
}

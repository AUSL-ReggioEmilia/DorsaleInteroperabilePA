using Dapper;
using DI.BiztalkMonitor.DataAccess.Data;
using DI.BiztalkMonitor.DataAccess.Models;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;

namespace DI.BiztalkMonitor.DataAccess.Adapters
{
    public class MessaggiScartatiAdapter : SqlAdapterBase
    {
        public MessaggiScartatiAdapter(IConfiguration config) : base(config)
        {

        }

        public async Task<List<MessaggioScartatoData>> GetAll(int periodo, string errore, int stato, string nomeOrchestrazione, string utente)
        {
            DateTime? dataDal = null;
            DateTime? dataAl = null;
            // Converto il periodo in date "dal" "al"
            switch (periodo)
            {
                // Caso "tutti" --> non faccio nulla pechè di default le date sono "null"
                case -1:
                    break;
                // Oggi
                case 1:
                    dataDal = DateTime.Today;
                    dataAl = DateTime.Today.AddDays(1).AddMilliseconds(-1);
                    break;
                // Ultimi 3 giorni
                case 3:
                    dataDal = DateTime.Today.AddDays(-3);
                    dataAl = DateTime.Today.AddDays(1).AddMilliseconds(-1);
                    break;
                // Ultima settimana
                case 7:
                    dataDal = DateTime.Today.AddDays(-7);
                    dataAl = DateTime.Today.AddDays(1).AddMilliseconds(-1);
                    break;
                // Ultimo mese
                case 30:
                    dataDal = DateTime.Today.AddMonths(-1);
                    dataAl = DateTime.Today.AddDays(1).AddMilliseconds(-1);
                    break;
            }

            DynamicParameters dynamicParameters = new DynamicParameters();
            dynamicParameters.Add("@DataDal", dataDal);
            dynamicParameters.Add("@DataAl", dataAl);
            dynamicParameters.Add("@Errore", errore);

            // Se lo STATO è -1, 3 oppure 4 torno i messaggi con qulsiasi stato --> passando null alla SP
            if (stato == -1 || stato == 3 || stato == 4)
            {
                dynamicParameters.Add("@Stato", null);
            }
            else
            {
                dynamicParameters.Add("@Stato", stato);
            }

            dynamicParameters.Add("@NomeOrchestrazione", nomeOrchestrazione);

            // Se l'UTENTE non è valorizzato passo "null" alla SP
            if (!String.IsNullOrEmpty(utente))
            {
                dynamicParameters.Add("@Utente", utente);

            }
            else
            {
                dynamicParameters.Add("@Utente", null);
            }


            IEnumerable<MessaggioScartatoData> result = await this.Connection.QueryAsync<MessaggioScartatoData>("[bt_recycle_bin_admin].[MessaggiOrchestrazioneCerca]",
                       dynamicParameters,
                       commandType: CommandType.StoredProcedure);

            return result.ToList();

        }

        public async Task<MessaggioScartatoData> GetById(Guid id)
        {
            DynamicParameters dynamicParameters = new DynamicParameters();
            dynamicParameters.Add("@Id", id);

            return await this.Connection.QuerySingleOrDefaultAsync<MessaggioScartatoData>("[bt_recycle_bin_admin].[MessaggiOrchestrazioneOttieni]",
                       dynamicParameters,
                       commandType: CommandType.StoredProcedure);

        }

        public async Task<List<MessaggioScartatoDashboardData>> GetDashboard()
        {
            IEnumerable<MessaggioScartatoDashboardData> result = await this.Connection.QueryAsync<MessaggioScartatoDashboardData>("[bt_recycle_bin_admin].[MessaggiOrchestrazioneDashboard]",
                       null,
                       commandType: CommandType.StoredProcedure);

            return result.ToList();
        }

        /// <summary>
        /// Ottiene tutti i nomi DISCTINCT delle orchestrazioni presenti sul DB
        /// </summary>
        /// <returns>Lista di stringhe</returns>
        public async Task<List<string>> GetNomiOrchestrazioni()
        {
            IEnumerable<string> result = await this.Connection.QueryAsync<string>("[bt_recycle_bin_admin].[MessaggiOrchestrazioneNomiLista]",
                       null,
                       commandType: CommandType.StoredProcedure);

            return result.ToList();
        }

        public async Task<MessaggioScartatoData> ChangeState(Guid id, int stato, string utente)
        {
            DynamicParameters dynamicParameters = new DynamicParameters();
            dynamicParameters.Add("@Id", id);
            dynamicParameters.Add("@IdStato", stato);
            dynamicParameters.Add("@UtenteModifica", utente);

            return await this.Connection.QuerySingleOrDefaultAsync<MessaggioScartatoData>("[bt_recycle_bin_admin].[MessaggiOrchestrazioneCambiaStato]",
                       dynamicParameters,
                       commandType: CommandType.StoredProcedure);

        }
    }
}

using Dapper;
using DI.BiztalkMonitor.DataAccess.Data;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DI.BiztalkMonitor.DataAccess.Adapters
{
    public class PortalAdminConfigurazioniAdapter : SqlAdapterBase
    {
        public PortalAdminConfigurazioniAdapter(IConfiguration config) : base(config)
        {
            //Imposto la connessione per il DB Portal Admin 
            Connection = new SqlConnection(config.GetConnectionString("PortalAdminConnectionString"));
        }

        /// <summary>
        /// Ottiene il sottotitolo del portale ottenuto dalle configurazioni sul Database
        /// </summary>
        /// <returns>PortalAdminConfigurazioniData</returns>
        public async Task<PortalAdminConfigurazioniData> GetSubTitle()
        {
            List<PortalAdminConfigurazioniData> listaConfig = await GetBySessione("MenuPortali");

            return listaConfig.Where(x => x.Chiave == "Subtitle").FirstOrDefault();
        }

        private async Task<List<PortalAdminConfigurazioniData>> GetBySessione(string sessione)
        {
            DynamicParameters dynamicParameters = new DynamicParameters();
            dynamicParameters.Add("@Sessione", sessione);

            IEnumerable<PortalAdminConfigurazioniData> result = await this.Connection.QueryAsync<PortalAdminConfigurazioniData>("[dbo].[ConfigurazioniOttieniBySessione]",
                       dynamicParameters,
                       commandType: CommandType.StoredProcedure);

            return result.ToList();
        }
    }
}

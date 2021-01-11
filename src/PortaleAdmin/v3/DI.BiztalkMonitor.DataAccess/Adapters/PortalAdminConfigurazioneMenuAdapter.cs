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
    public class PortalAdminConfigurazioneMenuAdapter : SqlAdapterBase
    {
        public PortalAdminConfigurazioneMenuAdapter(IConfiguration config) : base(config)
        {
            //Imposto la connessione per il DB Portal Admin 
            Connection = new SqlConnection(config.GetConnectionString("PortalAdminConnectionString"));
        }

        /// <summary>
        /// Ottiene l'URL della pagina informazioni del portale home ADMIN
        /// </summary>
        /// <returns></returns>
        public async Task<string> GetURLInformazioni()
        {
            List<PortalAdminConfigurazioneMenuData> menu = await GetAll();

            return menu.Where(x => x.Titolo == "Informazioni").FirstOrDefault().Url;
        }


        public async Task<List<PortalAdminConfigurazioneMenuData>> GetAll()
        {
            //Ottengo i parametri per generare il Menu Admin
            IEnumerable<PortalAdminConfigurazioneMenuData> result = await this.Connection.QueryAsync<PortalAdminConfigurazioneMenuData>("[dbo].[ConfigurazioneMenuLista1]",
                             null,
                       commandType: CommandType.StoredProcedure);

            return result.ToList();
        }
    }
}

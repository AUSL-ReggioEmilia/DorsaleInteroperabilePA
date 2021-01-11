using Dapper;
using DI.BiztalkMonitor.DataAccess.Data;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DI.BiztalkMonitor.DataAccess.Adapters
{
    public class MessaggiScartatiStatiAdapter : SqlAdapterBase
    {
        public MessaggiScartatiStatiAdapter(IConfiguration config) : base(config)
        {

        }

        public async Task<List<MessaggioScartatoStatoData>> GetAll()
        {
            IEnumerable<MessaggioScartatoStatoData> result = await this.Connection.QueryAsync<MessaggioScartatoStatoData>("[bt_recycle_bin_admin].[MessaggiOrchestrazioneStatiEnum]",
                       null,
                       commandType: CommandType.StoredProcedure);

            return result.ToList();
        }
    }
}

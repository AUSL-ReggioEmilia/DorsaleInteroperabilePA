using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace DI.BiztalkMonitor.DataAccess
{
    public interface IDBRepository
    {
        IConfiguration Configuration { get; set; }
        SqlConnection Connection { get; }

        Task<SqlTransaction> CreateTransactionAsync(IsolationLevel isolationLevel);

        Adapters.PortalAdminConfigurazioneMenuAdapter ConfigurazioneMenu { get; }
        Adapters.MessaggiScartatiAdapter MessaggiScartati { get; }
        Adapters.MessaggiScartatiStatiAdapter MessaggiScartatiStati { get; }
        Adapters.PortalAdminConfigurazioniAdapter ConfigurazioniAdmin { get; }
    }
}

using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace DI.BiztalkMonitor.DataAccess
{
    public class DBRepository : IDBRepository
    {
        private IConfiguration _config;

        public DBRepository(IConfiguration config)
        {
            _config = config;
        }

        // AdapterBase adapter = new AdapterBase(_dbRepository.Configuration);
        IConfiguration IDBRepository.Configuration { get => _config; set => _config = value; }

        SqlConnection IDBRepository.Connection { get => new Adapters.SqlAdapterBase(_config).Connection; }

        public Task<SqlTransaction> CreateTransactionAsync(IsolationLevel isolationLevel)
        {
            throw new NotImplementedException();
        }

        async Task<SqlTransaction> IDBRepository.CreateTransactionAsync(IsolationLevel isolationLevel)
        {
            SqlConnection conn = new Adapters.SqlAdapterBase(_config).Connection;
            await conn.OpenAsync();

            // Apro una transazione (livello "ReadCommitted"); 
            // vedi: https://docs.microsoft.com/it-it/dotnet/api/system.transactions.isolationlevel?view=netframework-4.8
            return (SqlTransaction)conn.BeginTransaction(isolationLevel);
        }

        Adapters.PortalAdminConfigurazioneMenuAdapter IDBRepository.ConfigurazioneMenu { get => new Adapters.PortalAdminConfigurazioneMenuAdapter(_config); }
        Adapters.MessaggiScartatiAdapter IDBRepository.MessaggiScartati { get => new Adapters.MessaggiScartatiAdapter(_config); }
        Adapters.MessaggiScartatiStatiAdapter IDBRepository.MessaggiScartatiStati { get => new Adapters.MessaggiScartatiStatiAdapter(_config); }
        Adapters.PortalAdminConfigurazioniAdapter IDBRepository.ConfigurazioniAdmin { get => new Adapters.PortalAdminConfigurazioniAdapter(_config); }


    }
}

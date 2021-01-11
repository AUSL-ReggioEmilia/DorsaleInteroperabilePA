using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;

namespace DI.BiztalkMonitor.DataAccess.Adapters
{
    public class SqlAdapterBase : IDisposable
    {
        protected SqlTransaction _transaction = null;
        protected SqlConnection _connection = null;
        protected IConfiguration _config;
        private bool _privateConnection;

        public SqlAdapterBase(IConfiguration config)
        {
            //
            // Costruttore: viene passata solamente la configurazione
            // (servirà per leggere la connection string dalle configurazioni)
            //
            _config = config;
        }

        public IConfiguration Configuration { get => _config; }

        public SqlConnection Connection
        {
            get
            {
                // If the connection is null, create a new connection from the connection string in appsettings
                if (_connection == null)
                {
                    // Reading the connection string from "appsettings.json"
                    _connection = new SqlConnection(Configuration.GetConnectionString("ConnectionString"));

                    _privateConnection = true;
                }

                return _connection;
            }
            set
            {
                _connection = value;
            }
        }

        public void JoinConnection(SqlConnection connection, SqlTransaction transaction)
        {
            _connection = connection;
            _transaction = transaction;
        }
        public void JoinTransaction(SqlTransaction transaction)
        {
            _connection = (SqlConnection)transaction.Connection;
            _transaction = transaction;
        }
        public SqlTransaction Transaction { get => _transaction; }

        public void Dispose()
        {
            // Solo se ho creato la connection privata
            if (_privateConnection)
            {
                if (_transaction != null)
                {
                    // Chiudo la transaction
                    _transaction.Dispose();
                }

                if (_connection != null)
                {
                    // Chiudo la connection 
                    if (_connection.State == ConnectionState.Open)
                        _connection.Close();
                    _connection.Dispose();
                }
            }
        }
    }
}

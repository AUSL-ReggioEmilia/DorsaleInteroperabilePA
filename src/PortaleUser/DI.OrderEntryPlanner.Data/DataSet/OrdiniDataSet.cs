using System;
using System.Data.SqlClient;

namespace DI.OrderEntryPlanner.Data.DataSet
{
}

namespace DI.OrderEntryPlanner.Data.DataSet
{
}

namespace DI.OrderEntryPlanner.Data.Ordini
{
	[global::System.ComponentModel.DataObject(true)]
	public class OrdiniTestateCercaTableAdapter : DataSet.OrdiniTableAdapters.OrdiniTestateCercaTableAdapter
	{
		public OrdiniTestateCercaTableAdapter()
		{
			try
			{
				SqlConnection connection = Connection;
				connection.ConnectionString = DataSet.OrdiniTableAdapters.DataAccess.instance.OePlannerConnectionString;
				Connection = connection;
			}
			catch (Exception)
			{
				throw;
			}
		}
	}

	[global::System.ComponentModel.DataObject(true)]
	public class OrdiniTestateOttieniTableAdapter : DataSet.OrdiniTableAdapters.OrdiniTestateOttieniTableAdapter
	{
		public OrdiniTestateOttieniTableAdapter()
		{
			try
			{
				SqlConnection connection = Connection;
				connection.ConnectionString = DataSet.OrdiniTableAdapters.DataAccess.instance.OePlannerConnectionString;
				Connection = connection;
			}
			catch (Exception)
			{
				throw;
			}
		}
	}

	[global::System.ComponentModel.DataObject(true)]
	public class OrdiniPrioritaListaTableAdapter : DataSet.OrdiniTableAdapters.OrdiniPrioritaListaTableAdapter
	{
		public OrdiniPrioritaListaTableAdapter()
		{
			try
			{
				SqlConnection connection = Connection;
				connection.ConnectionString = DataSet.OrdiniTableAdapters.DataAccess.instance.OePlannerConnectionString;
				Connection = connection;
			}
			catch (Exception)
			{
				throw;
			}
		}
	}

	[global::System.ComponentModel.DataObject(true)]
	public class OrdiniErogatiStatiListaTableAdapter : DataSet.OrdiniTableAdapters.OrdiniErogatiStatiListaTableAdapter
	{
		public OrdiniErogatiStatiListaTableAdapter()
		{
			try
			{
				SqlConnection connection = Connection;
				connection.ConnectionString = DataSet.OrdiniTableAdapters.DataAccess.instance.OePlannerConnectionString;
				Connection = connection;
			}
			catch (Exception)
			{
				throw;
			}
		}
	}

	[global::System.ComponentModel.DataObject(true)]
	public class OrdiniRegimiListaTableAdapter : DataSet.OrdiniTableAdapters.OrdiniRegimiListaTableAdapter
	{
		public OrdiniRegimiListaTableAdapter()
		{
			try
			{
				SqlConnection connection = Connection;
				connection.ConnectionString = DataSet.OrdiniTableAdapters.DataAccess.instance.OePlannerConnectionString;
				Connection = connection;
			}
			catch (Exception)
			{
				throw;
			}
		}
	}

	[global::System.ComponentModel.DataObject(true)]
	public class OrdiniSistemiErogantiListaTableAdapter : DataSet.OrdiniTableAdapters.OrdiniSistemiErogantiListaTableAdapter
	{
		public OrdiniSistemiErogantiListaTableAdapter()
		{
			try
			{
				SqlConnection connection = Connection;
				connection.ConnectionString = DataSet.OrdiniTableAdapters.DataAccess.instance.OePlannerConnectionString;
				Connection = connection;
			}
			catch (Exception)
			{
				throw;
			}
		}
	}

	[global::System.ComponentModel.DataObject(true)]
	public class OrdiniRigheOttieniByIdOrdineTestataTableAdapter : DataSet.OrdiniTableAdapters.OrdiniRigheOttieniByIdOrdineTestataTableAdapter
	{
		public OrdiniRigheOttieniByIdOrdineTestataTableAdapter()
		{
			try
			{
                SqlConnection connection = Connection;
				connection.ConnectionString = DataSet.OrdiniTableAdapters.DataAccess.instance.OePlannerConnectionString;
				Connection = connection;
			}
			catch (Exception)
			{
				throw;
			}
		}
	}

    [global::System.ComponentModel.DataObject(true)]
    public class QueriesTableAdapter : DataSet.OrdiniTableAdapters.QueriesTableAdapter
    {
        public QueriesTableAdapter()
        {
            try
            {

                foreach (var item in CommandCollection)
                {
                    item.Connection.ConnectionString = DataSet.OrdiniTableAdapters.DataAccess.instance.OePlannerConnectionString;
                }

            }
            catch (Exception)
            {
                throw;
            }
        }
    }
}

//namespace DI.OrderEntryPlanner.Data.DataSet
//{


//	partial class Ordini
//	{
//		partial class OrdiniRigheOttieniByIdOrdineTestataDataTable
//		{
//		}
//	}
//}
namespace DI.OrderEntryPlanner.Data.DataSet
{


	public partial class Ordini
	{
	}
}

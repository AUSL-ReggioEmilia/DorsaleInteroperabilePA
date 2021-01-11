using DI.PortalUser2.RoleManager;
using Serilog;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using DI.OrderEntryPlanner.Data.Ordini;
using static DI.OrderEntryPlanner.Data.DataSet.Ordini;

namespace OrderEntryPlanner.Components
{
	public class CustomDataSource
	{
		[DataObject]
		public class SistemiErogantiTableAdapter
		{
			[DataObjectMethod(DataObjectMethodType.Select, true)]
			public Dictionary<string, string> getData()
			{
				Dictionary<string, string> result = new Dictionary<string, string>();
				Dictionary<string, string> sistemiOfRuolo = new Dictionary<string, string>();
				Dictionary<string, string> sistemiEroganti = new Dictionary<string, string>();
				try
				{
					OrdiniSistemiErogantiListaDataTable dataTable;
					OrdiniSistemiErogantiListaTableAdapter tableAdapter = new OrdiniSistemiErogantiListaTableAdapter();

					using (tableAdapter)
					{
						dataTable = tableAdapter.GetData();
					}

					List<Sistema> sistemiRuoloTutti = PortalUserSingleton.instance.RoleManagerUtility.GetSistemi();

					var sistemiErogantiRuolo = (from sistema in sistemiRuoloTutti where (sistema.Erogante == true) select sistema).ToList();

					if (sistemiErogantiRuolo != null && sistemiErogantiRuolo.Count > 0)
					{

						foreach (var item in sistemiErogantiRuolo)
						{

							var sistema = (from sistemaOe in dataTable
										   where (sistemaOe.Attivo == true && sistemaOe.Erogante == true && sistemaOe.Codice == item.Codice && sistemaOe.CodiceAzienda == item.CodiceAzienda)
										   select sistemaOe).ToList();

							if (sistema != null && sistema.Count > 0)
							{
								var sistemaDefinitivo = sistema[0];
								result.Add($"{sistemaDefinitivo.Codice}@{sistemaDefinitivo.CodiceAzienda}", $"{sistemaDefinitivo.CodiceAzienda} - {item.Descrizione}");
							}
						}
					}
				}
				catch (Exception ex)
				{
					Log.Error(ex, ex.Message);
					throw;
				}
				return result;
			}
		}
	}
}
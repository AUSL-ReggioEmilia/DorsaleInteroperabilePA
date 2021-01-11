Imports System
Imports System.Data
Imports System.Linq
Imports System.Configuration
Imports System.ComponentModel
Imports System.Collections.Generic
Imports System.Web.Services
Imports DI.PortalUser2.Data
Imports DI.PortalUser2

Namespace DI.OrderEntry.User.Data

	<DataObjectAttribute(True)>
	Public NotInheritable Class DataAdapterManager

		Public Shared ReadOnly PortalAdminDataAdapterManager As PortalDataAdapterManager
		Public Shared ReadOnly DataAccess As RoleManager.DataAccess

		Private Sub New()

		End Sub

		Shared Sub New()

			PortalAdminDataAdapterManager = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			DataAccess = New RoleManager.DataAccess(My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)

		End Sub

		<WebMethod()>
		<DataObjectMethod(DataObjectMethodType.Select)>
		Public Shared Function GetLookupUOPerRuolo() As List(Of UnitaOperativa)

			Dim oRol = New RoleManagerUtility2(Global_asax.ConnectionStringPortalUser, My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
			Dim result = oRol.GetUnitaOperative()
			If result Is Nothing Then
				Return New List(Of UnitaOperativa)
			Else
				'2020-05-18 KYRY: Modificata la UnitaOperativa.descrizioneUo da uo.Descrizione a {uo.Descrizione} - ({uo.Codice}-{uo.CodiceAzienda}) per la visualizzazione corretta
				'2020-05-20 Leo: ri aggiunta la azienda nel codice (era stata rimossa per errore)
				Dim returnValue = From uo In result
								  Select New UnitaOperativa(uo.CodiceAzienda, uo.CodiceAzienda & "-" & uo.Codice, $"{uo.Descrizione} - ({uo.Codice}-{uo.CodiceAzienda})")

				Return returnValue.OrderBy(Function(uo) uo.DescrizioneUO).ToList()
			End If
		End Function

		''' <summary>
		''' Ottiene la lista dei Regimi di ricovero associati all'unità operativa passata
		''' </summary>
		<WebMethod()>
		<DataObjectMethod(DataObjectMethodType.Select)>
		Public Shared Function GetRegimiDiRicoveroPerUO(CodiceAzienda As String, CodiceUnitaOperativa As String) As List(Of RoleManager.Regime)
			Dim moRoleManagerUtility As New RoleManagerUtility2(Global_asax.ConnectionStringPortalUser, My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
			Return moRoleManagerUtility.GetRegimiByUnitaOperativa(CodiceAzienda, CodiceUnitaOperativa)
		End Function

	End Class

End Namespace
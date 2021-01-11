Imports DI.PortalUser2.Data
Imports System.Configuration
Imports System.Web
Imports System
Imports DI.OrderEntry.User
Imports System.Diagnostics

Public Class DatiUtente

	''' <summary>
	''' Chiavi tabella DatiUtente su DiPortalUser 
	''' Le chiavi relative al solo portale OE_USER iniziano per OE_USER_  
	''' Quelle cross-applicazioni USER inizano con DI_USER
	''' </summary>
	Public Enum Chiavi
		'
		' Opzioni per OE_USER
		'

		''' <summary>
		''' Ultimo Reparto di ricovero selezionato come filtro di ricerca
		''' </summary>
		OE_USER_REP_RIC_CODICE

		'
		' Opzioni per DI-USER (opzioni cross-applicazioni user)
		'

		''' <summary>
		''' memorizza ultimo ruolo usato dall'utente
		''' </summary>
		DI_USER_RUOLO_CORRENTE_CODICE

	End Enum

	Private Shared ReadOnly PortalUserConnString As String = Global_asax.ConnectionStringPortalUser

	Public Shared Function OttieniValore(Chiave As Chiavi) As String

		Try
			Dim oPortal = New PortalDataAdapterManager(PortalUserConnString)
			Return oPortal.DatiUtenteOttieniValore(HttpContext.Current.User.Identity.Name.ToUpper, Chiave.ToString, String.Empty)

		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(PortalUserConnString)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
			Debug.Assert(False, ex.Message)
			Return ""

		End Try

	End Function


	Public Shared Sub SalvaValore(Chiave As Chiavi, Valore As String)

		Try
			Dim oPortal = New PortalDataAdapterManager(PortalUserConnString)
			oPortal.DatiUtenteSalvaValore(HttpContext.Current.User.Identity.Name.ToUpper, Chiave.ToString, Valore)

		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(PortalUserConnString)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
			Debug.Assert(False, ex.Message)

		End Try

	End Sub


End Class

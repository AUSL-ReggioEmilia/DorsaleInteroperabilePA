Imports System
Imports System.Web
Imports System.Configuration
Imports DI.DataWarehouse.Admin.Data
Imports DI.PortalAdmin.Data

Namespace DI.DataWarehouse.Admin

    Public Class ApreAllegato
        Inherits System.Web.UI.Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

            Dim guidIdAllegato As Guid
            Try
                Try
                    '
                    ' Leggo parametri dal QueryString
                    '
                    guidIdAllegato = New Guid(Context.Request.QueryString(Constants.IdAllegato))
                Catch ex As Exception
                    '
                    ' Gestione dell'errore
                    '
                    Throw New Exception("Il parametro '" & Constants.IdAllegato & "' non è valido!")
                End Try
                '
                ' Creo data manager
                '
                Using ota As New RefertiDataSetTableAdapters.BevsApreAllegatoContentTableAdapter
                    Using odt As RefertiDataSet.BevsApreAllegatoContentDataTable = ota.GetData(guidIdAllegato)
                        If odt IsNot Nothing AndAlso odt.Rows.Count > 0 Then
                            Dim orow As RefertiDataSet.BevsApreAllegatoContentRow = odt(0)
                            If (Not orow.IsMimeDataNull) AndAlso (orow.MimeData.GetLength(0) > 0) Then
                                '
                                ' Toglie directory dal nome
                                '
                                Dim oFileInfo As System.IO.FileInfo
                                oFileInfo = New System.IO.FileInfo(orow.NomeFile)
                                Dim sFileName As String = oFileInfo.Name()
                                '
                                ' Scrivo il contenuto binario
                                '
                                Context.Response.Expires = 0
                                Context.Response.Clear()
                                Context.Response.BufferOutput = True
                                Context.Response.ContentType = orow.MimeType
                                Context.Response.AddHeader("content-disposition", "inline; filename=" & sFileName)
                                Context.Response.BinaryWrite(orow.MimeData)
                            Else
                                Call Context.Response.Write(FormatError("Impossibile visualizzare l'allegato: i dati dell'allegato non esistono!"))
                            End If
                        Else
                            Call Context.Response.Write(FormatError("Impossibile visualizzare l'allegato: i dati dell'allegato non esistono!"))
                        End If

                    End Using

                End Using

                '
                '2020-07-07 Kyrylo: Traccia Operazioni
                '
                Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Visualizzato allegato referto", idPaziente:=Nothing, Nothing, guidIdAllegato.ToString(), "IdAllegato")

            Catch ex As Exception

                Call Context.Response.Write(FormatError("Si è verificato un errore, contattare l'amministratore."))
                Try
                    Dim sMessage As String = Utility.TrapError(ex, True)

                Catch ex1 As Exception

                    Call Context.Response.Write(FormatError(ex1.Message))

                End Try
                '  Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                '  portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.DwhClinico)

            End Try

        End Sub

        Private Function FormatError(ByVal sMsg As String) As String
            sMsg = "DataWareHouse - Visualizzatore Allegati:<br />" & sMsg
            Return String.Format("<div style=""color: red; font-weight: bold; font-size: 11px; font-family: verdana, helvetica, arial, sans-serif;"">{0}</div>", sMsg)
        End Function

    End Class

End Namespace


'Imports System
'Imports System.Web
'Imports System.Linq

'Namespace DI.DataWarehouse.Admin

'    ''' <summary>
'    ''' Questo HTTP Handler fa da tramite per leggere un'immagine salvata su DB, l'immagine restituita viene scritta nella response 
'    ''' nel context corrente 
'    ''' </summary>
'    Public Class ImageHandler
'        Implements System.Web.IHttpHandler

'        Private Sub IHttpHandler_ProcessRequest(context As HttpContext) Implements IHttpHandler.ProcessRequest

'            Dim resourcetype As String = context.Request.QueryString("resourcetype")
'            Dim id As String = context.Request.QueryString("id")

'            If resourcetype IsNot Nothing And id IsNot Nothing Then

'                Dim file As Byte() = Nothing

'                Select Case resourcetype.ToLower
'                    Case "tiporeferto"
'                        context.Response.ContentType = "image/png"
'                        file = GetImageFromDB(id)
'                End Select

'                If file Is Nothing Then
'                    ImageNotFound(context)
'                Else
'                    context.Response.Buffer = True
'                    context.Response.BinaryWrite(file)
'                End If

'            End If
'        End Sub

'        Private Sub ImageNotFound(context As HttpContext)
'            'Dim img = System.Drawing.Image.FromFile("~\Images\ImageNotFound.png")
'            'Dim str As MemoryStream = New MemoryStream()

'            context.Response.Redirect("~/Images/ImageNotFound.png")

'        End Sub
'        ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
'            Get
'                Return False
'            End Get
'        End Property

'        ''' <summary>
'        ''' RECUPERA L'ICONA PER IL TIPO REFERTO; FUNZIONE CHIAMATA DALL'HANDLER IMAGEHANDLER.ASHX
'        ''' </summary>
'        ''' <param name="ID"></param>
'        ''' <returns></returns>
'        Public Shared Function GetImageFromDB(ID As String) As Byte()
'            Try
'                Using ta As New InfoDispositivoMedicoDataSetTableAdapters.BevsTipiRefertoCercaTableAdapter
'                    Dim dtd As InfoDispositivoMedicoDataSet.BevsTipiRefertoCercaDataTable = ta.GetData(Nothing, Nothing)

'                    If dtd.Count = 0 Then
'                        Return Nothing
'                    Else
'                        'Return dt(0).Icona

'                        Dim i = (From r As InfoDispositivoMedicoDataSet.BevsTipiRefertoCercaRow In dtd.Rows Where r.Id = New Guid(ID) Select r.Icona).ToList()

'                        If i IsNot Nothing AndAlso i.Count > 0 Then
'                            Return i.First()
'                        End If

'                        Return Nothing
'                    End If
'                End Using

'            Catch ex As Exception
'                GestioneErrori.TrapError(ex)
'                Return Nothing
'            End Try
'        End Function
'    End Class

'End Namespace


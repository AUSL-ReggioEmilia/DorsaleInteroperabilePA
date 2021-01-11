Imports System.Configuration
Imports System.ServiceModel.Configuration
Imports System.Reflection

Public Class frmMain

	Private Sub frmMain_Load(sender As System.Object, e As System.EventArgs) Handles MyBase.Load
		ToolbarSetup()

		'
		'Aggiungo in lista i metodi da testare, presi dal Namespace Methods
		'
		Dim listaMetodi = Assembly.GetExecutingAssembly().GetTypes().ToList().Where(Function(t) t.[Namespace] = "Tester.Methods" And t.IsPublic = True).ToList()
		For Each typeMetodo In listaMetodi
			Dim istanza = Activator.CreateInstance(typeMetodo)
			lstMetodi.Items.Add(istanza)
		Next

	End Sub

	Private Sub lstMetodi_Click(sender As Object, e As System.EventArgs) Handles lstMetodi.SelectedIndexChanged

		If TypeOf (lstMetodi.SelectedItem) Is BaseMethod Then
			Dim oMethod = DirectCast(lstMetodi.SelectedItem, BaseMethod)

			'Predispone i dati propri del metodo scelto e li mostra a video per poterli modificare
			oMethod.Setup()
			txtRequest.Text = oMethod.Serialize()
		End If

	End Sub

	Private Sub butInvoke_Click(sender As System.Object, e As System.EventArgs) Handles butInvoca.Click

		If TypeOf (lstMetodi.SelectedItem) Is BaseMethod Then
			If txtRequest.Text.Length = 0 Then
				txtResponse.Text = "Request non presente"
				Return
			End If
			Try
				panWait.Visible = True
				txtResponse.Text = ""
				lblResponse.Text = lstMetodi.SelectedItem.ToString
				Application.DoEvents()

				'genero una nuova istanza deserializzando l'xml a video
				Dim oNewInstance = BaseMethod.Deserialize(lstMetodi.SelectedItem.GetType, txtRequest.Text)

				'salvo la nuova istanza dell'oggetto nella listbox
				lstMetodi.SelectedItem = oNewInstance
				'lstMetodi.Items(lstMetodi.SelectedIndex) = oNewInstance

				'eseguo il metodo
				oNewInstance.Endpoint = GetSelectedEndpoint.Text
				Dim oRet = oNewInstance.Execute
				'serializzo il response
				If oRet IsNot Nothing Then
					txtResponse.Text = GenericSerializer.Serialize(oRet)
				Else
					txtResponse.Text = "[Nothing]"
				End If

				lblResponse.Text = lstMetodi.SelectedItem.ToString & " Response"

			Catch ex As Exception
				txtResponse.Text = "ECCEZIONE LATO CLIENT:" & vbCrLf & ex.Message
			Finally
				panWait.Visible = False
			End Try
		End If

	End Sub


#Region "User interface"

	Private Sub ToolbarSetup()
		Me.Text = Me.Text & " " & Application.ProductVersion

		'Pulsante Endopint 
		Dim clientSection = TryCast(ConfigurationManager.GetSection("system.serviceModel/client"), ClientSection)
		Dim endpointCollection = TryCast(clientSection.ElementInformation.Properties(String.Empty).Value, ChannelEndpointElementCollection)
		For Each Endpoint As ChannelEndpointElement In endpointCollection
			Dim MenuItem = New ToolStripMenuItem(Endpoint.Name)
			ddlEndpoint.DropDownItems.Add(MenuItem)
			MenuItem.CheckOnClick = True
			MenuItem.Name = Endpoint.Name

			If (Diagnostic.InDebug And Endpoint.Name.Contains("Debug")) Or _
			 (Not Diagnostic.InDebug And Endpoint.Name.Contains("Release")) Then
				MenuItem.Checked = True
			End If
			AddHandler MenuItem.CheckStateChanged, AddressOf MenuItmEndpoint_CheckStateChanged
		Next

		'Pulsante Impostazioni
		Dim toolDrop = DirectCast(butConfigurazione.DropDown, ToolStripDropDownMenu)
		toolDrop.ShowCheckMargin = False
		toolDrop.ShowImageMargin = False
		Dim hostTool = New ToolStripControlHost(PropertyGridConfig)
		toolDrop.Items.Add(hostTool)
		PropertyGridConfig.SelectedObject = My.Settings
	End Sub

	Private Function GetSelectedEndpoint() As ToolStripMenuItem
		For Each itm In ddlEndpoint.DropDownItems
			If DirectCast(itm, ToolStripMenuItem).Checked Then
				Return DirectCast(itm, ToolStripMenuItem)
			End If
		Next
		Throw New Exception("Selezionare un endpoint.")
	End Function

	Private Sub MenuItmEndpoint_CheckStateChanged(sender As Object, e As System.EventArgs)
		If DirectCast(sender, ToolStripMenuItem).Checked Then
			For Each itm In DirectCast(sender, ToolStripMenuItem).GetCurrentParent().Items
				If itm IsNot sender Then
					DirectCast(itm, ToolStripMenuItem).Checked = False
				End If
			Next
		End If
	End Sub

	Private Sub butPulisci_Click(sender As System.Object, e As System.EventArgs) Handles butPulisci.Click
		txtRequest.Text = ""
		txtResponse.Text = ""
		lblResponse.Text = ""
	End Sub

	Private Sub Textbox_KeyUp(sender As Object, e As System.Windows.Forms.KeyEventArgs) Handles txtResponse.KeyUp, txtRequest.KeyUp
		If e.Control And e.KeyCode = Keys.A Then
			DirectCast(sender, TextBox).SelectAll()
		End If
	End Sub

	Private Sub frmMain_Resize(sender As System.Object, e As System.EventArgs) Handles MyBase.Resize
		Try
			lblSpacer.Width = Me.Size.Width - 420
		Catch
		End Try
	End Sub

#End Region


End Class

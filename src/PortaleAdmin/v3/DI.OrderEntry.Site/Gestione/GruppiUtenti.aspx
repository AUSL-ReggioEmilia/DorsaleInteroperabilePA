<%@ Page Title="Order Entry - Configurazione Gruppi Utenti" Language="vb" AutoEventWireup="false" MasterPageFile="~/OrderEntry.Master"
	CodeBehind="GruppiUtenti.aspx.vb" Inherits="DI.OrderEntry.Admin.GruppiUtenti" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder" runat="server">
	<table id="filterPanel" runat="server" class="toolbar">
		<tr>
			<td colspan="7">
				<br />
			</td>
		</tr>
		<tr>
			<td>
				Descrizione:
			</td>
			<td>
				<asp:TextBox ID="CodiceDescrizioneFiltroTextBox" runat="server" />
			</td>
			<td nowrap="nowrap">
				Utente nel Gruppo:
			</td>
			<td>
				<asp:TextBox ID="UtenteFiltroTextBox" runat="server" />
			</td>
            <td nowrap="nowrap">
				Note
			</td>
			<td>
				<asp:TextBox ID="txtNote" runat="server" />
			</td>
			<td style="width: 100%">
				<asp:Button ID="CercaButton" runat="server" CssClass="Button" Text="Cerca" OnClick="CaricaGruppi" />
			</td>
		</tr>
		<tr>
			<td colspan="7">
				<br />
			</td>
		</tr>
	</table>
	<asp:Label ID="ErrorLabel" runat="server" Text="error" Visible="false" CssClass="Error"></asp:Label>
	<div id="toolbarAzioni" style="padding: 3px;">
		<input id="newButton" type="button" class="addLongButton" onclick="AggiungiGruppo(); return false;" value="Nuovo"
			title="aggiunge un nuovo gruppo" />
		<input id="ImportFromCsvButton" type="button" class="csvLongButton" value="Importa" title="importa da file CSV"
			onclick="PopUpDialogImportaDaCsv(450,370); return false;" />
	</div>
	<asp:GridView ID="GridViewGruppiUtenti" runat="server" AutoGenerateColumns="False" AllowPaging="True" AllowSorting="True"
		DataKeyNames="ID" DataSourceID="ObjectDataSourceGruppiUtenti" EnableModelValidation="True" PageSize="100" Style="width: 100%;
		margin-top: 5px;" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom" CssClass="Grid" HeaderStyle-CssClass="Header"
		AlternatingRowStyle-CssClass="GridAlternatingItem" PagerStyle-CssClass="Pager">
		<Columns>
			<asp:TemplateField HeaderText="Modifica gruppo">
				<ItemTemplate>
					<asp:ImageButton ID="EditButton" CssClass="ImageButton" runat="server" CommandArgument='<%# Eval("ID") %>' ToolTip="Modifica il gruppo di utenti"
						ImageUrl="~/Images/edititem.gif" OnClientClick='<%# "ModificaGruppo(""" & Eval("ID").ToString() & """, """ & Eval("Descrizione").ToString() & """,""" & Eval("Note").ToString() & """); return false;"%>' />
				</ItemTemplate>
			</asp:TemplateField>
			<asp:TemplateField HeaderText="Modifica utenti del gruppo">
				<ItemTemplate>
					<asp:ImageButton ID="EditPrestazioniButton" CssClass="ImageButton" runat="server" CommandArgument='<%# Eval("ID") %>'
						ToolTip="Modifica gli utenti appartenenti al gruppo" ImageUrl="~/Images/stato.gif" OnClientClick='<%# "OpenUtentiDialog(""" & Eval("ID").ToString() & """, """ & Eval("Descrizione").ToString() & """); return false;"%>' />
				</ItemTemplate>
			</asp:TemplateField>
			<asp:BoundField DataField="CountUtenti" HeaderText="Utenti Inclusi" ReadOnly="True" SortExpression="CountUtenti" />
			<asp:BoundField DataField="ID" HeaderText="ID" ReadOnly="True" SortExpression="ID" Visible="false" />
			<asp:TemplateField HeaderText="Descrizione" SortExpression="Descrizione">
				<HeaderStyle HorizontalAlign="Center" Width="50%" />
				<ItemTemplate>
					<asp:Label ID="DescrizioneLabel" runat="server" Text='<%# Bind("Descrizione") %>' />
				</ItemTemplate>
			</asp:TemplateField>
			<asp:BoundField DataField="Note" HeaderText="Note" HeaderStyle-Width="50%"
                        SortExpression="Note" />
			<asp:TemplateField HeaderText="Elimina">
				<ItemTemplate>
					<asp:ImageButton ID="DeleteButton" CssClass="ImageButton" runat="server" CommandName="Elimina" CommandArgument='<%# Eval("ID") %>'
						ToolTip="Elimina il gruppo di utenti" ImageUrl="~/Images/delete.gif" OnClientClick="return confirm('Si conferma l\'eliminazione dell\'elemento?');" />
				</ItemTemplate>
			</asp:TemplateField>
		</Columns>
	</asp:GridView>
	<asp:ObjectDataSource ID="ObjectDataSourceGruppiUtenti" runat="server" DeleteMethod="Delete" InsertMethod="Insert"
		OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiGruppiUtentiListTableAdapter"
		UpdateMethod="Update">
		<InsertParameters>
			<asp:Parameter Name="Descrizione" Type="String" />
            <asp:Parameter Name="Note" Type="String" />
		</InsertParameters>
		<SelectParameters>
			<asp:ControlParameter ControlID="CodiceDescrizioneFiltroTextBox" Name="Descrizione" PropertyName="Text" Type="String" />
			<asp:ControlParameter ControlID="UtenteFiltroTextBox" Name="Utente" PropertyName="Text" Type="String" />
            <asp:ControlParameter ControlID="txtNote" Name="Note" PropertyName="Text" Type="String" />
		</SelectParameters>
		<UpdateParameters>
			<asp:Parameter DbType="Guid" Name="ID" />
			<asp:Parameter Name="Descrizione" Type="String" />
            <asp:Parameter Name="Note" Type="String" />
		</UpdateParameters>
	</asp:ObjectDataSource>
	<div id="NewOrEditGruppoUtenti" style="display: none; padding: 5px;">
		<table style="width: 100%; border-collapse: collapse; padding: 5px;">
			<tr>
				<td>
					Descrizione:
				</td>
				<td style="width: 100%;">
					<input type="text" id="gruppo_utenti_descrizione" style="width: 180px;" />
					<span style="color: red; margin-left: 5px; display: none;">campo obbligatorio</span>
				</td>
            </tr>
            <tr>
                <td>
					Note:
				</td>
				<td style="width: 100%;">
                    <asp:TextBox TextMode="MultiLine" Rows="3" runat="server" ID="gruppo_utenti_note" ClientIDMode="Static" style="width:180px;margin-bottom:20px;"/>  
				</td>
			</tr>
		</table>
	</div>
	<div id="UtentiGruppoUtenti" style="display: none; padding: 5px;">
		<table id="splitterUtentiGruppoUtenti" style="height: 400px; width: 100%">
			<tr>
				<td style="width: 50%; vertical-align: top;">
					<fieldset style="height: 100%;">
						<legend>Utenti o gruppi inclusi</legend>
						<div id="selettoreUtentiGruppo" style="padding: 5px;">
							<div id="selettoreUtentiFiltroGruppo">
								<div style="float: left;">
									<span>Utente o gruppo:</span><br />
									<input id="descrizioneFiltroUtenteGruppo" type="text" style="height: 22px; width: 300px;" onkeydown="if(event.keyCode == 13){FiltraUtentiGruppo();}" />
								</div>
								<div style="float: left; margin-left: 3px; margin-top: 15px;">
									<input id="selettoreUtentiFiltroButtonGruppo" type="button" class="searchButton" onclick="FiltraUtentiGruppo(); return false;"
										style="width: 80px; text-align: center;" value="Cerca" />
								</div>
								<img id="loaderGruppo" src="../Images/refresh.gif" style="display: none; float: left; margin-top: 18px; margin-left: 5px;" />
							</div>
							<div class="separator">
							</div>
							<div id="Utenti" style="overflow-y: auto; height: 350px; max-height: 350px; margin-top: 5px; border: 1px solid #c0c0c0;">
							</div>
						</div>
					</fieldset>
				</td>
				<td style="vertical-align: middle;">
					<input id="addUtenti" type="button" class="leftArrowButton" onclick="AddUtenti(); return false;" title="Inserisci" />
					<br />
					<input id="removeUtenti" type="button" class="rightArrowButton" onclick="RemoveUtenti(); return false;" title="Rimuovi" />
				</td>
				<td style="width: 50%; vertical-align: top;">
					<fieldset style="height: 100%;">
						<legend>Aggiungi utenti o gruppi</legend>
						<div id="selettoreUtenti" style="padding: 5px;">
							<div id="selettoreUtentiFiltro">
								<div style="float: left;">
									<span>Utente o gruppo:</span><br />
									<input id="descrizioneFiltro" type="text" style="height: 22px; width: 300px;" onkeydown="if(event.keyCode == 13){CercaUtenti();}" />
								</div>
								<div style="float: left; margin-left: 3px; margin-top: 15px;">
									<input id="selettoreUtentiFiltroButton" type="button" class="searchButton" onclick="CercaUtenti(); return false;"
										style="width: 80px; text-align: center;" value="Cerca" />
								</div>
								<img id="loader" src="../Images/refresh.gif" style="display: none; float: left; margin-top: 18px; margin-left: 5px;" />
							</div>
							<div class="separator">
							</div>
							<div id="listaUtenti" style="overflow-y: auto; height: 350px; max-height: 350px; margin-top: 5px; border: 1px solid #c0c0c0;">
							</div>
						</div>
					</fieldset>
				</td>
			</tr>
		</table>
	</div>
	<div id="importaDaCsv" style="display: none; padding: 5px; text-align: center; padding: 25px;">
		<p>
			Selezionare il file CSV da importare, la struttura deve essere:<br />
			 <code>Nome Gruppo,Utente o Gruppo AD, Note</code>
		</p>
		<asp:FileUpload ID="CsvFileUpload" runat="server" Width="300px" />
		<asp:Button ID="ImportButton" runat="server" CssClass="importFake" Text="Importa" ToolTip="Importa da file CSV"
			Style="display: none;" CauseValidation="false" OnClick="ImportButton_Click"></asp:Button>
	</div>	
	<script src="../Scripts/gruppi-utenti.js?<%# Reflection.Assembly.GetExecutingAssembly.GetName.Version.ToString %>" type="text/javascript"></script>
</asp:Content>

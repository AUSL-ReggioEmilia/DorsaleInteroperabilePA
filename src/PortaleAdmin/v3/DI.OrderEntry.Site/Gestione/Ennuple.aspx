<%@ Page Title="Order Entry - Configurazione Ennuple" Language="vb" AutoEventWireup="false"
	MasterPageFile="~/OrderEntry.Master" CodeBehind="Ennuple.aspx.vb" Inherits="DI.OrderEntry.Admin.Ennuple" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder"
	runat="server">
	<style type="text/css">
		.GridItem1 /*ABILITATO*/
		{
			cursor: default;
		}
		.GridItem2 /*DISABILITATO*/
		{
			cursor: default;
			background-color: #E4E4E4;
			color: #6F6F6F;
			text-decoration: line-through;
		}
		.GridItem3 /*SIMULAZIONE*/
		{
			cursor: default;
			background-color: #E4F4E4;
		}
	</style>
	<img id="loader" src="../Images/refresh.gif" style="display: none; float: left;" />
	<div id="filterPanel" runat="server" style="width: 100%;">
		<fieldset style="width: 100%;">
			<legend>Ricerca</legend>
			<table style="border-collapse: collapse;" class="ui-accordion">
				<tr style="padding: 4px;">
					<td>
						NOT:
						<br />
						<asp:DropDownList ID="NotFiltroDropDownList" runat="server" CssClass="GridCombo"
							Width="153px">
							<asp:ListItem Value="" Text="(Tutti)" Selected="true"></asp:ListItem>
							<asp:ListItem Value="false" Text="Solo logica positiva"></asp:ListItem>
							<asp:ListItem Value="true" Text="Solo logica negativa"></asp:ListItem>
						</asp:DropDownList>
					</td>
					<td>
						Gruppo di Order Entry:
						<br />
						<asp:TextBox ID="GruppoUtentiFiltroTextBox" runat="server" Text="" />
					</td>
					<td>
						Unità operativa:
						<br />
						<asp:DropDownList ID="UnitaOperativaFiltroDropDownList" runat="server" DataSourceID="UnitaOperativeObjectDataSource"
							DataTextField="Descrizione" DataValueField="Id" AppendDataBoundItems="true" CssClass="GridCombo"
							Width="300px">
							<asp:ListItem Value="" Text="(Tutte)"></asp:ListItem>
						</asp:DropDownList>
					</td>
					<td>
						Descrizione:
						<br />
						<asp:TextBox ID="DescrizioneFiltroTextBox" runat="server" Text="" Width="153px" />
					</td>
					<td>
					</td>
				</tr>
				<tr style="padding: 4px;">
					<td>
						Stato:
						<br />
						<asp:DropDownList ID="StatoFiltroDropDownList" runat="server" DataSourceID="EnnupleStatiObjectDataSource"
							DataTextField="Descrizione" DataValueField="ID" CssClass="GridCombo" AppendDataBoundItems="true"
							Width="153px">
							<asp:ListItem Value="" Text="(Tutti)"></asp:ListItem>
						</asp:DropDownList>
					</td>
					<td>
						Gruppo prestazioni:
						<br />
						<asp:TextBox ID="GruppoPrestazioniFiltroTextBox" runat="server" Text="" />
					</td>
					<td>
						Sistema Richiedente:
						<br />
						<asp:DropDownList ID="SistemaRichiedenteFiltroDropDownList" runat="server" DataSourceID="SistemiRichiedentiObjectDataSource"
							DataTextField="Descrizione" DataValueField="Id" AppendDataBoundItems="true" CssClass="GridCombo"
							Width="300px">
							<asp:ListItem Value="" Text="(Tutti)"></asp:ListItem>
						</asp:DropDownList>
					</td>
					<td>
						Regime:
						<br />
						<asp:DropDownList ID="RegimeFiltroDropDownList" runat="server" DataSourceID="RegimiObjectDataSource"
							DataTextField="Descrizione" DataValueField="Codice" AppendDataBoundItems="true"
							CssClass="GridCombo" Width="153px">
							<asp:ListItem Value="" Text="(Tutti)"></asp:ListItem>
						</asp:DropDownList>
					</td>
					<td>
						Priorità:
						<br />
						<asp:DropDownList ID="PrioritaFiltroDropDownList" runat="server" DataSourceID="PrioritaObjectDataSource"
							DataTextField="Descrizione" DataValueField="Codice" AppendDataBoundItems="true"
							CssClass="GridCombo" Width="153px">
							<asp:ListItem Value="" Text="(Tutti)"></asp:ListItem>
						</asp:DropDownList>
					</td>
				</tr>
			</table>
			<div style="text-align: right;">
				<asp:Button ID="CercaButton" runat="server" CssClass="Button" Style="float: left;
					margin-top: 15px;" Text="Cerca" />
			</div>
		</fieldset>
	</div>
	<asp:Label ID="ErrorLabel" runat="server" Text="error" Visible="false" CssClass="Error"></asp:Label>
	<asp:ValidationSummary ID="InsertValidationSummary" runat="server" DisplayMode="List"
		CssClass="Error" ValidationGroup="InsertGroup" />
	<asp:ValidationSummary ID="EditValidationSummary" runat="server" DisplayMode="List"
		CssClass="Error" ValidationGroup="EditGroup" />
	<div class="separator">
	</div>
	<fieldset id='listFieldset' style="padding: 3px;">
		<legend>Ennuple</legend>
		<div id="toolbarAzioni" style="padding: 3px;">
			<input id="NewButton" type="button" class="addLongButton" onclick="NewEnnupla(); return false;"
				value="Nuovo" title="aggiunge una nuova ennupla" />
		</div>
		<div style="padding: 3px;">
			<asp:ListView ID="EnnupleListView" runat="server" DataKeyNames="ID" DataSourceID="EnnupleObjectDataSource"
				InsertItemPosition="FirstItem">
				<EditItemTemplate>
				</EditItemTemplate>
				<EmptyDataTemplate>
					Nessuna ennupla inserita
				</EmptyDataTemplate>
				<InsertItemTemplate>
				</InsertItemTemplate>
				<ItemTemplate>
					<tr class='GridItem<%# eval("IDStato") %>'>
						<td>
							<%-- <asp:ImageButton ID="EditButton" CssClass="ImageButton" runat="server" CommandName="Edit"
                            ImageUrl="~/Images/edititem.gif" ToolTip="Modifica" CausesValidation="false" />--%>
							<asp:ImageButton ID="EditButton" CssClass="ImageButton" runat="server" ImageUrl="~/Images/edititem.gif"
								ToolTip="Modifica" OnClientClick='<%# "EditEnnupla(""" & Eval("ID").ToString() & """, """ & Eval("Inverso").ToString().ToLower() & """, """ & Eval("IDStato").ToString().ToLower() & """,  """ & Eval("Descrizione").ToString() & """,  """ & Eval("Note").ToString() & """,""" & Eval("IDGruppoUtenti").ToString().ToLower() & """ , """ & Eval("IDGruppoPrestazioni").ToString().ToLower() & """, """ & Eval("OrarioInizio").ToString() & """, """ & Eval("OrarioFine").ToString() & """, """ & Eval("Lunedi").ToString().ToLower() & """,""" & Eval("Martedi").ToString().ToLower() & """,""" & Eval("Mercoledi").ToString().ToLower() & """,""" & Eval("Giovedi").ToString().ToLower() & """,""" & Eval("Venerdi").ToString().ToLower() & """,""" & Eval("Sabato").ToString().ToLower() & """,""" & Eval("Domenica").ToString().ToLower() & """,""" & Eval("IDUnitaOperativa").ToString().ToLower() & """,""" & Eval("IDSistemaRichiedente").ToString().ToLower() & """,""" & Eval("CodiceRegime").ToString() & """,""" & Eval("CodicePriorita").ToString() & """); return false;"%>' />
						</td>
						<td>
							<asp:Label ID="IDStatoLabel" runat="server" Text='<%# Bind("IDStato") %>' Style="display: none;" />
							<asp:Label ID="StatoLabel" runat="server" Text='<%# Eval("Stato") %>' />
						</td>
						<td>
							<%# If(Eval("Inverso"), "<img src='../Images/alert.png'>", "")%>
						</td>
						<td>
							<asp:Label ID="IdLabel" runat="server" Text='<%# Bind("ID") %>' Style="display: none;" />
							<asp:Label ID="DescrizioneLabel" runat="server" Text='<%# Bind("Descrizione") %>' />
						</td>
						<td>
							<asp:Label ID="NoteLabel" runat="server" Text='<%# Bind("Note") %>' />
						</td>
						<td>
							<asp:Label ID="IdGruppoUtentiLabel" runat="server" Text='<%# Bind("IDGruppoUtenti") %>'
								Style="display: none;" />
							<asp:Label ID="GruppoUtentiLabel" runat="server" Text='<%# IF(Eval("GruppoUtenti") Is DbNull.Value, "(Tutti)", Eval("GruppoUtenti")) %>'
								CssClass='<%# IF(Eval("GruppoUtenti") Is DbNull.Value, "Bold", "") %>' />
						</td>
						<td>
							<asp:Label ID="IDGruppoPrestazioniLabel" runat="server" Text='<%# Bind("IDGruppoPrestazioni") %>'
								Style="display: none;" />
							<asp:Label ID="GruppoPrestazioniLabel" runat="server" Text='<%# IF(Eval("GruppoPrestazioni") Is DbNull.Value, "(Tutti)", Eval("GruppoPrestazioni")) %>'
								CssClass='<%# IF(Eval("GruppoPrestazioni") Is DbNull.Value, "Bold", "") %>' />
						</td>
						<td>
							<asp:Label ID="OrarioInizioLabel" runat="server" Text='<%# IF(Eval("OrarioInizio") Is DbNull.Value, String.Empty, (New DateTime(Eval("OrarioInizio").Ticks)).ToString("HH\:mm")) %>' />
						</td>
						<td>
							<asp:Label ID="OrarioFineLabel" runat="server" Text='<%# IF(Eval("OrarioFine") Is DbNull.Value, String.Empty, (New DateTime(Eval("OrarioFine").Ticks)).ToString("HH\:mm")) %>' />
						</td>
						<td style="text-align: left;">
							<asp:Label ID="LuLabel" runat="server" ForeColor='<%# If(Eval("Lunedi"), System.Drawing.Color.Green, System.Drawing.Color.Red) %>'
								Text="Lu" Font-Bold="true" />
							<asp:Label ID="MaLabel" runat="server" ForeColor='<%# If(Eval("Martedi"), System.Drawing.Color.Green, System.Drawing.Color.Red) %>'
								Text="Ma" Font-Bold="true" />
							<asp:Label ID="MeLabel" runat="server" ForeColor='<%# If(Eval("Mercoledi"), System.Drawing.Color.Green, System.Drawing.Color.Red) %>'
								Text="Me" Font-Bold="true" /><br />
							<asp:Label ID="GiLabel" runat="server" ForeColor='<%# If(Eval("Giovedi"), System.Drawing.Color.Green, System.Drawing.Color.Red) %>'
								Text="Gi" Font-Bold="true" />
							<asp:Label ID="VeLabel" runat="server" ForeColor='<%# If(Eval("Venerdi"), System.Drawing.Color.Green, System.Drawing.Color.Red) %>'
								Text="Ve" Font-Bold="true" />
							<asp:Label ID="SaLabel" runat="server" ForeColor='<%# If(Eval("Sabato"), System.Drawing.Color.Green, System.Drawing.Color.Red) %>'
								Text="Sa" Font-Bold="true" />
							<asp:Label ID="DoLabel" runat="server" ForeColor='<%# If(Eval("Domenica"), System.Drawing.Color.Green, System.Drawing.Color.Red) %>'
								Text="Do" Font-Bold="true" />
						</td>
						<td>
							<asp:Label ID="IDUnitaOperativaLabel" runat="server" Text='<%# Bind("IDUnitaOperativa") %>'
								Style="display: none;" />
							<asp:Label ID="UnitaOperativaLabel" runat="server" Text='<%# IF(Eval("UnitaOperativa") Is DbNull.Value, "(Tutti)", Eval("UnitaOperativa")) %>'
								CssClass='<%# IF(Eval("UnitaOperativa") Is DbNull.Value, "Bold", "") %>' />
						</td>
						<td>
							<asp:Label ID="IDSistemaRichiedenteLabel" runat="server" Text='<%# Bind("IDSistemaRichiedente") %>'
								Style="display: none;" />
							<asp:Label ID="SistemaRichiedenteLabel" runat="server" Text='<%# IF(Eval("SistemaRichiedente") Is DbNull.Value, "(Tutti)", Eval("SistemaRichiedente")) %>'
								CssClass='<%# IF(Eval("SistemaRichiedente") Is DbNull.Value, "Bold", "") %>' />
						</td>
						<td>
							<asp:Label ID="IDRegimeLabel" runat="server" Text='<%# Bind("CodiceRegime") %>' Style="display: none;" />
							<asp:Label ID="RegimeLabel" runat="server" Text='<%# IF(Eval("Regime") Is DbNull.Value, "(Tutti)", Eval("Regime")) %>'
								CssClass='<%# IF(Eval("Regime") Is DbNull.Value, "Bold", "") %>' />
						</td>
						<td>
							<asp:Label ID="IDPrioritaLabel" runat="server" Text='<%# Bind("CodicePriorita") %>'
								Style="display: none;" />
							<asp:Label ID="PrioritaLabel" runat="server" Text='<%# IF(Eval("Priorita") Is DbNull.Value, "(Tutti)", Eval("Priorita")) %>'
								CssClass='<%# IF(Eval("Priorita") Is DbNull.Value, "Bold", "") %>' />
						</td>
						<td>
							<asp:ImageButton ID="DeleteButton" CssClass="ImageButton" runat="server" CommandName="Elimina"
								CommandArgument='<%# Eval("ID") %>' ToolTip="Elimina" ImageUrl="~/Images/delete.gif"
								OnClientClick="return confirm('Sei sicuro di voler eliminare la riga selezionata?');" />
						</td>
						<td>
							<asp:ImageButton ID="CopyImageButton" CssClass="ImageButton" runat="server" CommandName="Copy"
								CommandArgument='<%# Eval("ID") %>' ToolTip="Copia ennupla" ImageUrl="~/Images/copy.png"
								OnClientClick='<%# "EditEnnupla("""", """ & Eval("Inverso").ToString().ToLower() & """, """ & Eval("IDStato").ToString().ToLower() & """,  """ & Eval("Descrizione").ToString() & """,""" & Eval("Note").ToString() & """, """ & Eval("IDGruppoUtenti").ToString().ToLower() & """ , """ & Eval("IDGruppoPrestazioni").ToString().ToLower() & """, """ & Eval("OrarioInizio").ToString() & """, """ & Eval("OrarioFine").ToString() & """, """ & Eval("Lunedi").ToString().ToLower() & """,""" & Eval("Martedi").ToString().ToLower() & """,""" & Eval("Mercoledi").ToString().ToLower() & """,""" & Eval("Giovedi").ToString().ToLower() & """,""" & Eval("Venerdi").ToString().ToLower() & """,""" & Eval("Sabato").ToString().ToLower() & """,""" & Eval("Domenica").ToString().ToLower() & """,""" & Eval("IDUnitaOperativa").ToString().ToLower() & """,""" & Eval("IDSistemaRichiedente").ToString().ToLower() & """,""" & Eval("CodiceRegime").ToString() & """,""" & Eval("CodicePriorita").ToString() & """); return false;"%>' />
						</td>
					</tr>
				</ItemTemplate>
				<LayoutTemplate>
					<table id="itemPlaceholderContainer" runat="server" style="width: 100%; border: 1px silver solid;
						border-collapse: collapse;" class="tablesorter">
						<tr id="Tr1" runat="server" style="">
							<th id="Th1" runat="server">
								Modifica ennupla
							</th>
							<th id="Th15" runat="server">
								<asp:LinkButton ID="StatoLinkButton" runat="server" CommandName="Sort" CommandArgument="Stato">Stato</asp:LinkButton>
							</th>
							<th id="Th14" runat="server">
								<asp:LinkButton ID="InversoLinkButton" runat="server" CommandName="Sort" CommandArgument="Inverso">NOT</asp:LinkButton>
							</th>
							<th id="Th6" runat="server">
								<asp:LinkButton ID="DescrizioneLinkButton" runat="server" CommandName="Sort" CommandArgument="Descrizione">Descrizione</asp:LinkButton>
							</th>
							<th id="Th16" runat="server">
								<asp:LinkButton ID="NoteLinkButton" runat="server" CommandName="Sort" CommandArgument="Note">Note</asp:LinkButton>
							</th>
							<th id="Th4" runat="server">
								<asp:LinkButton ID="IDGruppoUtentiLinkButton" runat="server" CommandName="Sort" CommandArgument="GruppoUtenti">Gruppo di Order Entry</asp:LinkButton>
							</th>
							<th id="Th5" runat="server">
								<asp:LinkButton ID="IDGruppoPrestazioniLinkButton" runat="server" CommandName="Sort"
									CommandArgument="GruppoPrestazioni">Gruppo di prestazioni</asp:LinkButton>
							</th>
							<th id="Th7" runat="server">
								<asp:LinkButton ID="OrarioInizioLinkButton" runat="server" CommandName="Sort" CommandArgument="OrarioInizio">Orario inizio</asp:LinkButton>
							</th>
							<th id="Th8" runat="server">
								<asp:LinkButton ID="OrarioFineLinkButton" runat="server" CommandName="Sort" CommandArgument="OrarioFine">Orario fine</asp:LinkButton>
							</th>
							<th id="Th9" runat="server">
								Giorni
							</th>
							<th id="Th10" runat="server">
								<asp:LinkButton ID="IDUnitaOperativaLinkButton" runat="server" CommandName="Sort"
									CommandArgument="UnitaOperativa">Unità operativa</asp:LinkButton>
							</th>
							<th id="Th11" runat="server">
								<asp:LinkButton ID="IDSistemaRichiedenteLinkButton" runat="server" CommandName="Sort"
									CommandArgument="SistemaRichiedente">Sistema richiedente</asp:LinkButton>
							</th>
							<th id="Th12" runat="server">
								<asp:LinkButton ID="RegimeLinkButton" runat="server" CommandName="Sort" CommandArgument="Regime">Regime</asp:LinkButton>
							</th>
							<th id="Th13" runat="server">
								<asp:LinkButton ID="PrioritaLinkButton" runat="server" CommandName="Sort" CommandArgument="Priorita">Priorità</asp:LinkButton>
							</th>
							<th id="Th2" runat="server">
								Elimina
							</th>
							<th id="Th3" runat="server">
								Copia
							</th>
						</tr>
						<tr id="itemPlaceholder" runat="server">
						</tr>
					</table>
				</LayoutTemplate>
			</asp:ListView>
			<asp:ObjectDataSource ID="EnnupleObjectDataSource" runat="server" InsertMethod="Insert"
				SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiEnnupleListTableAdapter"
				UpdateMethod="Update" OldValuesParameterFormatString="{0}">
				<InsertParameters>
					<asp:Parameter Name="UtenteInserimento" Type="String" />
					<asp:Parameter DbType="Guid" Name="IDGruppoUtenti" />
					<asp:Parameter DbType="Guid" Name="IDGruppoPrestazioni" />
					<asp:Parameter Name="Descrizione" Type="String" />
					<asp:Parameter Name="Note" Type="String" />
					<asp:Parameter DbType="Time" Name="OrarioInizio" />
					<asp:Parameter DbType="Time" Name="OrarioFine" />
					<asp:Parameter Name="Lunedi" Type="Boolean" />
					<asp:Parameter Name="Martedi" Type="Boolean" />
					<asp:Parameter Name="Mercoledi" Type="Boolean" />
					<asp:Parameter Name="Giovedi" Type="Boolean" />
					<asp:Parameter Name="Venerdi" Type="Boolean" />
					<asp:Parameter Name="Sabato" Type="Boolean" />
					<asp:Parameter Name="Domenica" Type="Boolean" />
					<asp:Parameter DbType="Guid" Name="IDUnitaOperativa" />
					<asp:Parameter DbType="Guid" Name="IDSistemaRichiedente" />
					<asp:Parameter Name="CodiceRegime" Type="String" />
					<asp:Parameter Name="CodicePriorita" Type="String" />
					<asp:Parameter Name="Inverso" Type="Boolean" />
					<asp:Parameter Name="IDStato" Type="Byte" />
				</InsertParameters>
				<SelectParameters>
					<asp:ControlParameter ControlID="GruppoUtentiFiltroTextBox" Name="GruppoUtenti" PropertyName="Text"
						Type="String" />
					<asp:ControlParameter ControlID="GruppoPrestazioniFiltroTextBox" Name="GruppoPrestazioni"
						PropertyName="Text" Type="String" />
					<asp:ControlParameter ControlID="DescrizioneFiltroTextBox" Name="Descrizione" PropertyName="Text"
						Type="String" />
					<asp:Parameter Name="Note" Type="String"/>
					<%--       <asp:ControlParameter ControlID="LunediFiltroCheckBox" Name="Lunedi" 
                    PropertyName="Checked" Type="Boolean" />
                <asp:ControlParameter ControlID="MartediFiltroCheckBox" Name="Martedi" 
                    PropertyName="Checked" Type="Boolean" />
                <asp:ControlParameter ControlID="MercolediFiltroCheckBox" Name="Mercoledi" 
                    PropertyName="Checked" Type="Boolean" />
                <asp:ControlParameter ControlID="GiovediFiltroCheckBox" Name="Giovedi" 
                    PropertyName="Checked" Type="Boolean" />
                <asp:ControlParameter ControlID="VenerdiFiltroCheckBox" Name="Venerdi" 
                    PropertyName="Checked" Type="Boolean" />
                <asp:ControlParameter ControlID="SabatoFiltroCheckBox" Name="Sabato" 
                    PropertyName="Checked" Type="Boolean" />
                <asp:ControlParameter ControlID="DomenicaFiltroCheckBox" Name="Domenica" 
                    PropertyName="Checked" Type="Boolean" />--%>
					<asp:ControlParameter ControlID="UnitaOperativaFiltroDropDownList" DbType="Guid"
						Name="IDUnitaOperativa" PropertyName="SelectedValue" />
					<asp:ControlParameter ControlID="SistemaRichiedenteFiltroDropDownList" DbType="Guid"
						Name="IDSistemaRichiedente" PropertyName="SelectedValue" />
					<asp:ControlParameter ControlID="RegimeFiltroDropDownList" Name="CodiceRegime" PropertyName="SelectedValue"
						Type="String" />
					<asp:ControlParameter ControlID="PrioritaFiltroDropDownList" Name="CodicePriorita"
						PropertyName="SelectedValue" Type="String" />
					<asp:ControlParameter ControlID="NotFiltroDropDownList" Name="Inverso" PropertyName="SelectedValue"
						Type="Boolean" />
					<asp:ControlParameter ControlID="StatoFiltroDropDownList" Name="IDStato" PropertyName="SelectedValue"
						Type="Byte" />
				</SelectParameters>
				<UpdateParameters>
					<asp:Parameter DbType="Guid" Name="ID" />
					<asp:Parameter Name="UtenteModifica" Type="String" />
					<asp:Parameter DbType="Guid" Name="IDGruppoUtenti" />
					<asp:Parameter DbType="Guid" Name="IDGruppoPrestazioni" />
					<asp:Parameter Name="Descrizione" Type="String" />
					<asp:Parameter Name="Note" Type="String" />
					<asp:Parameter DbType="Time" Name="OrarioInizio" />
					<asp:Parameter DbType="Time" Name="OrarioFine" />
					<asp:Parameter Name="Lunedi" Type="Boolean" />
					<asp:Parameter Name="Martedi" Type="Boolean" />
					<asp:Parameter Name="Mercoledi" Type="Boolean" />
					<asp:Parameter Name="Giovedi" Type="Boolean" />
					<asp:Parameter Name="Venerdi" Type="Boolean" />
					<asp:Parameter Name="Sabato" Type="Boolean" />
					<asp:Parameter Name="Domenica" Type="Boolean" />
					<asp:Parameter DbType="Guid" Name="IDUnitaOperativa" />
					<asp:Parameter DbType="Guid" Name="IDSistemaRichiedente" />
					<asp:Parameter Name="CodiceRegime" Type="String" />
					<asp:Parameter Name="CodicePriorita" Type="String" />
					<asp:Parameter Name="Inverso" Type="Boolean" />
					<asp:Parameter Name="IDStato" Type="Byte" />
				</UpdateParameters>
			</asp:ObjectDataSource>
			<asp:ObjectDataSource ID="PrioritaObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
				SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiLookupPrioritaTableAdapter">
				<SelectParameters>
					<asp:Parameter Name="Codice" Type="String" />
				</SelectParameters>
			</asp:ObjectDataSource>
			<asp:ObjectDataSource ID="RegimiObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
				SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiLookupRegimiTableAdapter">
				<SelectParameters>
					<asp:Parameter Name="Codice" Type="String" />
				</SelectParameters>
			</asp:ObjectDataSource>
			<asp:ObjectDataSource ID="EnnupleStatiObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
				SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiLookupEnnupleStatiTableAdapter">
				<SelectParameters>
					<asp:Parameter Name="ID" Type="Byte" />
				</SelectParameters>
			</asp:ObjectDataSource>
			<asp:ObjectDataSource ID="UnitaOperativeObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
				SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiLookupUnitaOperativeTableAdapter">
				<SelectParameters>
					<asp:Parameter Name="Codice" Type="String" />
				</SelectParameters>
			</asp:ObjectDataSource>
			<asp:ObjectDataSource ID="SistemiRichiedentiObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
				SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiLookupSistemiRichiedentiTableAdapter">
				<SelectParameters>
					<asp:Parameter Name="Codice" Type="String" />
				</SelectParameters>
			</asp:ObjectDataSource>
			<asp:ObjectDataSource ID="GruppiPrestazioniObjectDataSource" runat="server" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}"
				SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiGruppiPrestazioniListTableAdapter"
				UpdateMethod="Update">
				<InsertParameters>
					<asp:Parameter Name="Descrizione" Type="String" />
					<asp:Parameter Name="Preferiti" Type="Boolean" />
                    <asp:Parameter Name="Note" Type="String" />
				</InsertParameters>
				<SelectParameters>
					<asp:Parameter Name="Descrizione" Type="String" />
					<asp:Parameter Name="Preferiti" Type="Boolean" />
					<asp:Parameter Name="CodiceDescrizionePrestazione" Type="String"></asp:Parameter>
					<asp:Parameter DbType="Guid" Name="IdSistemaErogante"></asp:Parameter>
                    <asp:Parameter Name="Note" Type="String" />
				</SelectParameters>
				<UpdateParameters>
					<asp:Parameter DbType="Guid" Name="ID" />
					<asp:Parameter Name="Descrizione" Type="String" />
					<asp:Parameter Name="Preferiti" Type="Boolean" />
                    <asp:Parameter Name="Note" Type="String" />
				</UpdateParameters>
			</asp:ObjectDataSource>
            <asp:ObjectDataSource ID="GruppiUtentiObjectDataSource" runat="server"
                DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}"
                SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiGruppiUtentiListTableAdapter"
                UpdateMethod="Update" >
                <InsertParameters>
                    <asp:Parameter Name="Descrizione" Type="String" />
                    <asp:Parameter Name="Note" Type="String"></asp:Parameter>
                </InsertParameters>
                <SelectParameters>
                    <asp:Parameter Name="Descrizione" Type="String" />
                    <asp:Parameter Name="Utente" Type="String" />
                    <asp:Parameter Name="Note" Type="String"></asp:Parameter>
                </SelectParameters>
                <UpdateParameters>
                    <asp:Parameter DbType="Guid" Name="ID" />
                    <asp:Parameter Name="Descrizione" Type="String" />
                    <asp:Parameter Name="Note" Type="String"></asp:Parameter>
                </UpdateParameters>
			</asp:ObjectDataSource>
		</div>
	</fieldset>
	<div id="EnnuplaDetail" style="display: none; padding: 5px;">
		<table style="width: 100%; border-collapse: collapse; padding: 10px; font-size: 12px;">
			<tr>
				<td style="width: 100%; padding: 5px;">
					<asp:HiddenField ID="EnnuplaDetail_IdHiddenField" runat="server" />
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">
					NOT
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:CheckBox ID="EnnuplaDetail_NotCheckBox" runat="server" />
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">
					Stato
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:DropDownList ID="EnnuplaDetail_StatoDropDownList" runat="server" DataSourceID="EnnupleStatiObjectDataSource"
						DataTextField="Descrizione" DataValueField="ID" CssClass="GridCombo" Width="370">
						<asp:ListItem Value="" Text="(Tutti)"></asp:ListItem>
					</asp:DropDownList>
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">
					Descrizione
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:TextBox ID="EnnuplaDetail_DescrizioneTextBox" runat="server" Width="100%"></asp:TextBox>
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">Note
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:TextBox TextMode="MultiLine" Height="100" ID="EnnuplaDetail_NoteTextBox" runat="server" Width="100%"></asp:TextBox>
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">
					Gruppo di Order Entry
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:DropDownList ID="EnnuplaDetail_GruppoUtentiDropDownList" runat="server" DataSourceID="GruppiUtentiObjectDataSource"
						DataTextField="Descrizione" DataValueField="ID" AppendDataBoundItems="True" CssClass="GridCombo"
						Width="370">
						<asp:ListItem Value="" Text="(Tutti)"></asp:ListItem>
					</asp:DropDownList>
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">
					Gruppo di prestazioni
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:DropDownList ID="EnnuplaDetail_GruppiPrestazioniDropDownList" runat="server"
						DataSourceID="GruppiPrestazioniObjectDataSource" DataTextField="Descrizione" DataValueField="Id"
						AppendDataBoundItems="true" CssClass="GridCombo" Width="370">
						<asp:ListItem Value="" Text="(Tutti)"></asp:ListItem>
					</asp:DropDownList>
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">
					Orario inizio
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:TextBox ID="EnnuplaDetail_OraInizioTextBox" runat="server" CssClass="TimeInput"></asp:TextBox>
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">
					Orario fine
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:TextBox ID="EnnuplaDetail_OraFineTextBox" runat="server" CssClass="TimeInput"></asp:TextBox>
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">
					Giorni
				</td>
				<td style="width: 100%; padding: 5px;">
					<table>
						<tr>
							<td>
								<asp:CheckBox ID="EnnuplaDetail_LunediCheckBox" runat="server" Text="Lunedi" />
							</td>
						</tr>
						<tr>
							<td>
								<asp:CheckBox ID="EnnuplaDetail_MartediCheckBox" runat="server" Text="Martedì" />
							</td>
						</tr>
						<tr>
							<td>
								<asp:CheckBox ID="EnnuplaDetail_MercolediCheckBox" runat="server" Text="Mercoledì" />
							</td>
						</tr>
						<tr>
							<td>
								<asp:CheckBox ID="EnnuplaDetail_GiovediCheckBox" runat="server" Text="Giovedì" />
							</td>
						</tr>
						<tr>
							<td>
								<asp:CheckBox ID="EnnuplaDetail_VenerdiCheckBox" runat="server" Text="Venerdì" />
							</td>
						</tr>
						<tr>
							<td>
								<asp:CheckBox ID="EnnuplaDetail_SabatoCheckBox" runat="server" Text="Sabato" />
							</td>
						</tr>
						<tr>
							<td>
								<asp:CheckBox ID="EnnuplaDetail_DomenicaCheckBox" runat="server" Text="Domenica" />
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">
					Unità operativa
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:DropDownList ID="EnnuplaDetail_UnitaOperativaDropDownList" runat="server" DataSourceID="UnitaOperativeObjectDataSource"
						DataTextField="Descrizione" DataValueField="Id" AppendDataBoundItems="true" CssClass="GridCombo"
						Width="370">
						<asp:ListItem Value="" Text="(Tutte)"></asp:ListItem>
					</asp:DropDownList>
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">
					Sistema richiedente
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:DropDownList ID="EnnuplaDetail_SistemaRichiedenteDropDownList" runat="server"
						DataSourceID="SistemiRichiedentiObjectDataSource" DataTextField="Descrizione" DataValueField="Id"
						AppendDataBoundItems="true" CssClass="GridCombo" Width="370">
						<asp:ListItem Value="" Text="(Tutti)"></asp:ListItem>
					</asp:DropDownList>
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">
					Regime
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:DropDownList ID="EnnuplaDetail_RegimeDropDownList" runat="server" Width="370"
						DataSourceID="RegimiObjectDataSource" DataTextField="Descrizione" DataValueField="Codice"
						AppendDataBoundItems="true" CssClass="GridCombo">
						<asp:ListItem Value="" Text="(Tutti)"></asp:ListItem>
					</asp:DropDownList>
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">
					Priorità
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:DropDownList ID="EnnuplaDetail_PrioritaDropDownList" runat="server" Width="370"
						DataSourceID="PrioritaObjectDataSource" DataTextField="Descrizione" DataValueField="Codice"
						AppendDataBoundItems="true" CssClass="GridCombo">
						<asp:ListItem Value="" Text="(Tutti)"></asp:ListItem>
					</asp:DropDownList>
				</td>
			</tr>
		</table>
		<br />
		<asp:Button ID="SaveButton" runat="server" CssClass="saveFake" Text="Salva" ToolTip="Salva l'ennupla"
			Style="display: none;" CausesValidation="false" OnClick="SaveButton_Click"></asp:Button>
	</div>
	<script type="text/javascript">

		var _EnnuplaDetail_IdHiddenField;
		var _EnnuplaDetail_NotCheckBox;
		var _EnnuplaDetail_StatoDropDownList;
		var _EnnuplaDetail_DescrizioneTextBox;
		var _EnnuplaDetail_NoteTextBox;
		var _EnnuplaDetail_GruppiPrestazioniDropDownList;
		var _EnnuplaDetail_GruppoUtentiDropDownList;
		var _EnnuplaDetail_OraInizioTextBox;
		var _EnnuplaDetail_OraFineTextBox;
		var _EnnuplaDetail_LunediCheckBox;
		var _EnnuplaDetail_MartediCheckBox;
		var _EnnuplaDetail_MercolediCheckBox;
		var _EnnuplaDetail_GiovediCheckBox;
		var _EnnuplaDetail_VenerdiCheckBox;
		var _EnnuplaDetail_SabatoCheckBox;
		var _EnnuplaDetail_DomenicaCheckBox;
		var _EnnuplaDetail_UnitaOperativaDropDownList;
		var _EnnuplaDetail_SistemaRichiedenteDropDownList;
		var _EnnuplaDetail_RegimeDropDownList;
		var _EnnuplaDetail_PrioritaDropDownList;

		$(document).ready(function () {

			_EnnuplaDetail_IdHiddenField = '<%= EnnuplaDetail_IdHiddenField.ClientID %>';
			_EnnuplaDetail_NotCheckBox = '<%= EnnuplaDetail_NotCheckBox.ClientID %>';
			_EnnuplaDetail_StatoDropDownList = '<%= EnnuplaDetail_StatoDropDownList.ClientID %>';
			_EnnuplaDetail_DescrizioneTextBox = '<%= EnnuplaDetail_DescrizioneTextBox.ClientID %>';
			_EnnuplaDetail_NoteTextBox = '<%= EnnuplaDetail_NoteTextBox.ClientID %>';
			_EnnuplaDetail_GruppoUtentiDropDownList = '<%= EnnuplaDetail_GruppoUtentiDropDownList.ClientID %>';
			_EnnuplaDetail_GruppiPrestazioniDropDownList = '<%= EnnuplaDetail_GruppiPrestazioniDropDownList.ClientID %>';
			_EnnuplaDetail_OraInizioTextBox = '<%= EnnuplaDetail_OraInizioTextBox.ClientID %>';
			_EnnuplaDetail_OraFineTextBox = '<%= EnnuplaDetail_OraFineTextBox.ClientID %>';
			_EnnuplaDetail_LunediCheckBox = '<%= EnnuplaDetail_LunediCheckBox.ClientID %>';
			_EnnuplaDetail_MartediCheckBox = '<%= EnnuplaDetail_MartediCheckBox.ClientID %>';
			_EnnuplaDetail_MercolediCheckBox = '<%= EnnuplaDetail_MercolediCheckBox.ClientID %>';
			_EnnuplaDetail_GiovediCheckBox = '<%= EnnuplaDetail_GiovediCheckBox.ClientID %>';
			_EnnuplaDetail_VenerdiCheckBox = '<%= EnnuplaDetail_VenerdiCheckBox.ClientID %>';
			_EnnuplaDetail_SabatoCheckBox = '<%= EnnuplaDetail_SabatoCheckBox.ClientID %>';
			_EnnuplaDetail_DomenicaCheckBox = '<%= EnnuplaDetail_DomenicaCheckBox.ClientID %>';
			_EnnuplaDetail_UnitaOperativaDropDownList = '<%= EnnuplaDetail_UnitaOperativaDropDownList.ClientID %>';
			_EnnuplaDetail_SistemaRichiedenteDropDownList = '<%= EnnuplaDetail_SistemaRichiedenteDropDownList.ClientID %>';
			_EnnuplaDetail_RegimeDropDownList = '<%= EnnuplaDetail_RegimeDropDownList.ClientID %>';
			_EnnuplaDetail_PrioritaDropDownList = '<%= EnnuplaDetail_PrioritaDropDownList.ClientID %>';

		});
       
	</script>
	<script src="../Scripts/ennuple.js?<%# Reflection.Assembly.GetExecutingAssembly.GetName.Version.ToString %>" type="text/javascript"></script>
</asp:Content>

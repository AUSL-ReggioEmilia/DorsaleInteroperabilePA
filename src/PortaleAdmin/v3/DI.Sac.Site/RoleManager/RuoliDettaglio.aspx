<%@ Page Title="Dettaglio Ruolo" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="RuoliDettaglio.aspx.vb" Inherits=".RuoliDettaglio" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<asp:Label ID="lblTitolo" runat="server" class="Title" Text="Label"></asp:Label>
	<table id="toolbar" runat="server" class="toolbar" style="width: 100%;">
		<tr>
			<td>
				<asp:HyperLink ID="lnkNuovo" runat="server" NavigateUrl="javascript:window.location.href('RuoloOggettiActiveDirectoryLista.aspx?Id='+ $.QueryString['Id']);"
					ToolTip="Gestione Utenti e Gruppi associati al ruolo">
				 <img src="../Images/group.gif" />
				 Utenti e Gruppi
				</asp:HyperLink>
				<asp:LinkButton ID="lnkElimina" runat="server" ToolTip="Elimina Ruolo" OnClick="lnkElimina_Click"
					OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione dell\'elemento?');">
				 <img src="../Images/delete.gif" />
				 Elimina Ruolo
				</asp:LinkButton>
			</td>
		</tr>
	</table>
	<br />
	<asp:FormView ID="FormViewDettaglio" runat="server" DataKeyNames="Id" DataSourceID="odsDettagli"
		EmptyDataText="Dettaglio non disponibile." EnableModelValidation="True" DefaultMode="Edit">
		<EditItemTemplate>
			<table class="table_dettagli" width="500px">
				<tr>
					<td class="Td-Text" width="200px">
						Id
					</td>
					<td class="Td-Value">
						<%# Eval("Id")%>
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Codice
					</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtCodice" runat="server" Width="300px" MaxLength="16" Text='<%# Bind("Codice") %>' />
						<asp:RequiredFieldValidator ID="RequiredFieldValidator2" class="Error" runat="server"
							ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtCodice" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Descrizione
					</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtDescrizione" runat="server" Width="300px" MaxLength="128" Text='<%# Bind("Descrizione") %>' />
						<asp:RequiredFieldValidator ID="req1" class="Error" runat="server" ErrorMessage="Campo Obbligatorio"
							Display="Dynamic" ControlToValidate="txtDescrizione" />
					</td>
				</tr>
                <tr>
					<td class="Td-Text">
						Note
					</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtNote" runat="server"  TextMode="MultiLine" Width="300px" MaxLength="128" Rows="3" Text='<%# Bind("Note") %>' />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Attivo
					</td>
					<td class="Td-Value">
						<asp:CheckBox ID="chkAttivo" runat="server" Checked='<%# Bind("Attivo") %>' />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Creato
					</td>
					<td class="Td-Value">
						Da&nbsp;<%# Eval("UtenteInserimento")%><br />Il&nbsp;<%# Eval("DataInserimento")%></td>
				</tr>
				<tr>
					<td class="Td-Text2">
						Modificato
					</td>
					<td class="Td-Value2">
						Da&nbsp;<%# Eval("UtenteModifica")%><br />Il&nbsp;<%# Eval("DataModifica")%></td>
				</tr>
				<tr>
					<td class="LeftFooter">
						<asp:Button ID="butSalva" runat="server" Text="Conferma" CssClass="TabButton" CommandName="Update" />
					</td>
					<td class="RightFooter">
						<asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Annulla" CssClass="TabButton"
							ValidationGroup="none" />
					</td>
				</tr>
			</table>
			<!-- ############################################################################################################# -->
		</EditItemTemplate>
		<InsertItemTemplate>
			<table class="table_dettagli" width="500px">
				<tr>
					<td class="Td-Text" width="200px">
						Codice
					</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtCodice" runat="server" Width="300px" MaxLength="16" Text='<%# Bind("Codice") %>' />
						<asp:RequiredFieldValidator ID="RequiredFieldValidator1" class="Error" runat="server"
							ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtCodice" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text2">
						Descrizione
					</td>
					<td class="Td-Value2">
						<asp:TextBox ID="txtDescrizione" runat="server" Width="300px" MaxLength="128" Text='<%# Bind("Descrizione") %>' />
						<asp:RequiredFieldValidator ID="req1" class="Error" runat="server" ErrorMessage="Campo Obbligatorio"
							Display="Dynamic" ControlToValidate="txtDescrizione" />
					</td>
				</tr>
                <tr>
					<td class="Td-Text2">
						Note
					</td>
					<td class="Td-Value2">
						<asp:TextBox ID="txtNote" runat="server" Width="300px" Rows="3" TextMode="MultiLine" MaxLength="128" Text='<%# Bind("Note") %>' />
					</td>
				</tr>
				<tr>
					<td class="LeftFooter">
					</td>
					<td class="RightFooter">
						<asp:Button ID="butSalva" runat="server" Text="Conferma" CssClass="TabButton" CommandName="Insert"
							OnClick="butSalva_Click" />
						<asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="TabButton"
							ValidationGroup="null" />
					</td>
				</tr>
			</table>
		</InsertItemTemplate>
	</asp:FormView>
	<asp:Label ID="lblTitoloMembri" runat="server" Text="Membri del Ruolo" class="Title" />
	<asp:GridView ID="gvListaMembri" runat="server" AllowPaging="True" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="odsMembriDelRuolo" GridLines="Horizontal"
		PageSize="100" EnableModelValidation="True" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom"
		Width="500px" CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
		PagerStyle-CssClass="Pager">
		<Columns>
			<asp:BoundField DataField="Tipo" HeaderText="Tipo" SortExpression="Tipo" ItemStyle-Width="50px" />
			<asp:BoundField DataField="Utente" HeaderText="Utente" SortExpression="Utente" ItemStyle-Width="50%" />
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"
				ItemStyle-Width="50%" />
		</Columns>
	</asp:GridView>
	<asp:ObjectDataSource ID="odsDettagli" runat="server" TypeName="OrganigrammaDataSetTableAdapters.RuoliTableAdapter"
		SelectMethod="GetData" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update"
		OldValuesParameterFormatString="{0}" >
		<InsertParameters>
			<asp:Parameter Name="UtenteInserimento" Type="String" />
			<asp:Parameter Name="Codice" Type="String" />
			<asp:Parameter Name="Descrizione" Type="String" />
			<asp:Parameter Name="Attivo" Type="Boolean" DefaultValue="true" />			
			<asp:QueryStringParameter Name="IdRuoloDaCopiare" QueryStringField="IdRuoloDaCopiare" DbType="Guid" />
            <asp:Parameter Name="Note" Type="String" />
		</InsertParameters>
		<SelectParameters>
			<asp:QueryStringParameter Name="ID" QueryStringField="Id" DbType="Guid" />
		</SelectParameters>
		<UpdateParameters>
			<asp:Parameter Name="ID" DbType="Guid" />
			<asp:Parameter Name="UtenteModifica" Type="String" />
			<asp:Parameter Name="Codice" Type="String" />
			<asp:Parameter Name="Descrizione" Type="String" />
			<asp:Parameter Name="Attivo" Type="Boolean" />
            <asp:Parameter Name="Note" Type="String" />
		</UpdateParameters>
	</asp:ObjectDataSource>
	<asp:ObjectDataSource ID="odsMembriDelRuolo" runat="server" SelectMethod="GetData"
		TypeName="OrganigrammaDataSetTableAdapters.RuoliOggettiActiveDirectoryTableAdapter"
		CacheDuration="120" CacheKeyDependency="CacheRuoliOggettiActiveDirectory" EnableCaching="True"
		OldValuesParameterFormatString="{0}" DeleteMethod="Delete" InsertMethod="Insert">
		<SelectParameters>
			<asp:QueryStringParameter DbType="Guid" Name="IDRuolo" QueryStringField="Id" />
			<asp:Parameter Name="Tipo" Type="String" />
			<asp:Parameter Name="Utente" Type="String" />
			<asp:Parameter DefaultValue="" Name="Descrizione" Type="String" />
			<asp:Parameter DefaultValue="200" Name="Top" Type="Int32" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>

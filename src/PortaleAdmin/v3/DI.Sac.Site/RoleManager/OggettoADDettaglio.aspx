<%@ Page Title="Dettaglio Ruolo" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="OggettoADDettaglio.aspx.vb" Inherits=".OggettoADDettaglio" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<asp:Label ID="lblTitolo" runat="server" class="Title" Text="Dettaglio"></asp:Label>
	<table id="Toolbar" runat="server" class="toolbar" style="width: 100%;">
		<tr>
			<td>
				<asp:HyperLink ID="lnkNuovo" runat="server" NavigateUrl="javascript:window.location.href('RuoloOggettiActiveDirectoryLista.aspx?Id='+ $.QueryString['Id']);"
					ToolTip="Esamina i ruoli e i permessi associati all'utente">
				 <img src="../Images/group.gif" class="toolbar-img"/>
				 Ruoli e Permessi
				</asp:HyperLink>
			</td>
		</tr>
	</table>
	<br />
	<asp:FormView ID="FormViewDettaglio" runat="server" DataKeyNames="Id" DataSourceID="odsDettaglio"
		EmptyDataText="Dettaglio non disponibile." EnableModelValidation="True" DefaultMode="ReadOnly">
		<ItemTemplate>
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
						Attivo
					</td>
					<td class="Td-Value">
						<asp:CheckBox ID="chkAttivo" runat="server" Checked='<%# Bind("Attivo") %>' Enabled="false" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Tipo
					</td>
					<td class="Td-Value">
						<%# Eval("Tipo")%>
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Utente
					</td>
					<td class="Td-Value">
						<%# Eval("Utente")%>
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Descrizione
					</td>
					<td class="Td-Value">
						<%# Eval("Descrizione")%>
				</tr>
				<tr>
					<td class="Td-Text">
						Cognome
					</td>
					<td class="Td-Value">
						<%# Eval("Cognome")%>
				</tr>
				<tr>
					<td class="Td-Text">
						Nome
					</td>
					<td class="Td-Value">
						<%# Eval("Nome")%>
				</tr>
				<tr>
					<td class="Td-Text">
						Codice Fiscale
					</td>
					<td class="Td-Value">
						<%# Eval("CodiceFiscale")%>
				</tr>
				<tr>
					<td class="Td-Text">
						Matricola
					</td>
					<td class="Td-Value">
						<%# Eval("Matricola")%>
				</tr>
				<tr>
					<td class="Td-Text">
						Email
					</td>
					<td class="Td-Value">
						<%# Eval("Email")%>
				</tr>
				<tr>
					<td class="Td-Text">
						Creato
					</td>
					<td class="Td-Value">
						Da&nbsp;<%# Eval("UtenteInserimento")%><br />
						Il&nbsp;<%# Eval("DataInserimento")%>
					</td>
				</tr>
				<tr>
					<td class="Td-Text2">
						Modificato
					</td>
					<td class="Td-Value2">
						Da&nbsp;<%# Eval("UtenteModifica")%><br />
						Il&nbsp;<%# Eval("DataModifica")%>
					</td>
				</tr>
			</table>
		</ItemTemplate>
	</asp:FormView>
	<asp:Label ID="lblTitoloMembriGruppo" runat="server" class="Title" Text="Membri del gruppo"
		Style="margin-top: 30px;" />
	<asp:GridView ID="gvListaMembridelGruppo" runat="server" AllowPaging="false" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="odsMembriOttieniPerGruppo" GridLines="Horizontal"
		width="700px" EnableModelValidation="True" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom"
		DataKeyNames="IdUtente" CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
		PagerStyle-CssClass="Pager">
		<Columns>
			<asp:HyperLinkField DataNavigateUrlFormatString="OggettoADDettaglio.aspx?id={0}"
				HeaderText="Membro" DataNavigateUrlFields="IdUtente" DataTextField="Utente" />
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"
				ReadOnly="True" />
			<asp:BoundField DataField="Tipo" HeaderText="Tipo" SortExpression="Tipo" ReadOnly="True" />
		</Columns>
	</asp:GridView>
	<asp:Label ID="Label1" runat="server" class="Title" Text="Gruppi di appartenenza"
		Style="margin-top: 30px;" />
	<asp:GridView ID="gvListaGruppi" runat="server" AllowPaging="false" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="odsGruppiOttieniPerUtente" GridLines="Horizontal"
		width="700px" EnableModelValidation="True" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom"
		DataKeyNames="IdGruppo" CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
		PagerStyle-CssClass="Pager">
		<Columns>
			<asp:HyperLinkField DataNavigateUrlFormatString="OggettoADDettaglio.aspx?id={0}"
				HeaderText="Gruppo" DataNavigateUrlFields="IdGruppo" DataTextField="Utente" />
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"
				ReadOnly="True" />
		</Columns>
	</asp:GridView>
	<asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="TabButton"
		Style="margin-top: 30px;" />
	<asp:ObjectDataSource ID="odsDettaglio" runat="server" TypeName="OrganigrammaDataSetTableAdapters.OggettiActiveDirectoryTableAdapter"
		SelectMethod="GetDataById" OldValuesParameterFormatString="{0}">
		<SelectParameters>
			<asp:QueryStringParameter Name="ID" QueryStringField="Id" DbType="Guid" />
		</SelectParameters>
	</asp:ObjectDataSource>
	<asp:ObjectDataSource ID="odsMembriOttieniPerGruppo" runat="server" TypeName="OrganigrammaDataSetTableAdapters.OggettiActiveDirectoryUtentiGruppiTableAdapter"
		SelectMethod="GetDataByGruppo" OldValuesParameterFormatString="{0}">
		<SelectParameters>
			<asp:QueryStringParameter Name="IdGruppo" QueryStringField="Id" DbType="Guid" />
		</SelectParameters>
	</asp:ObjectDataSource>
	<asp:ObjectDataSource ID="odsGruppiOttieniPerUtente" runat="server" TypeName="OrganigrammaDataSetTableAdapters.OggettiActiveDirectoryUtentiGruppiTableAdapter"
		SelectMethod="GetDataByUtente" OldValuesParameterFormatString="{0}">
		<SelectParameters>
			<asp:QueryStringParameter Name="IdUtente" QueryStringField="Id" DbType="Guid" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>

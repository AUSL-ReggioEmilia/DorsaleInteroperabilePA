<%@ Page Title="Utenti e Gruppi" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="OggettiAD.aspx.vb" Inherits=".OggettiAD" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">	
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False" />
	<table id="pannelloFiltri" runat="server" class="toolbar">
		<tr>
			<td colspan="7">
				<br />
			</td>
		</tr>
		<tr>
			<td>
				Tipo
			</td>
			<td>
				<asp:DropDownList ID="ddlFiltriTipoOggetto" runat="server" Width="120px" AppendDataBoundItems="True"
					DataTextField="Descrizione" DataValueField="Codice">
					<asp:ListItem Text="" Value="" Selected="True" />
					<asp:ListItem>Gruppo</asp:ListItem>
					<asp:ListItem>Utente</asp:ListItem>
				</asp:DropDownList>
			</td>
			<td nowrap="nowrap">
				Utente o Gruppo
			</td>
			<td>
				<asp:TextBox ID="txtFiltriUtente" runat="server" Width="120px" MaxLength="128"></asp:TextBox>
			</td>
			<td>
				Descrizione
			</td>
			<td>
				<asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="120px" MaxLength="256"></asp:TextBox>
			</td>
			<td width="100%">
				<asp:Button ID="butFiltriRicerca" runat="server" CssClass="TabButton" Text="Cerca" />
			</td>
		</tr>
		<tr>
			<td>
			</td>
			<td colspan="6">
				<asp:CheckBox runat="server" ID="chkMembriAttivi" Text="Mostra solo membri con almeno un ruolo assegnato"
					Checked="true" />
			</td>
		</tr>
		<tr>
			<td colspan="7">
				<br />
			</td>
		</tr>
	</table>
	<br />
	<asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="odsLista" GridLines="Horizontal" PageSize="100"
		Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom"
		DataKeyNames="Id" CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
		PagerStyle-CssClass="Pager">
		<Columns>
			<asp:HyperLinkField DataNavigateUrlFormatString="OggettoActiveDirectoryRuoliLista.aspx?id={0}"
				DataNavigateUrlFields="Id" Text="Imposta Ruoli" ItemStyle-Wrap="false" ItemStyle-Width="1%" />
			<asp:HyperLinkField HeaderText="Utente / Gruppo" DataTextField="Utente" DataNavigateUrlFormatString="OggettoADDettaglio.aspx?id={0}"
				DataNavigateUrlFields="Id" SortExpression="Utente" />
			<asp:BoundField DataField="Tipo" HeaderText="Tipo" SortExpression="Tipo" ItemStyle-Width="1px" />
			<asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome" />
			<asp:BoundField DataField="Cognome" HeaderText="Cognome" SortExpression="Cognome" />
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
			<asp:CheckBoxField DataField="Attivo" HeaderText="Attivo" SortExpression="Attivo"
				ItemStyle-Width="1px" />
			<asp:BoundField DataField="Email" HeaderText="Email" SortExpression="Email" />
		</Columns>
	</asp:GridView>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="OrganigrammaDataSetTableAdapters.OggettiActiveDirectoryTableAdapter"
		CacheDuration="120" CacheKeyDependency="CacheOggettiActiveDirectory" EnableCaching="True"
		OldValuesParameterFormatString="original_{0}">
		<SelectParameters>
			<asp:ControlParameter ControlID="txtFiltriUtente" Name="Utente" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="ddlFiltriTipoOggetto" Name="Tipo" PropertyName="SelectedValue"
				Type="String" />
			<asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="chkMembriAttivi" Name="MembroConRuolo" PropertyName="Checked"
				Type="Boolean" />
			<asp:Parameter Name="Top" Type="Int32" DefaultValue="200" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>

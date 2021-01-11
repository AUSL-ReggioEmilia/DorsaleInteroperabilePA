<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="ProvenienzeLista.aspx.vb" Inherits="DI.Sac.Admin.ProvenienzeLista" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<table id="pannelloFiltri" runat="server" class="toolbar">
		<tr>
			<td colspan="2">
				<asp:HyperLink ID="lnkNuovo" runat="server" NavigateUrl="~/Provenienze/ProvenienzaDettaglio.aspx?mode=insert"><img src="../Images/newitem.gif" alt="Nuovo provenienza" class="toolbar-img"/>Nuova provenienza</asp:HyperLink>
			</td>
		</tr>
		<tr>
			<td>
				Provenienza
			</td>
			<td>
				<asp:TextBox ID="txtFiltriProvenienza" runat="server" Width="120px" MaxLength="16" />
			</td>
			<td width="100%">
				<asp:Button ID="butFiltriRicerca" runat="server" CssClass="TabButton" Text="Cerca" />
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<br />
			</td>
		</tr>

	</table>
	<br />
	<asp:GridView ID="gvMain" runat="server" AllowPaging="True" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="MainObjectDataSource" EmptyDataText="Nessun risultato!"
		GridLines="Horizontal" PageSize="100" DataKeyNames="Provenienza" Width="100%" PagerSettings-Position="TopAndBottom"
		CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
		PagerStyle-CssClass="Pager">
		<Columns>
			<asp:HyperLinkField DataTextField="Provenienza" DataNavigateUrlFormatString="~/Provenienze/ProvenienzaDettaglio.aspx?mode=edit&provenienza={0}"
				DataNavigateUrlFields="Provenienza" HeaderText="Provenienza" />
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
			<asp:BoundField DataField="EmailResponsabile" HeaderText="Email Responsabile" SortExpression="EmailResponsabile" />
			<asp:TemplateField HeaderText="FusioneAutomatica">
				<ItemTemplate>
					<asp:CheckBox ID="chkFusioneAutomatica" runat="server" Checked='<%# Eval("FusioneAutomatica") %>'
						Enabled="false" /></td>
				</ItemTemplate>
			</asp:TemplateField>
			<asp:TemplateField HeaderText="Disabilita Ricerca da WS">
				<ItemTemplate>
					<asp:CheckBox ID="chkDisabilitaRicercaWS" runat="server" Checked='<%# Eval("DisabilitaRicercaWS") %>'
						Enabled="false" /></td>
				</ItemTemplate>
			</asp:TemplateField>
			<asp:TemplateField HeaderText="Solo Propri da WS">
				<ItemTemplate>
					<asp:CheckBox ID="chkSoloPropriWS" runat="server" Checked='<%# Eval("SoloPropriWS") %>'
						Enabled="false" /></td>
				</ItemTemplate>
			</asp:TemplateField>
		</Columns>
	</asp:GridView>
	<asp:ObjectDataSource ID="MainObjectDataSource" runat="server" SelectMethod="GetDataByProvenienza"
		TypeName="DI.Sac.Admin.Data.ProvenienzeDataSetTableAdapters.ProvenienzeListaTableAdapter"
		OldValuesParameterFormatString="original_{0}">
		<SelectParameters>
			<asp:ControlParameter ControlID="txtFiltriProvenienza" Name="Provenienza" PropertyName="Text"
				Type="String" />
		</SelectParameters>

	</asp:ObjectDataSource>
</asp:Content>

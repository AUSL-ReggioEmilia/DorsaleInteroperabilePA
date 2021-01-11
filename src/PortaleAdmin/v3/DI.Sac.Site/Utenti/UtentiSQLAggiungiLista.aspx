<%@ Page Title="Lista Utenti" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="UtentiSQLAggiungiLista.aspx.vb" Inherits=".UtentiSQLAggiungiLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False" />
	<asp:Label ID="LabelTitolo" runat="server" CssClass="Title" EnableViewState="False"
			Text="Ricerca degli utenti SQL da aggiungere" />
	<table id="pannelloFiltri" runat="server" class="toolbar">
		<tr>
			<td colspan="7">
				<br />
			</td>
		</tr>
		<tr>		
			<td nowrap="nowrap">
				Utente
			</td>
			<td>
				<asp:TextBox ID="txtFiltriUtente" runat="server" Width="120px" MaxLength="64"></asp:TextBox>
			</td>
			<td width="100%">
				<asp:Button ID="butFiltriRicerca" runat="server" CssClass="TabButton" Text="Cerca" />
			</td>
		</tr>
		<tr>
			<td colspan="7">
				<br />
			</td>
		</tr>
	</table>
	<table class="table_pulsanti" width="100%">
		<tr>
			<td class="Left" >
				<asp:Button ID="butConfermaTop" runat="server" Text="Aggiungi Selezionati" CssClass="TabButton"
					Style="width: 140px;" CommandName="Insert" />
			</td>
			<td class="Right" >
				<asp:Button ID="butAnnullaTop" runat="server" CommandName="Cancel" Text="Chiudi"
					CssClass="TabButton" ValidationGroup="none" />
			</td>
		</tr>
	</table>
	<asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="odsLista" GridLines="Horizontal" PageSize="100"
		Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom"
		DataKeyNames="Name,Type_Desc" CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
		PagerStyle-CssClass="Pager">
		<Columns>
			<asp:TemplateField ItemStyle-Width="30px">
				<HeaderTemplate>
					<asp:CheckBox ID="chkboxSelectAll" runat="server" AutoPostBack="true" OnCheckedChanged="chkboxSelectAll_CheckedChanged" />
				</HeaderTemplate>
				<ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
				<ItemTemplate>
					<asp:CheckBox ID="CheckBox" runat="server"></asp:CheckBox>
				</ItemTemplate>
			</asp:TemplateField>
			<asp:BoundField DataField="Name" HeaderText="Utente / Gruppo" SortExpression="Name" ItemStyle-Width="200px"/>
			<asp:BoundField DataField="Type_Desc" HeaderText="Tipo" SortExpression="Type_Desc" />
		</Columns>
	</asp:GridView>
	<table class="table_pulsanti" width="100%">
		<tr>
			<td class="Left" >
				<asp:Button ID="butConferma" runat="server" Text="Aggiungi Selezionati" CssClass="TabButton"
					Style="width: 140px;" CommandName="Insert" />
			</td>
			<td class="Right" >
				<asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="TabButton"
					ValidationGroup="none" />
			</td>
		</tr>
	</table>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.UtentiDataSetTableAdapters.UtentiUiSQLServerListaTableAdapter"
		EnableCaching="false"
		OldValuesParameterFormatString="{0}">
		<SelectParameters>
			<asp:ControlParameter ControlID="txtFiltriUtente" Name="Utente" PropertyName="Text"
				Type="String" />
			<asp:Parameter Name="Type" Type="String" DefaultValue="S" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>

<%@ Page Title="Dettaglio Transcodifiche" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="TranscodificheUODettaglio.aspx.vb" Inherits=".TranscodificheUODettaglio" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False" />
	<asp:Label ID="lblTitolo" runat="server" class="Title" Text="Label" />
	<table class="table_pulsanti" width="100%">
		<tr>
			<td class="Left">
				<asp:Button ID="butSalvaTop" runat="server" Text="Conferma" CssClass="TabButton"
					CommandName="Update" />
			</td>
			<td class="Right">
				<asp:Button ID="butChiudiTop" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="TabButton"
					ValidationGroup="none" Style="height: 24px" />
			</td>
		</tr>
	</table>
	<asp:GridView ID="gvLista" runat="server" AllowPaging="false" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="odsDettaglio" GridLines="Horizontal"
		Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom"
		DataKeyNames="IdSistema" CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
		PagerStyle-CssClass="Pager">
		<Columns>
			<asp:BoundField DataField="Sistema_CodiceAzienda" HeaderText="Codice Azienda" SortExpression="Sistema_CodiceAzienda"
				ItemStyle-Width="70px" />
			<asp:BoundField DataField="Sistema_Codice" HeaderText="Codice Sistema" SortExpression="Sistema_Codice" />
			<asp:BoundField DataField="Sistema_Descrizione" HeaderText="Descrizione Sistema"
				SortExpression="Sistema_Descrizione" />
			<asp:TemplateField HeaderText="Codice Transcodifica" SortExpression="Codice">
				<ItemTemplate>
					<asp:TextBox ID="txt_Codice" runat="server" Text='<%# Bind("Codice") %>' MaxLength="16"></asp:TextBox>
				</ItemTemplate>
				<ControlStyle Width="100%" />
				<ItemStyle Width="20%" />
			</asp:TemplateField>
			<asp:TemplateField HeaderText="Descrizione" SortExpression="Descrizione">
				<ItemTemplate>
					<asp:TextBox ID="txt_Descrizione" runat="server" Text='<%# Bind("Descrizione") %>'
						MaxLength="128" Width="1px"></asp:TextBox>
				</ItemTemplate>
				<ControlStyle Width="100%" />
				<ItemStyle Width="45%" />
			</asp:TemplateField>
		</Columns>
	</asp:GridView>
	<table class="table_pulsanti" width="100%">
		<tr>
			<td class="Left">
				<asp:Button ID="butSalva" runat="server" Text="Conferma" CssClass="TabButton" CommandName="Update" />
			</td>
			<td class="Right">
				<asp:Button ID="butChiudi" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="TabButton"
					ValidationGroup="none" Style="height: 24px" />
			</td>
		</tr>
	</table>
	<asp:ObjectDataSource ID="odsDettaglio" runat="server" TypeName="OrganigrammaDataSetTableAdapters.UnitaOperativeSistemi"
		SelectMethod="GetDataByIdUnitaOperativa" OldValuesParameterFormatString="{0}" UpdateMethod="Update">
		<SelectParameters>
			<asp:QueryStringParameter Name="IdUnitaOperativa" QueryStringField="Id" DbType="Guid" />
		</SelectParameters>
		<UpdateParameters>
			<asp:Parameter Name="UtenteModifica" Type="String" />
			<asp:Parameter DbType="Guid" Name="IdUnitaOperativa" />
			<asp:Parameter DbType="Guid" Name="IdSistema" />
			<asp:Parameter Name="Codice" Type="String" />
			<asp:Parameter Name="CodiceAzienda" Type="String" />
			<asp:Parameter Name="Descrizione" Type="String" />
		</UpdateParameters>
	</asp:ObjectDataSource>
</asp:Content>

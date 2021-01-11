<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="UnitaOperativaRegimi.aspx.vb" Inherits=".UnitaOperativaRegimi" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<style type="text/css">
		body
		{
			/*  necessario quando si usa screenMask  */
			overflow: hidden;
		}
	</style>
	<div class="screenMask">
	</div>
	<div class="pseudo-popup" style="width: 400px; height: 350px;">
		<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />
		<asp:Label ID="lblTitolo" runat="server" class="Title" Text="Label" />
		<asp:GridView ID="gvLista" runat="server" AllowSorting="True" AutoGenerateColumns="False" DataSourceID="odsGrid"
			GridLines="Horizontal" Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom"
			CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow" PagerStyle-CssClass="Pager"
			DataKeyNames="CodiceRegime">
			<AlternatingRowStyle CssClass="AlternatingRow"></AlternatingRowStyle>
			<Columns>
				<asp:TemplateField ItemStyle-Width="80%" HeaderText="Regime">
					<ItemTemplate>
						<asp:CheckBox ID="CheckBox" runat="server" Checked='<%# Bind("Abilitato") %>' Text='<%# Eval("Descrizione") %>'>
						</asp:CheckBox>
					</ItemTemplate>
				</asp:TemplateField>
				<asp:BoundField DataField="CodiceRegime" Visible="true" HeaderText="Codice" ItemStyle-Width="20%" />
			</Columns>
			<HeaderStyle CssClass="Header"></HeaderStyle>
			<PagerSettings Position="TopAndBottom"></PagerSettings>
			<PagerStyle CssClass="Pager"></PagerStyle>
		</asp:GridView>
		<table class="table_pulsanti" width="100%">
			<tr>
				<td class="Left">
					<asp:Button ID="butSalva" runat="server" Text="Conferma" CssClass="TabButton" CommandName="Update" />
				</td>
				<td class="Right">
					<asp:Button ID="butChiudi" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="TabButton" ValidationGroup="none"
						Style="height: 24px" />
				</td>
			</tr>
		</table>
		<asp:ObjectDataSource ID="odsGrid" runat="server" TypeName="OrganigrammaDataSetTableAdapters.UnitaOperativeRegimiTableAdapter"
			SelectMethod="GetData" OldValuesParameterFormatString="{0}" UpdateMethod="Update">
			<SelectParameters>
				<asp:QueryStringParameter Name="IdUnitaOperativa" QueryStringField="Id" DbType="Guid" />
			</SelectParameters>
			<UpdateParameters>
				<asp:Parameter Name="UtenteModifica" Type="String" />
				<asp:QueryStringParameter Name="IdUnitaOperativa" QueryStringField="Id" DbType="Guid" />
				<asp:Parameter Name="CodiceRegime" Type="String" />
				<asp:Parameter Name="Abilitato" Type="Boolean" />
			</UpdateParameters>
		</asp:ObjectDataSource>
	</div>
</asp:Content>

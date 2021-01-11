<%@ Page Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeBehind="UtentiDettaglio.aspx.vb"
	Inherits="DI.DataWarehouse.Admin.UtentiDettaglio" Title="Dettaglio Utente" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="Server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"></asp:Label>
	<asp:Label ID="LabelTitolo" runat="server" CssClass="Title" Text="Label"></asp:Label>
	<asp:FormView ID="FormViewDettaglio" runat="server" DataKeyNames="Id" DataSourceID="odsDettaglio" EmptyDataText="Dettaglio non disponibile."
		EnableModelValidation="True" DefaultMode="Edit">
		<EditItemTemplate>
			<table class="table_dettagli" width="500px">
				<tr>
					<td class="Td-Text" width="150px">
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
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Ruolo
					</td>
					<td class="Td-Value">
						<asp:DropDownList ID="ddlRuolo" runat="server" Width="100%" AppendDataBoundItems="True" DataSourceID="odsRuoli"
							DataTextField="Descrizione" DataValueField="Id" >
							<asp:ListItem Text="" Value=""></asp:ListItem>
						</asp:DropDownList>
							<asp:RequiredFieldValidator ID="RequiredFieldValidator1" class="Error" runat="server"
							ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="ddlRuolo" />
					</td>
				</tr>				
				<tr>
					<td class="LeftFooter">
						<asp:Button ID="butElimina" runat="server" Text="Elimina" CssClass="Button" CommandName="Delete" OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione dell\'elemento?');"
							ValidationGroup="none" />
					</td>
					<td class="RightFooter">
						<asp:Button ID="butSalva" runat="server" Text="Conferma" CssClass="Button" CommandName="Update" />
						<asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Annulla" CssClass="Button" ValidationGroup="none" />
					</td>
				</tr>
			</table>
		</EditItemTemplate>
	</asp:FormView>
	<asp:Label ID="LabelWarning" runat="server" CssClass="Warning" Width="500px" EnableViewState="False" Text="L'utente non è utilizzabile in quanto non ha alcun ruolo assegnato dal Role Manager tramite l'interfaccia amministrativa SAC." Visible="false"/>

	<asp:ObjectDataSource ID="odsDettaglio" runat="server" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.UtentiTableAdapter"
		SelectMethod="GetData" UpdateMethod="Update" OldValuesParameterFormatString="{0}" DeleteMethod="Delete"
		InsertMethod="Insert">
		<InsertParameters>
			<asp:Parameter DbType="Guid" Name="Id" />
			<asp:Parameter Name="Utente" Type="String" />
			<asp:Parameter Name="Descrizione" Type="String" />
			<asp:Parameter DbType="Guid" Name="IdRuolo" />
		</InsertParameters>
		<SelectParameters>
			<asp:QueryStringParameter Name="ID" QueryStringField="Id" DbType="Guid" />
			<asp:Parameter Name="Utente" Type="String" />
			<asp:Parameter Name="Descrizione" Type="String" />
		</SelectParameters>
		<UpdateParameters>
			<asp:Parameter Name="ID" DbType="Guid" />
			<asp:Parameter Name="IdRuolo" DbType="Guid" />
		</UpdateParameters>
	</asp:ObjectDataSource>
	<asp:ObjectDataSource ID="odsRuoli" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData"
		TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.RuoliTableAdapter" CacheDuration="120" CacheKeyDependency="CacheRuoli"
		EnableCaching="True">
		<SelectParameters>
			<asp:QueryStringParameter DbType="Guid" Name="IdUtente" QueryStringField="Id" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>

<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="PermessiUtenteDettaglio.aspx.vb" Inherits="DI.Sac.Admin.PermessiUtenteDettaglio" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False" />
	<asp:Label ID="LabelTitolo" runat="server" CssClass="Title" EnableViewState="False"
		Text="Permessi Utente per il Servizio Organigramma" />
	<asp:FormView ID="MainFormView" runat="server" DataKeyNames="Id" DataSourceID="MainObjectDataSource"
		DefaultMode="Insert" EmptyDataText="Dettaglio non disponibile!" 
		EnableModelValidation="True">
		<InsertItemTemplate>
			<table class="table_dettagli">
				<tr>
					<td class="Td-Text" style="width: 200px;">
						Utente
					</td>
					<td class="Td-Value" style="width: 300px;">
						<asp:Label ID="lblUtente" runat="server" Text="" />
					</td>
				</tr>			
				<tr>
					<td class="Td-Text">
						Lettura
					</td>
					<td class="Td-Value">
						<asp:CheckBox ID="chkLettura" runat="server" Checked='<%# Bind("Lettura") %>' />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Scrittura
					</td>
					<td class="Td-Value">
						<asp:CheckBox ID="chkScrittura" runat="server" Checked='<%# Bind("Scrittura") %>' />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Cancellazione
					</td>
					<td class="Td-Value">
						<asp:CheckBox ID="chkCancellazione" runat="server" Checked='<%# Bind("Cancellazione") %>' />
					</td>
				</tr>			
				<tr>
					<td class="Td-Text2">
						Disattivato
					</td>
					<td class="Td-Value2">
						<asp:CheckBox ID="chkDisattivato" runat="server" Checked='<%# Bind("Disattivato") %>' />
					</td>
				</tr>
				<tr>
					<td colspan="2" class="RightFooter">
						<asp:Button ID="InsertButton" runat="server" CssClass="TabButton" CausesValidation="True"
							CommandName="Insert" Text="Conferma" />
						<asp:Button ID="InsertCancelButton" runat="server" CssClass="TabButton" CausesValidation="False"
							CommandName="Cancel" Text="Annulla" />
					</td>
				</tr>
			</table>
		</InsertItemTemplate>
		<EditItemTemplate>
			<table class="table_dettagli">
				<tr>
					<td class="Td-Text" style="width: 200px;">
						Utente
					</td>
					<td class="Td-Value" style="width: 300px;">
							<%# Eval("Utente") %>						
					</td>
				</tr>				
				<tr>
					<td class="Td-Text">
						Lettura
					</td>
					<td class="Td-Value">
						<asp:CheckBox ID="chkLettura" runat="server" Checked='<%# Bind("Lettura") %>' />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Scrittura
					</td>
					<td class="Td-Value">
						<asp:CheckBox ID="chkScrittura" runat="server" Checked='<%# Bind("Scrittura") %>' />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Cancellazione
					</td>
					<td class="Td-Value">
						<asp:CheckBox ID="chkCancellazione" runat="server" Checked='<%# Bind("Cancellazione") %>' />
					</td>
				</tr>			
				<tr>
					<td class="Td-Text2">
						Disattivato
					</td>
					<td class="Td-Value2">
						<asp:CheckBox ID="chkDisattivato" runat="server" Checked='<%# Bind("Disattivato") %>' />
					</td>
				</tr>
				<tr>
					<td colspan="2" class="RightFooter">
						<asp:Button ID="UpdateButton" runat="server" CssClass="TabButton" CausesValidation="True"
							CommandName="Update" Text="Conferma" />
						<asp:Button ID="UpdateCancelButton" runat="server" CssClass="TabButton" CausesValidation="False"
							CommandName="Cancel" Text="Annulla" />
					</td>
				</tr>
			</table>
		</EditItemTemplate>
	</asp:FormView>
	<asp:ObjectDataSource ID="MainObjectDataSource" runat="server" SelectMethod="GetData"
		TypeName="OrganigrammaDataSetTableAdapters.PermessiUtentiTableAdapter"
		InsertMethod="Insert" UpdateMethod="Update" 
		OldValuesParameterFormatString="{0}" >
		<UpdateParameters>
			<asp:QueryStringParameter Name="Id" QueryStringField="Id" DbType="Guid" />		
			<asp:Parameter Name="Lettura" Type="Boolean" />
			<asp:Parameter Name="Scrittura" Type="Boolean" />
			<asp:Parameter Name="Cancellazione" Type="Boolean" />
			<asp:Parameter Name="Disattivato" Type="Byte" />
		</UpdateParameters>
		<SelectParameters>
			<asp:QueryStringParameter Name="Id" QueryStringField="Id" DbType="Guid" />
		</SelectParameters>
		<InsertParameters>
			<asp:QueryStringParameter Name="Utente" QueryStringField="Utente" Type="String" />
			<asp:Parameter Name="Lettura" Type="Boolean" />
			<asp:Parameter Name="Scrittura" Type="Boolean" />
			<asp:Parameter Name="Cancellazione" Type="Boolean" />
			<asp:Parameter Name="Disattivato" Type="Byte" />
		</InsertParameters>
	</asp:ObjectDataSource>
	</asp:Content>

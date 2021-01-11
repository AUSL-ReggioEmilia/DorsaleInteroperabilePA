<%@ Page Title="Dettaglio Ruolo" Language="vb" AutoEventWireup="false" MasterPageFile="~/OrderEntry.Master" CodeBehind="DatiAggiuntiviDettaglio.aspx.vb"
	Inherits=".DatiAggiuntiviDettaglio" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />
	<asp:Label ID="LabelTitolo" runat="server" CssClass="Title" Text="Dettaglio Dato Aggiuntivo" />
	<asp:FormView ID="FormViewDettaglio" runat="server" DataKeyNames="Nome" DataSourceID="odsDettagli" EmptyDataText="Dettaglio non disponibile."
		EnableModelValidation="True" DefaultMode="Edit">
		<EditItemTemplate>
			<div id="toolbarAzioni" style="padding: 3px;">
				<asp:Button ID="butDelete" runat="server" Text="Elimina" CssClass="deleteLongButton" CommandName="Delete" OnClientClick="return confirm('Si conferma l\'eliminazione dell\'elemento?');" />
			</div>
			<table class="table_dettagli" width="500px">
				<tr>
					<td class="Td-Text" width="150px">
						Nome
					</td>
					<td class="Td-Value">
						<%# Eval("Nome") %>
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Descrizione
					</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtDesc" runat="server" Text='<%# Bind("Descrizione") %>' TextMode="MultiLine" Rows="4" MaxLength="256"
							Width="100%" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Visibile
					</td>
					<td class="Td-Value">
						<asp:CheckBox ID="chkVisibile" runat="server" Checked='<%# Bind("Visibile") %>' />
					</td>
				</tr>
				<tr>
					<td class="LeftFooter">
						<asp:Button ID="butSalva" runat="server" Text="Conferma" CssClass="TabButton" CommandName="Update" />
					</td>
					<td class="RightFooter">
						<asp:Button ID="butChiudi" runat="server" Text="Chiudi" CssClass="TabButton" CommandName="Cancel" CausesValidation="false" />
					</td>
				</tr>
			</table>
		</EditItemTemplate>
		<InsertItemTemplate>
			<table class="table_dettagli" width="500px">
				<tr>
					<td class="Td-Text" width="150px">
						Nome
					</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtCodice" runat="server" Text='<%# Bind("Nome") %>' MaxLength="128" Width="100%" />
						<asp:RequiredFieldValidator runat="server" ID="ReqNome" CssClass="Error" ControlToValidate="txtCodice" ErrorMessage="Campo Obbligatorio"
							Display="Dynamic" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Descrizione
					</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtDesc" runat="server" Text='<%# Bind("Descrizione") %>' TextMode="MultiLine" Rows="4" MaxLength="256"
							Width="100%" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Visibile
					</td>
					<td class="Td-Value">
						<asp:CheckBox ID="chkVisibile" runat="server" Checked='<%# Bind("Visibile") %>' />
					</td>
				</tr>
				<tr>
					<td class="LeftFooter">
						<asp:Button ID="butSalva" runat="server" Text="Conferma" CssClass="TabButton" CommandName="Insert" />
					</td>
					<td class="RightFooter">
						<asp:Button ID="butChiudi" runat="server" Text="Chiudi" CssClass="TabButton" CommandName="Cancel" CausesValidation="false"/>
					</td>
				</tr>
			</table>
		</InsertItemTemplate>
	</asp:FormView>
	<asp:ObjectDataSource ID="odsDettagli" runat="server" TypeName="DatiAggiuntiviTableAdapters.UiDatiAggiuntiviTableAdapter"
		SelectMethod="GetDataByNome" UpdateMethod="Update" OldValuesParameterFormatString="{0}" DeleteMethod="Delete"
		InsertMethod="Insert">
		<DeleteParameters>
			<asp:Parameter Name="Nome" Type="String" />
		</DeleteParameters>
		<InsertParameters>
			<asp:Parameter Name="Nome" Type="String" />
			<asp:Parameter Name="Descrizione" Type="String" />
			<asp:Parameter Name="Visibile" Type="Boolean" />
		</InsertParameters>
		<SelectParameters>
			<asp:QueryStringParameter Name="Nome" QueryStringField="Nome" Type="String" />
		</SelectParameters>
		<UpdateParameters>
			<asp:Parameter Name="Nome" Type="String" />
			<asp:Parameter Name="Descrizione" Type="String" />
			<asp:Parameter Name="Visibile" Type="Boolean" />
		</UpdateParameters>
	</asp:ObjectDataSource>
</asp:Content>

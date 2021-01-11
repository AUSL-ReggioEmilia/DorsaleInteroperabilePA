<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="UtenteDettaglio.aspx.vb" Inherits="DI.Sac.Admin.UtenteDettaglio" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<asp:FormView ID="MainFormView" runat="server" DataKeyNames="Utente" DataSourceID="MainObjectDataSource"
		DefaultMode="Edit" EmptyDataText="Dettaglio non disponibile!">
		<EditItemTemplate>
			<table class="table_dettagli">
				<tr>
					<td class="toolbar" colspan="2">
						<p>
							Dettaglio Utente</p>
						Nome: <span class="LabelReadOnly">
							<%#Eval("Utente")%>
						</span>
					</td>
				</tr>
				<tr>
					<td colspan="2">
					</td>
				</tr>
				<tr>
					<td class="Td-Text" style="width: 200px;">
						Descrizione
					</td>
					<td class="Td-Value" style="width: 300px;">
						<asp:TextBox ID="txtDescrizione" runat="server" Text='<%# Bind("Descrizione") %>'
							CssClass="Input64" MaxLength="128" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Dipartimentale
					</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtDipartimentale" runat="server" Text='<%# Bind("Dipartimentale") %>'
							CssClass="Input64" MaxLength="128" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Email Responsabile
					</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtEmailResponsabile" runat="server" Text='<%# Bind("EmailResponsabile") %>'
							CssClass="Input64" MaxLength="128" />
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
			<span class="Title">Abilitazione Servizi</span>
			<asp:GridView ID="gvUtentiServizi" runat="server" AllowPaging="True" AllowSorting="false"
				AutoGenerateColumns="False" DataSourceID="UtentiServiziListaObjectDataSource" EmptyDataText="Nessun risultato!"
				GridLines="Horizontal" PageSize="20" Width="100%" PagerSettings-Position="TopAndBottom"
				CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
				PagerStyle-CssClass="Pager">
				<Columns>
					<asp:TemplateField HeaderText="Servizio">
						<ItemTemplate>
							<a href='<%#Getlink(Eval("DetailPage"),Eval("Id"))%>'>
								<%#Eval("Servizio")%></a>
						</ItemTemplate>
					</asp:TemplateField>
					<asp:BoundField DataField="Provenienza" HeaderText="Provenienza" />
					<asp:CheckBoxField DataField="Lettura" HeaderText="Lettura" />
					<asp:CheckBoxField DataField="Scrittura" HeaderText="Scrittura" />
					<asp:CheckBoxField DataField="Cancellazione" HeaderText="Cancellazione" />
					<asp:BoundField DataField="LivelloAttendibilita" HeaderText="Livello Attendibilità" />
					<asp:BoundField DataField="Disattivato" HeaderText="Stato" />
				</Columns>
			</asp:GridView>
		</EditItemTemplate>
	</asp:FormView>
	<asp:ObjectDataSource ID="MainObjectDataSource" runat="server" SelectMethod="GetData"
		TypeName="DI.Sac.Admin.Data.UtentiDataSetTableAdapters.UtentiTableAdapter" UpdateMethod="Update"
		InsertMethod="Insert">
		<UpdateParameters>
			<asp:Parameter Name="Utente" Type="String" />
			<asp:Parameter Name="Descrizione" Type="String" />
			<asp:Parameter Name="Dipartimentale" Type="String" />
			<asp:Parameter Name="EmailResponsabile" Type="String" />
			<asp:Parameter Name="Disattivato" Type="Byte" />
		</UpdateParameters>
		<SelectParameters>
			<asp:QueryStringParameter Name="Utente" QueryStringField="utente" Type="String" />
		</SelectParameters>
		<InsertParameters>
			<asp:Parameter Name="Utente" Type="String" />
			<asp:Parameter Name="Descrizione" Type="String" />
			<asp:Parameter Name="Dipartimentale" Type="String" />
			<asp:Parameter Name="EmailResponsabile" Type="String" />
			<asp:Parameter Name="Disattivato" Type="Byte" />
		</InsertParameters>
	</asp:ObjectDataSource>
	<asp:ObjectDataSource ID="UtentiServiziListaObjectDataSource" runat="server" SelectMethod="GetData"
		TypeName="DI.Sac.Admin.Data.UtentiDataSetTableAdapters.UtentiServiziListaTableAdapter"
		OldValuesParameterFormatString="{0}">
		<SelectParameters>
			<asp:QueryStringParameter Name="Utente" QueryStringField="utente" Type="String" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>

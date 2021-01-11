<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="EntitaAccessiLista.aspx.vb"
	Inherits="DI.Sac.Admin.EntitaAccessiLista" Title="Untitled Page" EnableEventValidation="false" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<table class="toolbar">
		<tr>
			<td>
				<asp:HyperLink ID="lnkNuovo" runat="server" NavigateUrl="NuovoAccesso.aspx"><img src="../Images/newitem.gif" alt="Nuovo accesso" class="toolbar-img"/>Nuovo accesso</asp:HyperLink>
			</td>
		</tr>
	</table>
	<br />
	<asp:GridView ID="gvEntitaAccessi" runat="server" AllowPaging="True" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="MainObjectDataSource" EmptyDataText="Nessun risultato!"
		GridLines="Horizontal" PageSize="20" DataKeyNames="Id" Width="100%" PagerSettings-Position="TopAndBottom"
		CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
		PagerStyle-CssClass="Pager">
		<Columns>
			<asp:TemplateField ShowHeader="False">
				<ItemTemplate>
					<asp:ImageButton ID="ibtnModifica" runat="server" CausesValidation="False" CommandName="Edit"
						ImageUrl="~/Images/editInPlace.gif" AlternateText="Modifica" CssClass="ImageButton" />
				</ItemTemplate>
				<EditItemTemplate>
					<asp:ImageButton ID="ibtnAggiorna" runat="server" CausesValidation="True" CommandName="Update"
						CssClass="ImageButton" ImageUrl="~/Images/saveInPlace.gif" AlternateText="Aggiorna"
						CommandArgument='<%# String.Format("{0},{1},{2}", Eval("Nome"), Eval("Dominio"), Eval("Tipo")) %>' />
					&nbsp;<asp:ImageButton ID="ibtnCancella" runat="server" CausesValidation="False"
						CssClass="ImageButton" CommandName="Cancel" ImageUrl="~/Images/undoInPlace.gif"
						AlternateText="Annulla" />
				</EditItemTemplate>
				<ItemStyle Width="40px" />
			</asp:TemplateField>
			<asp:CheckBoxField DataField="Amministratore" HeaderText="Admin" SortExpression="Amministratore"
				ItemStyle-Width="50px" />
			<asp:TemplateField ShowHeader="True" HeaderText="Account">
				<ItemTemplate>
					<asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl='<%# String.Format("~/EntitaAccessi/EntitaAccessoDettaglio.aspx?id={0}",Eval("ID")) %>'
						Text='<%# String.Format("{0}\{1}",Eval("Dominio"), Eval("Nome")) %>' />
				</ItemTemplate>
			</asp:TemplateField>
			<asp:BoundField DataField="Descrizione1" HeaderText="Display Name" SortExpression="Descrizione1"
				ReadOnly="true" />
			<asp:BoundField DataField="Descrizione2" HeaderText="Common Name" SortExpression="Descrizione2"
				ReadOnly="true" />
			<asp:BoundField DataField="Descrizione3" HeaderText="Descrizione" SortExpression="Descrizione3"
				ReadOnly="true" />
			<asp:TemplateField ShowHeader="False">
				<ItemTemplate>
					<asp:ImageButton ID="ibtnElimina" runat="server" CausesValidation="False" CommandName="Delete"
						CssClass="ImageButton" ImageUrl="~/Images/delete.gif" AlternateText="Elimina" CommandArgument='<%# String.Format("{0},{1},{2}", Eval("Nome"), Eval("Dominio"), Eval("Tipo")) %>'
						OnClientClick='<%#  ConfirmDelete(Eval("Dominio"), Eval("Nome"), Eval("Tipo"))  %>' />
				</ItemTemplate>
			</asp:TemplateField>
		</Columns>
	</asp:GridView>
	<asp:ObjectDataSource ID="MainObjectDataSource" runat="server" DeleteMethod="Delete"
		SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.PermessiDataSetTableAdapters.EntitaAccessiTableAdapter"
		UpdateMethod="Update" InsertMethod="Insert">
		<UpdateParameters>
			<asp:Parameter Name="Id" Type="Object" />
			<asp:Parameter Name="Amministratore" Type="Boolean" />
		</UpdateParameters>
		<InsertParameters>
			<asp:Parameter Name="Id" Type="Object" />
			<asp:Parameter Name="Nome" Type="String" />
			<asp:Parameter Name="Descrizione1" Type="String" />
			<asp:Parameter Name="Descrizione2" Type="String" />
			<asp:Parameter Name="Descrizione3" Type="String" />
			<asp:Parameter Name="Dominio" Type="String" />
			<asp:Parameter Name="Tipo" Type="Byte" />
			<asp:Parameter Name="Amministratore" Type="Boolean" />
		</InsertParameters>
	</asp:ObjectDataSource>
</asp:Content>

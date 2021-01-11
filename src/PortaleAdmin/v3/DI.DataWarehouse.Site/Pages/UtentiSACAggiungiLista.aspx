<%@ Page Title="Sistemi" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="UtentiSACAggiungiLista.aspx.vb"
	Inherits=".UtentiSACAggiungiLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<style type="text/css">
		body
		{
			/*  necessario quando si usa screenMask  */
			overflow: hidden;
		}
	</style>
	<div class="screenMask">
	</div>
	<div class="pseudo-popup" style="width: 800px; height: 90%;">
		<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />
		<asp:Label ID="LabelTitolo" CssClass="Title" runat="server" Text="Selezionare l'utente da aggiungere" />
		<fieldset class="filters">
			<legend>Ricerca</legend>
			<table id="pannelloFiltri" class="table_dettagli" runat="server">
				<tr>
					<td>
						Utente
					</td>
					<td>
						<asp:TextBox ID="txtFiltriUtente" runat="server" Width="200px" MaxLength="128" />
					</td>
					<td>
						Descrizione
					</td>
					<td>
						<asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="200px" MaxLength="128" />
					</td>
					<td width="100%">
						<asp:Button ID="butFiltriRicerca" runat="server" CssClass="Button" Text="Cerca" />
					</td>
				</tr>
			</table>
		</fieldset>
		<table class="table_pulsanti" width="100%">
			<tr>
				<td class="Left">
					<asp:Button ID="butAnnullaTop" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="Button" ValidationGroup="none" />
				</td>
				<td class="Right">
				</td>
			</tr>
		</table>
		<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.SACUtentiTableAdapter"
			OldValuesParameterFormatString="original_{0}" EnableCaching="True" CacheKeyDependency="ListaUtenti" CacheDuration="120"
			InsertMethod="Insert">
			<InsertParameters>
				<asp:Parameter Name="Id" DbType="Guid" />
				<asp:Parameter Name="Utente" Type="String" />
				<asp:Parameter Name="Descrizione" Type="String" ConvertEmptyStringToNull="true"/>
				<asp:Parameter DbType="Guid" Name="IdRuolo" ConvertEmptyStringToNull="true" />
			</InsertParameters>
			<SelectParameters>
				<asp:ControlParameter ControlID="txtFiltriUtente" Name="Utente" PropertyName="Text" Type="String" />
				<asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text" Type="String" />
				<asp:Parameter Name="Top" DefaultValue="200" Type="Int32" />
			</SelectParameters>
		</asp:ObjectDataSource>
		<asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="True" DataSourceID="odsLista" AutoGenerateColumns="False"
			PageSize="100" CssClass="Grid" Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom"
			DataKeyNames="Id,Utente,Descrizione">
			<Columns>
				<asp:ButtonField DataTextField="Utente" HeaderText="Utente" SortExpression="Utente" ButtonType="Link" CommandName="Insert" />
				<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
				<asp:TemplateField HeaderText="Nome e Cognome" SortExpression="Nome">
					<ItemTemplate>
						<%#Eval("Nome")%>&nbsp;<%#Eval("Cognome")%>
					</ItemTemplate>
				</asp:TemplateField>
				<asp:BoundField DataField="Email" HeaderText="Email" SortExpression="Email" />
				<asp:CheckBoxField DataField="Attivo" HeaderText="Attivo" SortExpression="Attivo" HeaderStyle-Width="10px"  />
			</Columns>
			<RowStyle CssClass="GridItem" />
			<SelectedRowStyle CssClass="GridSelected" />
			<PagerSettings Position="TopAndBottom"></PagerSettings>
			<PagerStyle CssClass="GridPager" />
			<HeaderStyle CssClass="GridHeader" />
			<AlternatingRowStyle CssClass="GridAlternatingItem" />
			<FooterStyle CssClass="GridFooter" />
		</asp:GridView>
		<table class="table_pulsanti" width="100%">
			<tr>
				<td class="Left">
					<asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="Button" ValidationGroup="none" />
				</td>
				<td class="Right">
				</td>
			</tr>
		</table>
	</div>
</asp:Content>

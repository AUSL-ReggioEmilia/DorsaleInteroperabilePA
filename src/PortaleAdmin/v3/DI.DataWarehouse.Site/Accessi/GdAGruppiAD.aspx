<%@ Page Title="Oggetti Active Directory" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="GdAGruppiAD.aspx.vb" Inherits=".GdAGruppiAD" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="Server">
	<style type="text/css">
		body
		{
			/*  necessario quando si usa screenMask  */
			overflow: hidden;
		}
	</style>
	<div class="screenMask">
	</div>
	<div class="pseudo-popup" style="width: 700px; height: 90%;">
		<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False"></asp:Label>
		<asp:Label ID="lblTitolo" runat="server" CssClass="Title" Text=""></asp:Label>
		<table id="pannelloFiltri" runat="server" class="toolbar">
			<tr>
				<td colspan="5">
					<br />
				</td>
			</tr>
			<tr>
				<td>
					Gruppo
				</td>
				<td>
					<asp:TextBox ID="txtFiltriGruppo" runat="server" Width="170px" MaxLength="128"></asp:TextBox>
				</td>
				<td>
					Descrizione
				</td>
				<td>
					<asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="170px" MaxLength="256"></asp:TextBox>
				</td>
				<td width="100%">
					<asp:Button ID="butFiltriRicerca" runat="server" CssClass="Button" Text="Cerca" />
				</td>
			</tr>
			<tr>
				<td colspan="5">
					<br />
				</td>
			</tr>
		</table>
		<table class="table_pulsanti" width="100%">
			<tr>
				<td class="Left">
					<asp:Button ID="butEliminaTop" runat="server" Text="Elimina Selezionati" CssClass="Button" CommandName="Delete"
						OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione degli elementi selezionati?');" ValidationGroup="none"
						Width="10em" />
					<asp:Button ID="butAggiungiTop" runat="server" Text="Aggiungi..." CssClass="Button" CommandName="Insert" />
					<asp:Button ID="butConfermaTop" runat="server" Text="Aggiungi Selezionati" CssClass="Button" Style="width: 140px;"
						CommandName="Insert" />
				</td>
				<td class="Right">
					<asp:Button ID="butAnnullaTop" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="Button" ValidationGroup="none" />
				</td>
			</tr>
		</table>
		<asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False" DataSourceID="odsLista"
			PageSize="100" Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom"
			DataKeyNames="Id,Gruppo" CssClass="Grid">
			<AlternatingRowStyle CssClass="AlternatingRow"></AlternatingRowStyle>
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
				<asp:BoundField DataField="Gruppo" HeaderText="Gruppo" SortExpression="Gruppo" />
				<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
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
					<asp:Button ID="butElimina" runat="server" Text="Elimina Selezionati" CssClass="Button" CommandName="Delete" OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione degli elementi selezionati?');"
						ValidationGroup="none" Width="10em" />
					<asp:Button ID="butAggiungi" runat="server" Text="Aggiungi..." CssClass="Button" CommandName="Insert" />
					<asp:Button ID="butConferma" runat="server" Text="Aggiungi Selezionati" CssClass="Button" Style="width: 140px;"
						CommandName="Insert" />
				</td>
				<td class="Right" width="50%">
					<asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="Button" ValidationGroup="none" />
				</td>
			</tr>
		</table>
	</div>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="AccessiDataSetTableAdapters.GdAGruppiADTableAdapter"
		CacheDuration="120" CacheKeyDependency="CacheGdAGruppiAD" EnableCaching="True" OldValuesParameterFormatString="{0}"
		DeleteMethod="Delete" InsertMethod="Insert">
		<SelectParameters>
			<asp:QueryStringParameter DbType="Guid" Name="IdGdA" QueryStringField="Id" />
			<asp:ControlParameter ControlID="txtFiltriGruppo" Name="Gruppo" PropertyName="Text" Type="String" />
			<asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text" Type="String" />
			<asp:Parameter DefaultValue="200" Name="Top" Type="Int32" />
		</SelectParameters>
		<InsertParameters>
			<asp:Parameter Name="UtenteInserimento" Type="String" />
			<asp:Parameter DbType="Guid" Name="IdGdA" />
			<asp:Parameter Name="NomeGruppoAD" Type="String" />
		</InsertParameters>		
		<DeleteParameters>
			<asp:Parameter DbType="Guid" Name="Id" />
		</DeleteParameters>
	</asp:ObjectDataSource>
</asp:Content>

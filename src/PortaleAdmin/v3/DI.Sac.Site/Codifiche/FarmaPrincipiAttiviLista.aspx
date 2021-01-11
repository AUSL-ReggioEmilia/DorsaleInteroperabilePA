<%@ Page Title="Principi Attivi" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="FarmaPrincipiAttiviLista.aspx.vb" Inherits=".FarmaPrincipiAttiviLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False" />
	<table id="pannelloFiltri" runat="server" class="toolbar">
		<tr>
			<td colspan="9">
				<br />
			</td>
		</tr>
		<tr>
			<td>
				Codice
			</td>
			<td>
				<asp:TextBox ID="txtFiltriCodice" runat="server" Width="120px" MaxLength="6" />
				<asp:RegularExpressionValidator ControlToValidate ="txtFiltriCodice" runat ="server" id="reg1" Display="Dynamic" ValidationExpression="^[0-9]{1,6}$" ErrorMessage="Inserire un codice numerico"></asp:RegularExpressionValidator>
			</td>
			<td>
				Descrizione
			</td>
			<td>
				<asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="120px" MaxLength="200" />
			</td>
			<td>
				ATC Correlati
			</td>
			<td>
				<asp:TextBox ID="txtFiltriATC" runat="server" Width="120px" MaxLength="7" />
			</td>
			<td>
				Principio Attivo&nbsp;Base
			</td>
			<td>
				<asp:TextBox ID="txtFiltriPrincipioAttivoBase" runat="server" Width="120px" MaxLength="6" />
			</td>
			<td width="100%">
				<asp:Button ID="butFiltriRicerca" runat="server" CssClass="TabButton" Text="Cerca" />
			</td>
		</tr>
		<tr>
			<td colspan="9">
				<br />
			</td>
		</tr>
	</table>
	<br />
	<asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="True"
		AutoGenerateColumns="False" DataSourceID="odsLista" GridLines="Horizontal" PageSize="100"
		Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom"
		DataKeyNames="Id" CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
		PagerStyle-CssClass="Pager">
		<AlternatingRowStyle CssClass="AlternatingRow"></AlternatingRowStyle>
		<Columns>
			<%--			<asp:BoundField DataField="IdentificaTipoFile" HeaderText="IdentificaTipoFile" 
				SortExpression="IdentificaTipoFile" />
			<asp:BoundField DataField="TipoMovimento" HeaderText="TipoMovimento" 
				SortExpression="TipoMovimento" />--%>
			<asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice" />
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
			<asp:BoundField DataField="PABase" HeaderText="Principio Attivo Base" SortExpression="PABase" />
			<asp:BoundField DataField="ATCCorrelati" HeaderText="ATC Correlati" SortExpression="ATCCorrelati" />
			<asp:BoundField DataField="Veterinario" HeaderText="Veterinario" SortExpression="Veterinario" />
			<asp:BoundField DataField="ScadenzaBrevetto" HeaderText="Scadenza Brevetto" SortExpression="ScadenzaBrevetto"
				DataFormatString="{0:dd/M/yyyy}" />	
		</Columns>
		<HeaderStyle CssClass="Header"></HeaderStyle>
		<PagerSettings Position="TopAndBottom"></PagerSettings>
		<PagerStyle CssClass="Pager"></PagerStyle>
	</asp:GridView>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="CodificheDataSetTableAdapters.FarmaPrincipiAttiviTableAdapter"
		CacheDuration="120" CacheKeyDependency="CacheFarmaPrincipiAttiviLista" EnableCaching="True" >
		<SelectParameters>
			<asp:ControlParameter ControlID="txtFiltriCodice" Name="Codice" PropertyName="Text"
				Type="Int32" />
			<asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="txtFiltriATC" Name="ATCCorrelati" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="txtFiltriPrincipioAttivoBase" Name="PABase" PropertyName="Text"
				Type="String" />
			<asp:Parameter Name="Top" Type="Int32" DefaultValue="500" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>

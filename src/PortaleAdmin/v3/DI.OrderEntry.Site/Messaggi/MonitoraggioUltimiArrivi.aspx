<%@ Page Title="Sistemi" Language="vb" AutoEventWireup="false" MasterPageFile="~/OrderEntry.Master" CodeBehind="MonitoraggioUltimiArrivi.aspx.vb"
	Inherits=".MonitoraggioUltimiArrivi" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />
	<div class="Title" style="width: 800px;">
		In questo quadro riassuntivo vengono mostrati per ciascuna accoppiata Azienda + Sistema Richiedente la data di
		modifica dell'ultimo ordine ricevuto e il numero di ordini ricevuti nell'ultima ora.
	</div>
	<asp:GridView ID="gvRicevuti" runat="server" AllowSorting="True" DataSourceID="odsRicevuti" AutoGenerateColumns="False"
		CssClass="Grid" Width="600px" EnableModelValidation="True" EmptyDataText="Nessun risultato!">
		<Columns>
			<asp:BoundField DataField="CodiceAzienda" HeaderText="Azienda" SortExpression="CodiceAzienda" />
			<asp:BoundField DataField="CodiceSistema" HeaderText="Sistema Richiedente" SortExpression="CodiceSistema" />
			<asp:BoundField DataField="DataModifica" HeaderText="Data Modifica" SortExpression="DataModifica" ItemStyle-Width="140" />
			<asp:BoundField DataField="Count" HeaderText="Ordini" SortExpression="Count" />
		</Columns>
		<RowStyle CssClass="GridItem" />
		<SelectedRowStyle CssClass="GridSelected" />
		<PagerStyle CssClass="GridPager" />
		<HeaderStyle CssClass="GridHeader" />
		<AlternatingRowStyle CssClass="GridAlternatingItem" />
		<FooterStyle CssClass="GridFooter" />
	</asp:GridView>
	<asp:ObjectDataSource ID="odsRicevuti" runat="server" SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.MessaggiTableAdapters.UiOrdiniTestateUltimiArriviTableAdapter"
		OldValuesParameterFormatString="original_{0}">
		<SelectParameters>
			<asp:Parameter Name="NumeroOre" Type="Int32" DefaultValue="1" />
		</SelectParameters>
	</asp:ObjectDataSource>
	<div class="Title" style="width: 800px; margin-top: 20px;">
		In questo quadro riassuntivo vengono mostrati per ciascuna accoppiata Azienda + Sistema Erogante la data di modifica
		dell'ultimo ordine inoltrato e il numero di ordini inoltrati nell'ultima ora.
	</div>
	<asp:GridView ID="gvErogati" runat="server" AllowSorting="True" DataSourceID="odsErogati" AutoGenerateColumns="False"
		CssClass="Grid" Width="600px" EnableModelValidation="True" EmptyDataText="Nessun risultato!">
		<Columns>
			<asp:BoundField DataField="CodiceAzienda" HeaderText="Azienda" SortExpression="CodiceAzienda" />
			<asp:BoundField DataField="CodiceSistema" HeaderText="Sistema Erogante" SortExpression="CodiceSistema" />
			<asp:BoundField DataField="DataModifica" HeaderText="Data Modifica" SortExpression="DataModifica" ItemStyle-Width="140" />
			<asp:BoundField DataField="Count" HeaderText="Ordini" SortExpression="Count" />
		</Columns>
		<RowStyle CssClass="GridItem" />
		<SelectedRowStyle CssClass="GridSelected" />
		<PagerStyle CssClass="GridPager" />
		<HeaderStyle CssClass="GridHeader" />
		<AlternatingRowStyle CssClass="GridAlternatingItem" />
		<FooterStyle CssClass="GridFooter" />
	</asp:GridView>
	<asp:ObjectDataSource ID="odsErogati" runat="server" SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.MessaggiTableAdapters.UiOrdiniErogatiTestateUltimiArriviTableAdapter"
		OldValuesParameterFormatString="original_{0}">
		<SelectParameters>
			<asp:Parameter Name="NumeroOre" Type="Int32" DefaultValue="1" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>

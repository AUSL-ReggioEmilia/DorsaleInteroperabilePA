﻿<%@ Page Title="Sistemi" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="EventiUltimiArrivi.aspx.vb"
	Inherits=".EventiUltimiArrivi" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />
	<div class="Title" style="width: 600px;">
		In questo quadro riassuntivo vengono mostrati per ciascuna accoppiata Azienda + Sistema eroganti la data di modifica
		dell'ultimo evento e il numero di eventi ricevuti nell'ultima ora.
	</div>
	<asp:GridView ID="gvLista" runat="server" AllowSorting="True" DataSourceID="odsLista" AutoGenerateColumns="False"
		CssClass="Grid" Width="600px" EnableModelValidation="True" EmptyDataText="Nessun risultato!">
		<Columns>
			<asp:BoundField DataField="AziendaErogante" HeaderText="Azienda Erogante" SortExpression="AziendaErogante" />
			<asp:BoundField DataField="SistemaErogante" HeaderText="Sistema Erogante" SortExpression="SistemaErogante" />
			<asp:BoundField DataField="DataModifica" HeaderText="Data Modifica" SortExpression="DataModifica" />
			<asp:BoundField DataField="Count" HeaderText="Numero Eventi" SortExpression="Count" />
		</Columns>
		<RowStyle CssClass="GridItem" />
		<SelectedRowStyle CssClass="GridSelected" />
		<PagerStyle CssClass="GridPager" />
		<HeaderStyle CssClass="GridHeader" />
		<AlternatingRowStyle CssClass="GridAlternatingItem" />
		<FooterStyle CssClass="GridFooter" />
	</asp:GridView>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" 
		TypeName="MonitorTableAdapters.BevsEventiUltimiArriviTableAdapter" 
		OldValuesParameterFormatString="original_{0}">
		<SelectParameters>
			<asp:Parameter Name="NumeroOre" Type="Int32" DefaultValue="1" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>

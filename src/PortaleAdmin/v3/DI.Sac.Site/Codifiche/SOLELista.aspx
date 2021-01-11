<%@ Page Title="SOLE" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="SOLELista.aspx.vb" Inherits=".SOLELista" %>

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
				Codice Prestazione
			</td>
			<td>
				<asp:TextBox ID="txtFiltriCodicePrestazione" runat="server" Width="120px" MaxLength="16" />
			</td>
			<td>
				Codice Specialità
			</td>
			<td>
				<asp:TextBox ID="txtFiltriCodiceSpecialità" runat="server" Width="120px" MaxLength="16" />
			</td>
			<td>
				Codice Branca
			</td>
			<td>
				<asp:TextBox ID="txtFiltriCodiceBranca" runat="server" Width="120px" MaxLength="16" />
			</td>
			<td>
				Valido Dal
			</td>
			<td>
				<asp:TextBox ID="txtFiltriValidoDal" runat="server" Width="90px" MaxLength="10" />
			</td>
			<td>
			</td>
		</tr>
		<tr>
			<td>
				Descrizione Prestazione
			</td>
			<td>
				<asp:TextBox ID="txtFiltriDescrizionePrestazione" runat="server" Width="120px" MaxLength="256" />
			</td>
			<td>
				Descrizione Specialità
			</td>
			<td>
				<asp:TextBox ID="txtFiltriDescrizioneSpecialità" runat="server" Width="120px" MaxLength="256" />
			</td>
			<td>
				Descrizione Branca
			</td>
			<td>
				<asp:TextBox ID="txtFiltriDescrizioneBranca" runat="server" Width="120px" MaxLength="256" />
			</td>
			<td>
				Al
			</td>
			<td>
				<asp:TextBox ID="txtFiltriValidoAl" runat="server" Width="90px" MaxLength="10" />
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
		AutoGenerateColumns="False"  DataSourceID="odsLista" GridLines="Horizontal"
		PageSize="100" Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!"
		PagerSettings-Position="TopAndBottom" DataKeyNames="Id"
		CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"	PagerStyle-CssClass="Pager">
		<Columns>
			<asp:TemplateField HeaderText="Prestazione" SortExpression="CodicePrestazione">
				<ItemStyle Width="10%" />
				<ItemTemplate>
					<b>
						<%#Eval("CodicePrestazione")%>
					</b>
					<br />
					<%#Eval("DescrizionePrestazione")%>
				</ItemTemplate>
			</asp:TemplateField>
			<asp:TemplateField HeaderText="DMR" SortExpression="CodiceDmr">
				<ItemTemplate>
					<b>
						<%#Eval("CodiceDmr")%>
					</b>
					<br />
					<%#Eval("DescrizioneDmr")%>
				</ItemTemplate>
			</asp:TemplateField>
			<asp:TemplateField HeaderText="Specialità" SortExpression="CodiceSpecialita">
				<ItemTemplate>
					<b>
						<%#Eval("CodiceSpecialita")%>
					</b>
					<br />
					<%#Eval("DescrizioneSpecialita")%>
				</ItemTemplate>
			</asp:TemplateField>
			<asp:BoundField DataField="Branche" HeaderText="Branche" />
			<asp:TemplateField HeaderText="Oscurato">
				<ItemTemplate>					
					<%#If(Eval("Oscurato"),"Sì","No")%>
				</ItemTemplate>
			</asp:TemplateField>
			<asp:BoundField DataField="DataInizioValidita" HeaderText="Inizio Validità" SortExpression="DataInizioValidita"
				DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="DataFineValidita" HeaderText="Fine Validità" SortExpression="DataFineValidita"
				DataFormatString="{0:dd/M/yyyy}" />
			<asp:BoundField DataField="NotaInizioValidita" HeaderText="Nota Inizio Validità"
				SortExpression="NotaInizioValidita" />
			<asp:BoundField DataField="NotaFineValidita" HeaderText="Nota Fine Validità" SortExpression="NotaFineValidita" />
			<asp:BoundField DataField="Importo" HeaderText="Importo" SortExpression="Importo"
				DataFormatString="{0:C}" />
			<asp:BoundField DataField="Esenzione" HeaderText="Esenzione" SortExpression="Esenzione" />
		</Columns>	
	</asp:GridView>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="CodificheDataSetTableAdapters.SOLECodifichePrestazioniTableAdapter"
		OldValuesParameterFormatString="{0}"	CacheDuration="120" CacheKeyDependency="CacheSOLELista" EnableCaching="True" >
		<SelectParameters>
			<asp:ControlParameter ControlID="txtFiltriCodicePrestazione" Name="CodicePrestazione"
				PropertyName="Text" Type="String" />
			<asp:ControlParameter ControlID="txtFiltriDescrizionePrestazione" Name="DescrizionePrestazione"
				PropertyName="Text" Type="String" />
			<asp:ControlParameter ControlID="txtFiltriCodiceSpecialità" Name="CodiceSpecialita"
				PropertyName="Text" Type="String" />
			<asp:ControlParameter ControlID="txtFiltriDescrizioneSpecialità" Name="DescrizioneSpecialita"
				PropertyName="Text" Type="String" />
			<asp:ControlParameter ControlID="txtFiltriValidoDal" Name="DataInizioValidita" PropertyName="Text"
				Type="DateTime" />
			<asp:ControlParameter ControlID="txtFiltriValidoAl" Name="DataFineValidita" PropertyName="Text"
				Type="DateTime" />
			<asp:ControlParameter ControlID="txtFiltriCodiceBranca" Name="CodiceBranca" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="txtFiltriDescrizioneBranca" Name="DescrizioneBranca"
				PropertyName="Text" Type="String" />
			<asp:Parameter Name="Top" Type="Int32" DefaultValue="500" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>

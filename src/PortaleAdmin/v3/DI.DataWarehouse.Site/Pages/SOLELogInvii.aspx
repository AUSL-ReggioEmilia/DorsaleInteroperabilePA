<%@ Page Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeBehind="SOLELogInvii.aspx.vb"
	Inherits="DI.DataWarehouse.Admin.SOLELogInvii" Title="Log Notifiche SOLE" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="Server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False"></asp:Label>
	<div style="padding: 3px">
		<asp:Button ID="DeleteButton" CssClass="deleteButton" runat="server" Text="Cancella Referto su SOLE" TabIndex="10"
			OnClientClick="return msgboxYESNO('Si conferma l\'invio della notifica di cancellazione a SOLE?');" />
		<asp:Button ID="RiprocessaButton" CssClass="rinotificaButton" runat="server" Text="Riprocessa Referto su SOLE" TabIndex="10"
			OnClientClick="return msgboxYESNO('Si conferma il riprocessamento del referto su SOLE?');" />
	</div>

	<asp:Label ID="lblTitolo" runat="server" class="Title" Text="" Style="margin-top: 10px;" />
	<asp:GridView ID="GridViewMain" runat="server" DataSourceID="DataSourceMain" AutoGenerateColumns="False" CssClass="Grid"
		Width="100%" EnableModelValidation="True" EmptyDataText="Nessun Risultato.">
		<Columns>
			<asp:BoundField DataField="DataQueue" HeaderText="Data Queue" />
			<asp:BoundField DataField="IdReferto" HeaderText="Id Referto" />
			<asp:CheckBoxField DataField="InviatoSole" HeaderText="Inviato SOLE" />
			<asp:BoundField DataField="DataInvioSole" HeaderText="Data Invio SOLE" />
			<asp:CheckBoxField DataField="Oscurato" HeaderText="Oscurato" />
			<asp:BoundField DataField="CodiceOscuramento" HeaderText="Codice Oscuramento" />
			<asp:CheckBoxField DataField="Processato" HeaderText="Processato" />
			<asp:BoundField DataField="DataProcesso" HeaderText="Data Processo" />
			<asp:BoundField DataField="EsitoProcesso" HeaderText="Esito Processo" />
			<asp:TemplateField HeaderText="Referto">
				<ItemTemplate>
					<%# Eval("NumeroReferto")%>
					<br />
					<%# Eval("DataReferto", "{0:d}")%>
				</ItemTemplate>
			</asp:TemplateField>
			<asp:CheckBoxField DataField="RefertoConfidenziale" HeaderText="Referto Confidenziale" />
			<asp:CheckBoxField DataField="Verificato" HeaderText="Verificato" />
			<asp:BoundField DataField="Versione" HeaderText="Versione" />
			<asp:BoundField DataField="EsitoSoleStato" HeaderText="Esito SOLE Stato" />
			<asp:TemplateField HeaderText="Anno / Numero">
				<ItemTemplate>
					<%# Eval("IdAnno")%>
					/
					<%# Eval("IdNumero")%>
				</ItemTemplate>
			</asp:TemplateField>
		</Columns>
		<RowStyle CssClass="GridItem" />
		<SelectedRowStyle CssClass="GridSelected" />
		<PagerStyle CssClass="GridPager" />
		<HeaderStyle CssClass="GridHeader" />
		<AlternatingRowStyle CssClass="GridAlternatingItem" />
		<FooterStyle CssClass="GridFooter" />
	</asp:GridView>
	<asp:ObjectDataSource ID="DataSourceMain" runat="server" SelectMethod="GetDataByIdReferto" TypeName="DI.DataWarehouse.Admin.Data.SoleTableAdapters.LogInviiSoleTableAdapter"
		OldValuesParameterFormatString="{0}">
		<SelectParameters>
			<asp:QueryStringParameter DbType="Guid" Name="IdReferto" QueryStringField="IdReferto" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>

<%@ Page Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeBehind="SistemiErogantiDocumentiDettaglio.aspx.vb"
	Inherits="DI.DataWarehouse.Admin.SistemiErogantiDocumentiDettaglio" Title="Untitled Page" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="Server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"></asp:Label>
	<table width="600px" class="table_dettagli">
		<tr>
			<td style="width: 130px;">
				Sistema erogante:
			</td>
			<td>
				<asp:DropDownList ID="SistemaEroganteDropDownList" runat="server" DataSourceID="DataSourceSistemiEroganti" DataTextField="Codice"
					DataValueField="Id" Width="300px">
				</asp:DropDownList>
			</td>
		</tr>
		<tr>
			<td style="width: 130px;">
				Nome del file:
			</td>
			<td valign="middle">
				<asp:TextBox ID="NomeTextBox" runat="server" Text='<%# GetFileName(DataBinder.Eval(_mainDataSet, "Tables[SistemiErogantiDocumentiDettaglio].DefaultView.[0].Nome"), DataBinder.Eval(_mainDataSet, "Tables[SistemiErogantiDocumentiDettaglio].DefaultView.[0].Estensione")) %>'
					ReadOnly="True" Width="300px"></asp:TextBox>
				<asp:Button ID="UploadButton" runat="server" Text="Upload" />
				<asp:HyperLink ID="ViewDocumentLink" Target="_blank" runat="server"><img src="../Images/ViewDoc.gif"  border=0  /></asp:HyperLink>
			</td>
		</tr>
		<tr>
			<td style="width: 130px;">
				Dimensione del file:
			</td>
			<td>
				<asp:TextBox ID="DimensioneTextBox" runat="server" Text='<%# DataBinder.Eval(_mainDataSet, "Tables[SistemiErogantiDocumentiDettaglio].DefaultView.[0].Dimensione") %>'
					ReadOnly="True"></asp:TextBox>
				&nbsp;Byte
			</td>
		</tr>
		<tr>
			<td style="width: 130px;">
				Content-Type:
			</td>
			<td>
				<asp:TextBox ID="ContentTypeTextBox" runat="server" Text='<%# DataBinder.Eval(_mainDataSet, "Tables[SistemiErogantiDocumentiDettaglio].DefaultView.[0].ContentType") %>'
					ReadOnly="True"></asp:TextBox>
			</td>
		</tr>
		<tr>
			<td class="LeftFooter">
				<asp:Button ID="EliminaButton" CssClass="Button" runat="server" Text="Elimina"></asp:Button>
			</td>
			<td class="RightFooter">
				<asp:Button ID="OkButton" CssClass="Button" runat="server" Text="OK"></asp:Button>
				<asp:Button ID="RitornaButton" CssClass="Button" runat="server" Text="Annulla"></asp:Button>
				<asp:Button ID="SalvaButton" CssClass="Button" runat="server" Text="Applica"></asp:Button>
			</td>
		</tr>
	</table>
	<asp:ObjectDataSource ID="DataSourceSistemiEroganti" runat="server" OldValuesParameterFormatString="original_{0}"
		SelectMethod="SistemiErogantiCombo" TypeName="DI.DataWarehouse.Admin.Data.DataAdapterManager">
		<SelectParameters>
			<asp:Parameter Name="AziendaErogante" Type="String" />
		</SelectParameters>
	</asp:ObjectDataSource> 
</asp:Content>

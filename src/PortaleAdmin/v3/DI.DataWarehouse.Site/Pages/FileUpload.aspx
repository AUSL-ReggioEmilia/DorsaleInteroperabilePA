<%@ Page Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeBehind="FileUpload.aspx.vb"
	Inherits="DI.DataWarehouse.Admin.FileUpload" Title="Untitled Page" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="Server">
	<asp:Label ID="ErrorMessageLabel" runat="server" CssClass="Error" Visible="False"></asp:Label>	
	<asp:Label ID="TitleLabel" runat="server" CssClass="Title">Upload documenti</asp:Label>
	
	<table id="ContainerTable" class="table_dettagli" width="500px">
		<tr>
			<td colspan="9">
				<asp:Label ID="InfoLabel" runat="server">Selezionare il file desiderato e premere il pulsante OK.</asp:Label>
			</td>
		</tr>
		<tr>
			<td class="Td-Text">
				<asp:Label ID="FileLabel" CssClass="UploadPageLabel" Text="File da caricare" runat="server">File: </asp:Label>
			</td>
			<td class="Td-Value">
				<input id="InputFile" style="height: 22px" type="file" size="50" runat="server">
				<asp:RequiredFieldValidator ID="fv1" runat="server" Display="Dynamic" CssClass="Error" ErrorMessage="Selezionare il file da caricare" ControlToValidate="InputFile"/>
			</td>
		</tr>
		<tr>
			<td style="display:none;">
				<input type="hidden" value="Save" name="Cmd">
				<input type="hidden" name="NextUsing">
				<input type="hidden" value="New">
				<input type="hidden" value="true" name="putopts">
				<input type="hidden" name="destination">
				<input type="hidden" value="<%=GetConfirmationUrl()%>" name="Confirmation-URL">
				<input type="hidden" value="<%=GetPostUrl()%>" name="PostURL">
				<input type="hidden" value="0" name="VTI-GROUP">
			</td>
		</tr>	
		<tr>
			<td colspan="9" class="RightFooter">
				<asp:Button ID="OkButton" CssClass="Button" runat="server" Text="OK"/>
				<asp:Button ID="CancelButton" CssClass="Button" runat="server" Text="Annulla" CausesValidation="False" />
			</td>
		</tr>
	</table>
</asp:Content>

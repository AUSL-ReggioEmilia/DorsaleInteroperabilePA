<%@ Register TagPrefix="uc1" TagName="BarraNavigazione" Src="~/NavigationBar.ascx" %>

<%@ Page Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false" Inherits="DwhClinico.Web.Referti_RefertiLista" Title="" Codebehind="RefertiLista.aspx.vb" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <table cellpadding="0" cellspacing="0" border="0" class="ExpandWidthHeight" id="tblContainer">
        <tr>
            <td valign="top">
                <uc1:BarraNavigazione ID="NavBar" runat="server"></uc1:BarraNavigazione>
            </td>
        </tr>
        <tr>
            <td valign="top">
                <asp:Label ID="lblErrorMessage" runat="server" EnableViewState="False" CssClass="errore"
                    Visible="False"></asp:Label>
            </td>
        </tr>
        <tr>
            <td valign="top" height="100%">
                <div id="IFrameContent" class="IFrameContent">
                    <iframe id="IframeMain" runat="server" class="ExpandWidthHeight" frameborder="0"
                        scrolling="yes">
                        <div id="DivNoIframeMain" runat="server" class="NoIFrameContent">
                            <a id="LinkNoIframeMain" runat="server" target="_blank">Apri il contenuto</a>
                        </div>
                    </iframe>
                </div>
            </td>
        </tr>
    </table>
</asp:Content>

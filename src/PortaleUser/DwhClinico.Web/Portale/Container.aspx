<%@ Page Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false" Inherits="DwhClinico.Web.Portale_Container" Title="" Codebehind="Container.aspx.vb" %>

<asp:Content ID="ContentMain" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <table cellpadding="0" cellspacing="0" border="0" class="ExpandWidthHeight" id="tblContainer">
        <tr height="1">
            <td id=DivNavBar runat="server">
            </td>
        </tr>
        <tr height="1">
            <td>
                <table class="PageTitleContent" cellspacing="0" cellpadding="0" border="0">
                    <tr>
                        <td class="PageTitle">
                            <asp:Label ID="LabelTitle" runat="server" Text=""></asp:Label>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td valign="top" height="100%">
                <div class="IFrameContent">
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

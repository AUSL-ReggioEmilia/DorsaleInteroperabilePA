<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="RefertoDettaglioEsterno.ascx.vb" Inherits="DwhClinico.Web.RefertoDettaglioEsterno" %>
<%-- IFRAME REFERTO --%>
<div class="row" id="divErrorMessage" visible="false" runat="server">
    <div class="col-sm-12">
        <div class="alert alert-danger">
            <asp:Label ID="lblErrorMessage" runat="server" CssClass="text-danger"></asp:Label>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-sm-12">
        <div class="embed-responsive embed-responsive-4by3">
            <iframe id="IframeMain" runat="server" class="embed-responsive-item custom-embed-responsive-item"
                scrolling="yes">
                <div id="DivNoIframeMain" runat="server" class="NoIFrameContent">
                    <a id="LinkNoIframeMain" runat="server" href="#" target="_blank">Apri il contenuto</a>
                </div>
            </iframe>
        </div>
    </div>
</div>

<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="RefertoDettaglioPdf.ascx.vb" Inherits="DwhClinico.Web.RefertoDettaglioPdf" %>
<%-- IFRAME REFERTO --%>
<div class="row" id="divErrorMessage" visible="false" runat="server">
    <div class="col-sm-12">
        <div class="alert alert-danger">
            <asp:Label ID="lblErrorMessage" runat="server" CssClass="text-danger"></asp:Label>
        </div>
    </div>
</div>


<div id="divMessage" class="well well-sm" runat="server">
    <asp:Label ID="lblMessage" runat="server" />
</div>

<div class="row">
    <div class="col-sm-12">
        <div class="embed-responsive embed-responsive-16by9">
            <iframe id="IframeMain" runat="server" class="embed-responsive-item custom-embed-responsive-item"
                scrolling="no">
                <div id="DivNoIframeMain" runat="server" class="NoIFrameContent">
                    <a id="LinkNoIframeMain" runat="server" href="#" target="_blank">Apri il contenuto</a>
                </div>
            </iframe>
        </div>
    </div>
</div>

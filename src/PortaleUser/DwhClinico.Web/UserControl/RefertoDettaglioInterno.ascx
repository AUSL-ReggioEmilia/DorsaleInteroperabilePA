<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="RefertoDettaglioInterno.ascx.vb" Inherits="DwhClinico.Web.RefertoDettaglioInterno" %>
<link href="../Content/Visualizzazioni.css" rel="stylesheet" />
<div class="row" id="divErrorMessage" visible="false" runat="server">
    <div class="col-sm-12">
        <div class="alert alert-danger">
            <asp:Label ID="lblErrorMessage" runat="server" CssClass="text-danger"></asp:Label>
        </div>
    </div>
</div>

<div Id="divContainerTrasformation" class="row divContainerTrasformation" runat="server">
    <div class="col-sm-12">
        <div id="divTestata" runat="server"></div>
        <asp:HyperLink ID="lnkDocumentoPdf" runat="server" Target="_top">Visualizza il documento PDF</asp:HyperLink>
        <div id="divDettaglio" runat="server"></div>
        <div id="divFromAllegatoXml" runat="server"></div>
        <!--  Visualizzazione del campo Referto in formato RTF-->
        <div id="divRefertoFromRTFMain" runat="server">
            <table style="margin: 5px" cellspacing="0" cellpadding="0" border="0" runat="server">
                <tr>
                    <td class="Title">
                        <asp:Label ID="lbldivRefertoFromRTF_Titolo" runat="server" Text=""></asp:Label>
                    </td>
                </tr>
                <tr height="3px">
                </tr>
                <tr>
                    <td>
                        <div id="divRefertoFromRTF" runat="server"></div>
                    </td>
                </tr>
            </table>
        </div>
        <!--  Visualizzazione dell'aalegato RTF del referto -->
        <div id="divRefertoFromAllegatoRTFMain" runat="server">
            <br />
            <br />
            <table cellspacing="0" cellpadding="0" border="0">
                <tr>
                    <td class="Title">
                        <asp:Label ID="lbldivRefertoFromAllegatoRTF_Titolo" runat="server" Text=""></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td class="Container">
                        <div id="divRefertoFromAllegatoRTF" runat="server">
                        </div>
                    </td>
                </tr>
            </table>
        </div>
    </div>
</div>
<!-- Questo serve per visualizzare eventuale allegato a cui si naviga cliccando un link ottenuto dalla trasformazione XSLT-->
<div Id="divContainerIframe" class="row" runat="server">
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
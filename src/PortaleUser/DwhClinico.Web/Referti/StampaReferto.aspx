<%@ Page Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false" Inherits="DwhClinico.Web.Referti_StampaReferto" Title="" CodeBehind="StampaReferto.aspx.vb" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">

    <div class="row">
        <div class="col-sm-12">
            <asp:Label ID="lblErrorMessage" runat="server" EnableViewState="False" CssClass="text-danger"></asp:Label>
        </div>
    </div>

    <!-- Tabella contenente l'Iframe in cui si naviga all'applicazione di rendering PDF + stampa -->
    <div class="row" id="divStampaContainer" runat="server">
        <div class="col-sm-4 col-sm-offset-4" id="divStampaByRenderingPdf" runat="server">
            <div id="IFrameContent">
                <iframe id="IframeStampa" runat="server" style="width:100%;height:350px;border:none">
                    <div id="DivNoIframeMain" runat="server" class="NoIFrameContent">
                        <a id="LinkNoIframeStampa" runat="server" target="_blank">Apri il contenuto</a>
                    </div>
                </iframe>
            </div>
        </div>
    </div>


    <div id="trStampaDiretta" runat="server" class="row">
        <div id="divStampaDiretta" class="col-sm-12">
            <asp:Label ID="lblUserInformation" runat="server"></asp:Label>
        </div>
    </div>

        <!-- Tabella contenente l'Iframe in cui si naviga all'applicazione di rendering PDF per visualizzare il PDF di test-->
    <div id="divPdfContainer" runat="server" class="row">
        <div id="IFrameContent2" class="col-sm-12">
            <div class="embed-responsive embed-responsive-4by3">
                <iframe id="IframePdf" runat="server">
                    <div id="DivNoIframePdf" runat="server" class="embed-responsive-item">
                        <a id="LinkNoIframePdf" runat="server" target="_blank">Apri il contenuto</a>
                    </div>
                </iframe>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-4 col-sm-offset-4 text-center">
            <asp:Button ID="btnExit" runat="server" Text="Esci" CssClass="btn btn-sm btn-primary" />
        </div>
    </div>



</asp:Content>

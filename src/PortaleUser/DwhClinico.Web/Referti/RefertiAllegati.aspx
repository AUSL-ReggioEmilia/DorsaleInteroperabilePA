<%@ Page Title="" Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false" Inherits="DwhClinico.Web.Referti_RefertiAllegati" CodeBehind="RefertiAllegati.aspx.vb" %>

<%@ Register Src="~/UserControl/ucTestataPaziente.ascx" TagPrefix="uc1" TagName="ucTestataPaziente" %>
<%@ Register Src="~/UserControl/ucInfoPaziente.ascx" TagPrefix="uc1" TagName="ucInfoPaziente" %>



<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <div class="row" id="divErrorMessage" runat="server">
        <div class="col-sm-12">
            <div class="alert alert-danger">
                <asp:Label ID="lblErrorMessage" runat="server" EnableViewState="False" />
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-9 col-md-9 col-lg-10">

            <uc1:ucTestataPaziente runat="server" ID="ucTestataPaziente" />

            <%--<uc1:ucInfoPaziente runat="server" ID="ucInfoPaziente" />--%>

            <div class="row" id="divTestataReferto" runat="server">
                <div class="col-sm-12">
                    <label class="label label-default">Testata referto</label>
                    <div class="well well-sm small">
                        <div class="form">
                            <div class="row">
                                <div class="col-sm-6">
                                    <div class="col-sm-6">
                                        <asp:Label Text="Data:" runat="server" AssociatedControlID="lblDataReferto" />
                                    </div>
                                    <asp:Label ID="lblDataReferto" runat="server" CssClass="form-control-static"></asp:Label>
                                </div>
                                <div class="col-sm-6">
                                    <div class="col-sm-6">
                                        <asp:Label Text="Numero:" runat="server" AssociatedControlID="lblNumeroReferto" />
                                    </div>
                                    <asp:Label ID="lblNumeroReferto" runat="server" CssClass="form-control-static"></asp:Label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-6">
                                    <div class="col-sm-6">
                                        <asp:Label Text="Nosologico:" runat="server" AssociatedControlID="lblNosologico" />
                                    </div>
                                    <asp:Label ID="lblNosologico" runat="server" CssClass="form-control-static"></asp:Label>
                                </div>
                                <div class="col-sm-6">
                                    <div class="col-sm-6">
                                        <asp:Label Text="Azienda erogante:" runat="server" AssociatedControlID="lblAziendaErogante" />
                                    </div>
                                    <asp:Label ID="lblAziendaErogante" runat="server" CssClass="form-control-static"></asp:Label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-6">
                                    <div class="col-sm-6">
                                        <asp:Label Text="Sistema erogante:" runat="server" AssociatedControlID="lblSistemaErogante" />
                                    </div>
                                    <asp:Label ID="lblSistemaErogante" runat="server" CssClass="form-control-static"></asp:Label>
                                </div>
                                <div class="col-sm-6">
                                    <div class="col-sm-6">
                                        <asp:Label Text="Reparto erogante:" runat="server" AssociatedControlID="lblRepartoErogante" />
                                    </div>
                                    <asp:Label ID="lblRepartoErogante" runat="server"></asp:Label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-6">
                                    <div class="col-sm-6">
                                        <asp:Label Text="Reparto richiedente:" runat="server" AssociatedControlID="lblRepartoRichiedente" />
                                    </div>
                                    <asp:Label ID="lblRepartoRichiedente" runat="server"></asp:Label>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Elenco degli allegati  -->
            <div class="row small">
                <div class="col-sm-12">
                    <div runat="server" id="divElencoAllegati" class="table-responsive">
                        <asp:GridView ID="WebGridAllegati" runat="server" AutoGenerateColumns="False"
                            DataKeyField="ID" DefaultColumnWidth="" DefaultRowHeight=""
                            CssClass="table table-striped table-bordered table-condensed">
                            <Columns>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:HyperLink ID="hlReferto" runat="server" Text="Apri" NavigateUrl='<%# BuildUrlOpenAllegato(Eval("IdEsterno")) %>'></asp:HyperLink>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Descrizione">
                                    <ItemTemplate>
                                        <asp:Label ID="lblDescrizione" runat="server" Text='<%# GetDescrizioneAllegato(Eval("Descrizione")) %>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Data">
                                    <ItemTemplate>
                                        <asp:Label ID="lblDataModifica" runat="server" Text='<%# GetDataModificaAllegato(Eval("DataFile")) %>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>

            <div class="row" id="TblPdfContainer" runat="server">
                <div class="col-sm-12">
                    <div class="embed-responsive embed-responsive-16by9">
                        <div id="IFrameContent" class="IFrameContent">
                            <iframe id="IframeMain" runat="server" class="ExpandWidthHeight" frameborder="0"
                                scrolling="yes">
                                <div id="DivNoIframeMain" runat="server" class="NoIFrameContent">
                                    <a id="LinkNoIframeMain" runat="server" target="_blank">Apri il contenuto</a>
                                </div>
                            </iframe>
                        </div>
                    </div>
                </div>
            </div>

        </div>
        <div class="col-sm-3 col-md-3 col-lg-2">
            <div id="rightSidebar" data-offset-top="64" data-spy="affix">
                <div class="custom-margin-right-sidebar">
                    <div class="row">
                        <div class="col-sm-12">
                            <asp:Button Text="Torna indietro" ID="cmdEsci" CssClass="toolbarbtn-top-custom-margin btn btn-primary btn-block btn-sm" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

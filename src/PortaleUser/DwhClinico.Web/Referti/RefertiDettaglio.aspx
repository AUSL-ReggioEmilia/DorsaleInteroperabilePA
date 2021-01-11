<%@ Page Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false" Inherits="DwhClinico.Web.Referti_RefertiDettaglio" Title="" CodeBehind="RefertiDettaglio.aspx.vb" %>

<%@ Register Src="~/UserControl/ucStampaReferti.ascx" TagPrefix="uc1" TagName="StampaReferti" %>
<%@ Register Src="~/UserControl/ucTestataPaziente.ascx" TagPrefix="uc1" TagName="ucTestataPaziente" %>
<%@ Register Src="~/UserControl/RefertoDettaglioEsterno.ascx" TagPrefix="uc1" TagName="RefertoDettaglioEsterno" %>
<%@ Register Src="~/UserControl/RefertoDettaglioPdf.ascx" TagPrefix="uc1" TagName="RefertoDettaglioPdf" %>
<%@ Register Src="~/UserControl/RefertoDettaglioInterno.ascx" TagPrefix="uc1" TagName="RefertoDettaglioInterno" %>
<%@ Register Src="~/UserControl/ucModaleInvioLinkPerAccessoDiretto.ascx" TagPrefix="uc1" TagName="ucModaleInvioLinkPerAccessoDiretto" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <div class="row" id="divErrorMessage" visible="false" runat="server">
        <div class="col-sm-12">
            <div class="alert alert-danger">
                <asp:Label ID="lblErrorMessage" runat="server" CssClass="text-danger"></asp:Label>
            </div>
        </div>
    </div>

    <div id="divPage" runat="server">
        <div class="row">
            <div class="col-sm-9 col-md-9 col-lg-10">
                <%-- TESTATA PAZIENTE --%>
                <uc1:ucTestataPaziente runat="server" ID="ucTestataPaziente" />

                <%-- PANNELLINO AVVERTENZE --%>
                <div class="row" id="DivPannelloAvvertenze" visible="false" runat="server">
                    <div class="col-sm-12">
                        <label class="label label-default">
                            Avvertenze
                        </label>
                        <div class="panel panel-default">
                            <div class="panel-body small">
                                <asp:Label ID="LabelAvertenze" Text="" runat="server">
                                </asp:Label>
                            </div>
                        </div>
                    </div>
                </div>


                <%-- MODALE STAMPA --%>
                <div class="modal fade bs-example-modal-lg" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel" id="ModalStampa">
                    <div class="modal-dialog modal-lg">
                        <uc1:StampaReferti runat="server" ID="StampaReferti" />
                    </div>
                </div>

                <%-- MODALE MODALITA' DI GENERAZIONE DEL REFERTO --%>
                <div class="modal fade" id="ModalGenerazioneReferto" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
                    <div class="modal-dialog modal-lg" role="document">
                        <div class="modal-content" style="overflow: hidden">
                            <div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                                <h4 class="modal-title" id="myModalLabel">Modalità di generazione del referto</h4>
                            </div>
                            <div class="modal-body">
                                <div class="embed-responsive embed-responsive-4by3">
                                    <iframe class="embed-responsive-item" src="#" id="ModalIframe" runat="server"></iframe>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-default" data-dismiss="modal" runat="server">Chiudi</button>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- REPEATER PER VISUALIZZAZIONE DELLE NOTE. --%>
                <div id="divElencoNote" runat="server" class="row">
                    <div class="col-sm-12">
                        <h4><strong>Elenco note associate al referto</strong></h4>
                        <table class="table table-bordered table-condensed">
                            <tbody>
                                <asp:Repeater ID="RepeaterNote" runat="server" DataSourceID="DataSourceNote">
                                    <ItemTemplate>
                                        <tr>
                                            <td>
                                                <strong>Autore:</strong>
                                                <asp:Label Text=' <%#DataBinder.Eval(Container.DataItem, "Autore")%>' runat="server" /><br />
                                                <strong>Data:</strong>
                                                <asp:Label Text='<%#DataBinder.Eval(Container.DataItem, "DataNota", "{0:g}")%>' runat="server" />
                                            </td>
                                            <td style="width: 80%">
                                                <%#GetNota(DataBinder.Eval(Container.DataItem, "Nota"))%>
                                            </td>
                                            <td class="text-center">
                                                <asp:LinkButton OnClientClick="javascript: return confirm('Confermi la cancellazione della nota?');"
                                                    CommandArgument='<%#DataBinder.Eval(Container.DataItem, "Id")%>' ID="IdImageCancella"
                                                    runat="server" Visible='<%# GetCancellaVisibile(DataBinder.Eval(Container.DataItem, "RuoloDelete"))%>'>
                                                    <span class="glyphicon glyphicon-remove" aria-hidden="true"></span>
                                                </asp:LinkButton>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                </div>

                <%-- LABEL DELLA VERSIONE REFERTO --%>
                <div class="row">
                    <div class="col-sm-12">
                        <asp:Label ID="LabelVersione" Text="" class="label label-default" Visible="false" runat="server">
                        </asp:Label>

                        <div id="PanelEsternoLabelVersione" runat="server">
                            <div id="PanelInternoLabelVersione" runat="server">
                                <div id="divIframeEsterno">
                                    <uc1:RefertoDettaglioEsterno runat="server" ID="RefertoDettaglioEsterno" />
                                    <uc1:RefertoDettaglioInterno runat="server" ID="RefertoDettaglioInterno" />
                                </div>
                                <div id="divIframePdf">
                                    <uc1:RefertoDettaglioPdf runat="server" ID="RefertoDettaglioPdf" ClientIDMode="Static" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>


            </div>

            <div class="col-sm-3 col-md-3 col-lg-2">
                <%-- PANNELLO FILTRI --%>
                <div id="rightSidebar" data-offset-top="100" data-spy="affix">
                    <div class="custom-margin-right-sidebar">
                        <div class="row">
                            <div class="col-sm-12">
                                <uc1:ucModaleInvioLinkPerAccessoDiretto runat="server" ID="ucModaleInvioLinkPerAccessoDiretto" />
                                <asp:Button ID="cmdEsci" CssClass="btn btn-primary btn-sm btn-block" Text="Torna indietro" runat="server" />
                                <asp:Button ID="btnApriAllegato" runat="server" Text="Stampa" CssClass="btn btn-default btn-sm btn-block"
                                    Visible="False" />
                                <asp:Button ID="btnExecutePrint" runat="server"
                                    CssClass="btn btn-default btn-sm btn-block" Text=" Stampa"></asp:Button>
                                <input id="hlModoImportazione" value="Modalità di generazione del referto" runat="server" type="button" name="name" class="btn btn-sm btn-default btn-block" data-toggle="modal" data-target="#ModalGenerazioneReferto" />
                                <asp:Button ID="ButtonAggiungiNota" runat="server" Text="Segnala nota al referto" CssClass="btn btn-danger btn-sm btn-block" />
                            </div>
                            <div id="divEsito" runat="server" class="col-sm-12">
                                <hr />
                                <div class="jumbotron jumbotron-custom">
                                    <div class="container" style="padding: 0px">
                                        <div id="contenitoreEsitoSOLE" runat="server">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <asp:ObjectDataSource ID="DataSourceNote" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetDataRefertiNoteLista" TypeName="DwhClinico.Data.Referti">
        <SelectParameters>
            <asp:Parameter Name="IdReferto" Type="Object" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <script src="../Scripts/referti-dettaglio.js"></script>
</asp:Content>

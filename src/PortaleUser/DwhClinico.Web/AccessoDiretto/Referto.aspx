<%@ Page Language="VB" MasterPageFile="~/AccessoDiretto/AccessoDiretto.master" AutoEventWireup="false" Inherits="DwhClinico.Web.AccessoDiretto_Referto" Title="" CodeBehind="Referto.aspx.vb" %>

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

    <div class="divPage" id="divPage" runat="server">
        <div class="row">
            <div class="col-sm-9 col-md-9 col-lg-10">

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
                                <div id="divIframeEsterno" runat="server">
                                    <uc1:RefertoDettaglioEsterno runat="server" ID="RefertoDettaglioEsterno" />
                                    <uc1:RefertoDettaglioPdf runat="server" ID="RefertoDettaglioPdf" />
                                    <uc1:RefertoDettaglioInterno runat="server" ID="RefertoDettaglioInterno" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>


            </div>
            <div class="col-sm-3 col-md-3 col-lg-2">
                <div id="rightSidebar" data-offset-top="100" data-spy="affix">
                    <div class="row">
                        <div class="col-sm-12">
                            <uc1:ucModaleInvioLinkPerAccessoDiretto runat="server" ID="ucModaleInvioLinkPerAccessoDiretto" />
                        </div>
                        <div class="col-sm-12">
                            <asp:Button ID="cmdEsci" Text="Torna alla lista" CssClass="btn btn-primary btn-sm btn-block" runat="server" />
                            <asp:Button ID="btnApriAllegato" runat="server" Text="Allegati" CssClass="btn btn-default btn-sm btn-block "
                                Visible="False" />
                        </div>
                        <div class="col-sm-12" id="divEsito" runat="server">
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

    <asp:ObjectDataSource ID="DataSourceNote" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetDataRefertiNoteLista" TypeName="DwhClinico.Data.Referti">
        <SelectParameters>
            <asp:Parameter Name="IdReferto" Type="Object" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <script src="../Scripts/referti-dettaglio.js"></script>
</asp:Content>

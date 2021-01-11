<%@ Page Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false" Inherits="DwhClinico.Web.Referti_RefertiNote" Title="" ValidateRequest="false" CodeBehind="RefertiNote.aspx.vb" %>

<%@ Register Src="~/UserControl/ucTestataPaziente.ascx" TagPrefix="uc1" TagName="ucTestataPaziente" %>
<%@ Register Src="~/UserControl/ucInfoPaziente.ascx" TagPrefix="uc1" TagName="ucInfoPaziente" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <div class="row" id="divErrorMessage" visible="false" runat="server">
        <div class="col-sm-12">
            <div class="alert alert-danger">
                <asp:Label ID="lblErrorMessage" runat="server" EnableViewState="False"></asp:Label>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12 ">
            <div class="alert alert-warning">
                <strong>
                    LE NOTE AL REFERTO SU DWH SONO UNO STRUMENTO DI SEGNALAZIONE DI EVENTUALI ANOMALIE SUL DOCUMENTO O MALFUNZIONAMENTI.
                    <br />
                    LE NOTE NON COSTITUISCONO ADDENDUM AL REFERTO O UN MEZZO LEGALMENTE VALIDO PER INTEGRARE O RETTIFICARE I CONTENUTI CLINICI DEL REFERTO.
                </strong>
            </div>
        </div>
    </div>


    <uc1:ucTestataPaziente runat="server" ID="ucTestataPaziente" />

    <uc1:ucInfoPaziente runat="server" ID="ucInfoPaziente" />

    <div class="row">
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

    <div class="row">
        <div class="col-sm-12">
            <div class="form small">
                <div class="form-group form-group-sm">
                    <asp:Label Text="Nota referto :" runat="server" AssociatedControlID="txtNote" />
                    <asp:TextBox ID="txtNote" runat="server" Rows="10" TextMode="MultiLine" CssClass="form-control" placeholder="Nota"></asp:TextBox>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <asp:Button ID="cmdSalva" runat="server" Text="Salva" CssClass="btn btn-primary btn-sm" OnClientClick="javascript:return confirm('Confermi inserimento della nota?');return false;" />
            <asp:Button Text="Annulla" runat="server" ID="cmdEsci" CssClass="btn btn-default btn-sm" />
        </div>
    </div>
</asp:Content>

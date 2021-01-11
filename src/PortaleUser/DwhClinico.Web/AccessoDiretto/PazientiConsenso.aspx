<%@ Page Title="" Language="VB" MasterPageFile="~/AccessoDiretto/AccessoDiretto.master"
    AutoEventWireup="false" Inherits="DwhClinico.Web.AccessoDiretto_PazientiConsenso"
    CodeBehind="PazientiConsenso.aspx.vb" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <%-- HEADER --%>
    <div class="row">
        <div class="col-sm-12">
            <div class="page-header">
                <h3>Dettaglio del Consenso</h3>
            </div>
        </div>
    </div>

    <%-- DIV ERRORE --%>
    <div class="row">
        <div class="col-sm-12">
            <div class="alert alert-danger" id="alertErrorMessage" runat="server" visible="false" enableviewstate="false">
                <asp:Label ID="lblErrorMessage" runat="server" EnableViewState="False" CssClass="text-danger"></asp:Label>
            </div>
        </div>
    </div>

    <%-- TESTATA PAZIENTTE --%>
    <div id="divDatiPaziente" runat="server">
        <div id="divPaziente" runat="server">
            <div class="row">
                <div class="col-sm-12">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            Paziente
                        </div>
                        <div class="panel-body">
                            <div class="form">
                                <div class="row">
                                    <div class="col-sm-6">
                                        <asp:Label Text="Cognome:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblCognome" />
                                        <asp:Label ID="lblCognome" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "Cognome") %>' CssClass="form-control-static">
                                        </asp:Label>
                                    </div>
                                    <div class="col-sm-6">
                                        <asp:Label Text="Nome:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblNome" />
                                        <asp:Label ID="lblNome" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "Nome") %>' CssClass="form-control-static">
                                        </asp:Label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-6">
                                        <asp:Label Text="Data di nascita:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblDataNascita" />
                                        <asp:Label ID="lblDataNascita" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "DataNascita", "{0:d}") %>' CssClass="form-control-static">
                                        </asp:Label>
                                    </div>
                                    <div class="col-sm-6">
                                        <asp:Label Text="Luogo di nascita:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblLuogoNascita" />
                                        <asp:Label ID="lblLuogoNascita" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "LuogoNascita") %>' CssClass="form-control-static">
                                        </asp:Label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-6">
                                        <asp:Label Text="Codice fiscale:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblCodiceFiscale" />
                                        <asp:Label ID="lblCodiceFiscale" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "CodiceFiscale") %>' CssClass="form-control-static">
                                        </asp:Label>
                                    </div>
                                    <div class="col-sm-6">
                                        <asp:Label Text="Codice Sanitario:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblCodiceSanitario" />
                                        <asp:Label ID="lblCodiceSanitario" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "CodiceSanitario") %>'>
                                        </asp:Label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-6">
                                        <asp:Label ID="lblDataDecessoDesc" runat="server" Font-Bold="True" Text="Data decesso:" CssClass="col-sm-6" AssociatedControlID="lblDataDecesso"></asp:Label>
                                        <asp:Label ID="lblDataDecesso" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "DataDecesso", "{0:d}") %>' CssClass="text-danger"></asp:Label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- PANEL CONSENSO --%>
    <div class="row">
        <div class="col-sm-12">
            <div class="panel panel-default">
                <div class="panel-heading">
                    Consenso
                </div>
                <div class="panel-body">
                    <div class="form">
                        <div class="row">
                            <div class="col-sm-4">
                                <div class="form-group">
                                    <asp:Label Text="Consenso:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblConsenso" />
                                    <asp:Label ID="lblConsenso" runat="server" CssClass="form-control-static">
                                     <%= GetImageStatoConsenso(moSacDettaglioPaziente.GetConsensoGenerico()) %>
                                
                                    </asp:Label>
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="form-group">
                                    <asp:Label ID="lblDataConsenso" runat="server" Text="Data:" CssClass="col-sm-6" AssociatedControlID="lblDataConsensoValue" />
                                    <asp:Label ID="lblDataConsensoValue" runat="server" Text="" CssClass="form-control-static" />
                                </div>
                            </div>

                            <div class="col-sm-4">
                                <div class="form-group">
                                    <input id="cmdRichiediConsenso" onclick="" type="button" class="btn btn-default btn-sm col-sm-4" value="Richiedi consenso"
                                        runat="server" />

                                    <input id="cmdModificaConsenso" onclick="" type="button" class="btn btn-default btn-sm col-sm-4" value="Modifica consenso"
                                        runat="server" />
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-4">
                                <div class="form-group">
                                    <asp:Label Text="Consenso Dossier:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblConsenso" />
                                    <asp:Label ID="lblConsensoDossier" runat="server" CssClass="form-control-static">
                                    <%= GetImageStatoConsenso(moSacDettaglioPaziente.GetConsensoDossier()) %>
                                    </asp:Label>
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="form-group">
                                    <asp:Label ID="lblDataConsensoDossier" runat="server" Text="Data:" CssClass="col-sm-6" AssociatedControlID="lblDataConsensoDossierValue" />
                                    <asp:Label ID="lblDataConsensoDossierValue" runat="server" Text="" CssClass="form-control-static" />
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="form-group">
                                    <input id="cmdRichiediConsensoDossier" class="btn btn-default btn-sm col-sm-6" onclick="" type="button"
                                        value="Richiedi consenso dossier" runat="server" />
                                    <input id="cmdModificaConsensoDossier" onclick="" type="button" class="btn btn-default btn-sm col-sm-4"
                                        value="Modifica consenso dossier" runat="server" />
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-4">
                                <div class="form-group">
                                    <asp:Label Text="Consenso Storico Dossier:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblConsensoStoricoDossier" />
                                    <asp:Label ID="lblConsensoStoricoDossier" runat="server" CssClass="form-control-static">
                                    <%= GetImageStatoConsenso(moSacDettaglioPaziente.GetConsensoDossierStorico()) %>
                                    </asp:Label>
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="form-group">
                                    <asp:Label ID="lblDataConsensoDossierStorico" runat="server" Text="Data:" CssClass="col-sm-6" AssociatedControlID="lblDataConsensoDossierStoricoValue" />
                                    <asp:Label ID="lblDataConsensoDossierStoricoValue" runat="server" Text="" CssClass="form-control-static" />

                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="form-group">
                                    <input id="cmdRichiediConsensoDossierStorico" class="btn btn-sm btn-default col-sm-4" onclick="" type="button"
                                        value="Richiedi consenso dossier storico" runat="server" />
                                    <input id="cmdModificaConsensoDossierStorico" class="btn btn-sm btn-default col-sm-4" onclick="" type="button"
                                        value="Modifica consenso dossier storico" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="divMotivoAccesso" runat="server" class="row">
        <div class="col-sm-6">
            <div class="form-horizontal">
                <div class="form-group">
                    <asp:Label Text="Motivo dell'accesso:" runat="server" CssClass="control-label col-sm-2" />
                    <div class="col-sm-8">
                        <asp:DropDownList ID="cmbMotiviAccesso" runat="server" CssClass="form-control">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="form-group">
                    <asp:Label ID="lblMessaggioAssenzaConsenso" CssClass="col-sm-12" runat="server"> </asp:Label>
                    <asp:Label ID="lblMessaggioUsaAccessoForzato" CssClass="col-sm-12" runat="server"></asp:Label>
                </div>
                <div id="divPulsanti" runat="server">
                    <div class="form-group">
                        <div class="col-sm-offset-2 col-sm-10">
                            <asp:Button ID="cmdForzaConsenso" runat="server" Text="Accesso necessità clinica urgente" CssClass="btn btn-sm btn-danger"></asp:Button>
                            <asp:Button ID="cmdAccedi" runat="server" Text="Accedi" CssClass="btn btn-sm btn-default" />
                            <asp:Button ID="cmdAnnulla" runat="server" Text="Esci" CssClass="btn btn-sm btn-default" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

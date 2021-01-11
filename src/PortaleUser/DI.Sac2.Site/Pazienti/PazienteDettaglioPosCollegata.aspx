<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PazienteDettaglioPosCollegata.aspx.vb" Inherits=".PazienteDettaglioPosCollegata" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <div class="row" id="divErrorMessage" visible="false" runat="server">
        <div class="col-sm-12">
            <div class="alert alert-danger">
                <asp:Label ID="LabelError" runat="server" CssClass="text-danger" EnableViewState="False"></asp:Label>
            </div>
        </div>
    </div>


    <div id="MainTable" runat="server">

        <label class="label label-default">Dettaglio paziente</label>
        <div class="well well-sm">
            <div class="row">
                <div class="col-sm-12">
                    <asp:FormView ID="PazienteDettaglioFormView" RenderOuterTable="false" runat="server" DataKeyNames="Id" DataSourceID="DettaglioPazienteObjectDataSource"
                        EmptyDataText="Dettaglio paziente non disponibile!" EnableModelValidation="True">
                        <ItemTemplate>
                            <div class="form-horizontal">
                                <div class="col-sm-6">
                                    <div class="form-group form-group-sm">
                                        <label for="lblCognome" class="col-sm-6 control-label">Cognome</label>
                                        <div class="col-sm-6">
                                            <p id="lblCognome" class="form-control-static"><%# Eval("Cognome") %></p>
                                        </div>
                                    </div>

                                    <div class="row form-group-sm">
                                        <label for="lblNome" class="col-sm-6 control-label ">Nome</label>
                                        <div class="col-sm-6">
                                            <p id="lblNome" class="form-control-static"><%# Eval("Nome") %></p>
                                        </div>
                                    </div>

                                    <div class="row form-group-sm">
                                        <label for="lblCodiceFiscales" class="col-sm-6 control-label">Codice fiscale</label>
                                        <div class="col-sm-6">
                                            <p id="lblCodiceFiscales" class="form-control-static"><%# Eval("CodiceFiscale") %></p>
                                        </div>
                                    </div>

                                    <div class="row form-group-sm">
                                        <label for="lblSesso" class="col-sm-6 control-label">Sesso</label>
                                        <div class="col-sm-6">
                                            <p id="lblSesso" class="form-control-static"><%# Eval("Sesso") %></p>
                                        </div>
                                    </div>

                                    <div class="row form-group-sm">
                                        <label for="lblDataNascita" class="col-sm-6 control-label">Data nascita</label>
                                        <div class="col-sm-6">
                                            <p id="lblDataNascita" class="form-control-static"><%# Eval("DataNascita", "{0:d}") %></p>
                                        </div>
                                    </div>

                                    <div class="row form-group-sm">
                                        <label for="lblComuneNascitaDescrizione" class="col-sm-6 control-label">Comune nascita</label>
                                        <div class="col-sm-6">
                                            <p id="lblComuneNascitaDescrizione" class="form-control-static"><%# Eval("ComuneNascitaDescrizione") %></p>
                                        </div>
                                    </div>

                                    <div class="row form-group-sm">
                                        <label for="lblProvinciaNascitaDescrizione" class="col-sm-6 control-label">Provincia nascita</label>
                                        <div class="col-sm-6">
                                            <p id="lblProvinciaNascitaDescrizione" class="form-control-static"><%# Eval("ProvinciaNascitaDescrizione") %></p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:FormView>
                </div>
            </div>
        </div>

        <label class="label label-default">Dettaglio posizione collegata</label>
        <div class="well well-sm">
            <div class="row">
                <div class="col-sm-12">
                    <div class="form-horizontal">
                        <asp:FormView ID="FormView" runat="server" DataKeyNames="IdPosizioneCollegata" RenderOuterTable="false"
                            DataSourceID="DettaglioPosizioniCollegateObjectDataSource" EmptyDataText="Dettaglio posizione collegata non disponibile!"
                            EnableModelValidation="True">
                            <ItemTemplate>

                                <div class="form-group form-group-sm">
                                    <label for="lblIdPosizioneCollegata" class="col-sm-3 control-label">Codice posizione collegata</label>
                                    <div class="col-sm-9">
                                        <strong>
                                            <p id="lblNome" class="h4" style="margin-top: 0px !important;">&nbsp;<%# Eval("IdPosizioneCollegata") %></p>
                                        </strong>
                                    </div>
                                </div>
                                <div class="form-group form-group-sm">
                                    <label for="lblNote" class="col-sm-3 control-label">Motivo</label>
                                    <div class="col-sm-9">
                                        <p id="lblNote" class="form-control-static"><%# Eval("Note") %></p>
                                    </div>
                                </div>
                                <hr />
                                <div class="form-group form-group-sm">
                                    <div class="col-sm-12">
                                        <asp:HyperLink ID="hlGoToPosOriginale" CssClass="btn btn-link" runat="server" NavigateUrl='<%#String.Format("~/Pazienti/PazienteDettaglio.aspx?Id={0}", Eval("IdSacOriginale")) %>'>Vai a posizione originale</asp:HyperLink>
                                    </div>
                                </div>
                                <div class="form-group form-group-sm">
                                    <div class="col-sm-12">
                                        <asp:HyperLink ID="hlGoToPosCollegata" CssClass="btn btn-link" runat="server" NavigateUrl='<%#String.Format("~/Pazienti/PazienteDettaglio.aspx?Id={0}", Eval("IdSacPosizioneCollegata")) %>'>Vai a posizione collegata</asp:HyperLink>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:FormView>
                        <div class="form-group form-group-sm">
                            <div class="col-sm-12">
                                <asp:HyperLink ID="hlShowModuleToPrint" CssClass="btn btn-link" runat="server" NavigateUrl="">Stampa documento</asp:HyperLink>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <asp:ObjectDataSource ID="DettaglioPazienteObjectDataSource" runat="server" SelectMethod="GetData"
        TypeName="PazientiPosizioniCollegateDataSetTableAdapters.PazientiPosizioniCollegatePazienteSelectTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter Name="Id" QueryStringField="id" DbType="Guid" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="DettaglioPosizioniCollegateObjectDataSource" runat="server"
        SelectMethod="GetData" TypeName="PazientiPosizioniCollegateDataSetTableAdapters.PazientiPosizioniCollegateSelectByIdSacPosizioneCollegataTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter Name="IdSacPosizioneCollegata" QueryStringField="IdSacPosizioneCollegata" DbType="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>

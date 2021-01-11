<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="EsenzioneDettaglio.aspx.vb" Inherits="DI.Sac.User.EsenzioneDettaglio" %>

<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <div class="row" id="ToolbarRow" runat="server">
        <div class="col-sm-12">
            <div class="well well-sm">
                <asp:HyperLink ID="lnkIndietro" CssClass="btn btn-primary btn-sm" runat="server" NavigateUrl="~/Pazienti/PazienteDettaglio.aspx?id={0}">
                    <span class="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>&nbsp;Indietro</asp:HyperLink>
            </div>
        </div>
    </div>


    <label class="label label-default">Dettaglio Esenzione</label>
    <div class="well well-sm">
        <div class="row">
            <div class="col-sm-12">
                <asp:FormView runat="server" DataSourceID="odsDettaglioEsenzione" ID="fvDettaglioEsenzione" DataKeyNames="Id" RenderOuterTable="false" DefaultMode="ReadOnly">
                    <ItemTemplate>
                        <div class="form-horizontal">
                            <div class="col-sm-6">
                                <div class="form-group form-group-sm">
                                    <label for="lblCodiceEsenzione" class="col-sm-6 control-label">Codice Esenzione</label>
                                    <div class="col-sm-6">
                                        <p class="form-control-static"><%# Eval("CodiceEsenzione") %></p>
                                    </div>
                                </div>
                                <div class="form-group form-group-sm">
                                    <label for="lblCodiceDiagnosi" class="col-sm-6 control-label">Codice Diagnosi</label>
                                    <div class="col-sm-6">
                                        <p class="form-control-static"><%# Eval("CodiceDiagnosi") %></p>
                                    </div>
                                </div>
                                <div class="form-group form-group-sm">
                                    <label for="chkPatologica" class="col-sm-6 control-label">Patologica</label>
                                    <div class="col-sm-6">
                                        <p class="form-control-static"><%# Eval("Patologica") %></p>
                                    </div>
                                </div>
                                <div class="form-group form-group-sm">
                                    <label for="lblDataInizioValidita" class="col-sm-6 control-label">Data Inizio Validità</label>
                                    <div class="col-sm-6">
                                        <p class="form-control-static"><%# Eval("DataInizioValidita", "{0:d}") %></p>
                                    </div>
                                </div>
                                <div class="form-group form-group-sm">
                                    <label for="lblDataFineValidita" class="col-sm-6 control-label">Data Fine Validità</label>
                                    <div class="col-sm-6">
                                        <p class="form-control-static"><%# Eval("DataFineValidita", "{0:d}") %></p>
                                    </div>
                                </div>
                                <div class="form-group form-group-sm">
                                    <label for="lblNumeroAutorizzazioneEsenzione" class="col-sm-6 control-label">Nr Autorizzazione Esenzione</label>
                                    <div class="col-sm-6">
                                        <p class="form-control-static"><%# Eval("NumeroAutorizzazioneEsenzione") %></p>
                                    </div>
                                </div>
                                <div class="form-group form-group-sm">
                                    <label for="lblNoteAggiuntive" class="col-sm-6 control-label">Note Aggiuntive</label>
                                    <div class="col-sm-6">
                                        <p class="form-control-static"><%# Eval("NoteAggiuntive") %></p>
                                    </div>
                                </div>
                                <div class="form-group form-group-sm">
                                    <label for="lblNumeroTestoDescrizioneEsenzione" class="col-sm-6 control-label">Testo Esenzione</label>
                                    <div class="col-sm-6">
                                        <p class="form-control-static"><%# GetEsenzioneTestoDescrizione(Container.DataItem)%></p>
                                    </div>
                                </div>
                                <div class="form-group form-group-sm">
                                    <label for="lblNumeroTestoCodiceEsenzione" class="col-sm-6 control-label">Codice Testo Esenzione</label>
                                    <div class="col-sm-6">
                                        <p class="form-control-static"><%# GetEsenzioneTestoCodice(Container.DataItem)%></p>
                                    </div>
                                </div>
                                <div class="form-group form-group-sm">
                                    <label for="lblDecodificaEsenzioneDiagnosi" class="col-sm-6 control-label">Decodifica Esenzione Diagnosi</label>
                                    <div class="col-sm-6">
                                        <p class="form-control-static"><%# Eval("DecodificaEsenzioneDiagnosi") %></p>
                                    </div>
                                </div>
                                <div class="form-group form-group-sm">
                                    <label for="lblDecodificaEsenzioneDiagnosi" class="col-sm-6 control-label">Attributo Esenzione Diagnosi</label>
                                    <div class="col-sm-6">
                                        <p class="form-control-static"><%# Eval("AttributoEsenzioneDiagnosi") %></p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:FormView>
            </div>
        </div>
    </div>
    <asp:ObjectDataSource ID="odsDettaglioEsenzione" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="CustomDataSource.EsenzionePaziente">
        <SelectParameters>
            <asp:Parameter Name="Token" Type="Object"></asp:Parameter>
            <asp:QueryStringParameter QueryStringField="IdPaziente" DbType="Guid" DefaultValue="" Name="IdPaziente"></asp:QueryStringParameter>
            <asp:QueryStringParameter QueryStringField="IdEsenzione" DbType="Guid" DefaultValue="" Name="IdEsenzione"></asp:QueryStringParameter>
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>

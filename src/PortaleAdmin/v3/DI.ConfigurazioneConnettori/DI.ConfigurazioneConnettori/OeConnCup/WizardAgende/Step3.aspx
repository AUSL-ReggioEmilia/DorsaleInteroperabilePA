<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.master" CodeBehind="Step3.aspx.vb" Inherits=".WizardStep3" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <%--TITOLO PAGINA--%>
    <div class="row">
        <div class="col-sm-12">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h3 class="panel-title">Connettori / OeConnCup / Cofigurazione agende</h3>
                </div>
            </div>
        </div>
    </div>

    <%--WIZARD--%>
    <div class="row form-group">
        <div class="col-xs-10">
            <ul class="nav nav-pills nav-justified thumbnail">
                <li>
                    <a class="list-group-item-success" href="Step1.aspx" onclick="return confirm('Tornare indietro? le modifiche effettuate alle prestazioni verrano annullate!');">
                        <span class="h4">1</span>
                        <span>Dettaglio Agenda</span>
                    </a>
                </li>
                <li>
                    <a class="list-group-item-success" href="Step2.aspx" onclick="return confirm('Tornare indietro? le modifiche effettuate alle prestazioni verrano annullate!');">
                        <span class="h4">2</span>
                        <span>Prestazioni Associate</span>
                    </a>
                </li>
                <li>
                    <a class="list-group-item-warning" href="#">
                        <span class="h4">3</span>
                        <span>Riepilogo Agenda</span>
                    </a>
                </li>
                <li>
                    <a class="disabled" href="#">
                        <span class="h4">4</span>
                        <span>Completato</span>
                    </a>
                </li>
            </ul>
        </div>
    </div>

    <div class="row">
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <div class="col-sm-12 col-md-10">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title">STEP 3: Riepilogo configurazione agenda <%# Agenda.CodiceAgendaCup %></h3>
                        </div>

                        <div class="panel-body">
                            <div class="form-horizontal" role="form">
                                <div class="panel-body">
                                    <div class="form-horizontal" role="form">
                                        <div class="form-group">
                                            <label class="col-sm-4 control-label" for="">Codice Agenda Cup</label>
                                            <div class="col-sm-8">
                                                <p class="form-control-static"><span><%# Agenda.CodiceAgendaCup %></span></p>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-4 control-label" for="">Descrizione Agenda Cup</label>
                                            <div class="col-sm-8">
                                                <p class="form-control-static"><span><%# Agenda.DescrizioneAgendaCup %></span></p>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-4 control-label" for="">Transcodifica Codice Agenda Cup</label>
                                            <div class="col-sm-8">
                                                <p class="form-control-static"><span><%# Agenda.TranscodificaCodiceAgendaCup %></span></p>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-4 control-label" for="">Codice Sistema Erogante</label>
                                            <div class="col-sm-8">
                                                <p class="form-control-static"><span><%# Agenda.CodiceSistemaErogante %></span></p>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-4 control-label" for="">Codice Azienda Erogante</label>
                                            <div class="col-sm-8">
                                                <p class="form-control-static"><span><%# Agenda.CodiceAziendaErogante %></span></p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <%--Preview prestazioni--%>
                        <div class="row">
                            <div class="col-sm-12" style="margin-left: 15px;">
                                <p>L'agenda <%# Agenda.CodiceAgendaCup %> è impostata correttamente.</p>
                                <p>Numero di prestazioni associate da inserire: <%# Agenda.Prestazioni.Count %></p>
                                <p>Premere "Salva" per concludere la configurazione</p>
                            </div>
                        </div>

                        <div class="panel-footer">
                            <div class="text-center">
                                <asp:Button runat="server" ID="BtnConferma" Text="Salva" CssClass="btn btn-primary" OnClientClick="this.disabled='true';" UseSubmitBehavior="false" CausesValidation="false" />
                            </div>
                            <div class="clearfix"></div>
                        </div>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>

</asp:Content>

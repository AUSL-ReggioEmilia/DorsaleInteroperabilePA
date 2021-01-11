<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.master" CodeBehind="Step1.aspx.vb" Inherits=".WizardStep1" %>

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
                    <a class="list-group-item-warning" href="#">
                        <span class="h4">1</span>
                        <span>Dettaglio Agenda</span>
                    </a>
                </li>
                <li>
                    <a class="disabled" href="#">
                        <span class="h4">2</span>
                        <span>Prestazioni Associate</span>
                    </a>
                </li>
                <li>
                    <a class="disabled" href="#">
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

                <div class="col-sm-12">
                    <asp:ValidationSummary ID="ValidationSummaryStep1" runat="server" EnableClientScript="true"
                        HeaderText="<strong>Non è possibile continuare, sono presenti i seguenti errori:</strong>"
                        CssClass="alert alert-danger text-danger" />
                </div>

                <div class="col-sm-12 col-md-10">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title">STEP 1: Dettaglio dell'agenda</h3>
                        </div>

                        <div class="panel-body">
                            <div class="form-horizontal" role="form">
                                <div class="form-group">
                                    <label class="col-sm-4 control-label" for="">Codice Agenda Cup</label>
                                    <div class="col-sm-8">
                                        <p class="form-control-static">
                                            <asp:Label runat="server" Text="<%# Agenda.CodiceAgendaCup %>" />
                                        </p>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-sm-4 control-label" for="">Descrizione Agenda Cup</label>
                                    <div class="col-sm-8">
                                        <p class="form-control-static">
                                            <asp:Label runat="server" Text="<%# Agenda.DescrizioneAgendaCup %>" />
                                        </p>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-sm-4 control-label" for="">Transcodifica Codice Agenda Cup</label>
                                    <div class="col-sm-8">
                                        <p class="form-control-static">

                                            <asp:TextBox runat="server"
                                                ID="TxtTranscodificaCodiceAgendaCup" Text="<%# Agenda.TranscodificaCodiceAgendaCup %>"
                                                CssClass="form-control"></asp:TextBox>

                                            <asp:RequiredFieldValidator
                                                ID="ReqTranscodificaCodiceAgendaCup"
                                                Text="*"
                                                ErrorMessage="Transcodifica Codice Agenda Cup è obbligatorio"
                                                ControlToValidate="TxtTranscodificaCodiceAgendaCup"
                                                CssClass="text-danger"
                                                Display="Dynamic"
                                                runat="server" />
                                        </p>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-4 control-label" for="">Sistema Erogante</label>
                                    <div class="col-sm-8">
                                        <p class="form-control-static">

                                            <asp:DropDownList ID="DdlSistemaErogante" CssClass="form-control" AutoPostBack="True" runat="server">
                                            </asp:DropDownList>                                           
                                         
                                            <asp:RequiredFieldValidator
                                                ID="ReqDdlSistemaErogante"
                                                Text="*"
                                                ErrorMessage="Il Sistema Erogante è obbligatorio"
                                                ControlToValidate="DdlSistemaErogante"
                                                CssClass="text-danger"
                                                Display="Dynamic"
                                                runat="server" />
                                        </p>
                                    </div>
                                </div>                   
                            </div>
                        </div>
                        <div class="panel-footer">
                            <div class="text-center">
                                <asp:LinkButton runat="server" ID="BtnAvanti" CssClass="btn btn-primary"> Avanti <span class="glyphicon glyphicon-menu-right"></span> </asp:LinkButton>
                            </div>
                            <div class="clearfix"></div>
                        </div>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>

</asp:Content>

<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.master" CodeBehind="Step2.aspx.vb" Inherits=".WizardStep2" %>

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
                    <a class="list-group-item-success" href="Step1.aspx">
                        <span class="h4">1</span>
                        <span>Dettaglio Agenda</span>
                    </a>
                </li>
                <li>
                    <a class="list-group-item-warning" href="#">
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

    <%--FILTRI--%>
    <div class="row">
        <div class="col-sm-12 col-md-10">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h3 class="panel-title">STEP 2: Lista prestazioni dell'agenda <%# Agenda.CodiceAziendaErogante %></h3>
                </div>

                <div class="panel-body">
                    <asp:UpdatePanel ID="UpdatePanelFiltri" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <div class="form-horizontal">

                                <%-- Id Prestazione Cup --%>
                                <div class="col-md-4 col-sm-6">
                                    <div class="form-group form-group-sm">
                                        <div class="col-md-5">
                                            <label class="control-label" for="">Id Prestazione Cup</label>
                                        </div>
                                        <div class="col-md-7">

                                            <div class="input-group input-group-sm ">
                                                <!-- le funzioni collegate agli eventi onblur e onfocus sono definiti dentro il file main.js -->
                                                <asp:TextBox ID="TxtFiltroIdPrestazioneCup" runat="server" CssClass="form-control" onblur="TextBox_onBlur(this,event);" onfocus="TextBox_onFocus(this,event);"></asp:TextBox>
                                                <span class="input-group-btn">
                                                    <asp:LinkButton ID="FiltriCercaIdPrestazioneCup" ClientIDMode="Static" runat="server" CssClass="btn btn-default disabled" ToolTip="Applica Filtro [invio]">
			                                       <span class="glyphicon glyphicon-filter"></span>
                                                    </asp:LinkButton>
                                                </span>
                                            </div>
                                        </div>

                                    </div>
                                </div>
                            </div>

                            <%-- Id Prestazione Erogante --%>
                            <div class="col-md-4 col-sm-6">
                                <div class="form-group form-group-sm">
                                    <div class="col-md-5">
                                        <label class="control-label">Id Prestazione Erogante</label>
                                    </div>
                                    <div class="col-md-7">

                                        <div class="input-group input-group-sm ">
                                            <!-- le funzioni collegate agli eventi onblur e onfocus sono definiti dentro il file main.js -->
                                            <asp:TextBox ID="TxtFiltroIdPrestazioneErogante" runat="server" CssClass="form-control" onblur="TextBox_onBlur(this,event);" onfocus="TextBox_onFocus(this,event);"></asp:TextBox>
                                            <span class="input-group-btn">
                                                <asp:LinkButton ID="FiltriCercaIdPrestazioneErogante" ClientIDMode="Static" runat="server" CssClass="btn btn-default disabled" ToolTip="Applica Filtro [invio]" UseSubmitBehavior="true">
			                                       <span class="glyphicon glyphicon-filter"></span>
                                                </asp:LinkButton>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>

                <%--TABELLA PRESTAZIONI--%>
                <asp:UpdatePanel ID="UpdatePanelPrestazioni" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>

                        <div class="table-responsive" style="margin: 10px">
                            <asp:GridView ID="GridViewPrestazioni" runat="server" AllowPaging="True"
                                PageSize="10" AutoGenerateColumns="false" DataKeyNames="IdPrestazioneErogante" GridLines="None"
                                CssClass="table table-striped table-bordered table-condensed table-custom-padding" EmptyDataText="Non ci sono Prestazioni">

                                <Columns>

                                    <asp:TemplateField HeaderStyle-Width="30px">
                                        <ItemTemplate>
                                            <asp:LinkButton runat="server" CommandName="Modifica" CommandArgument='<%# Eval("IdPrestazioneErogante") %>' ToolTip="Modifica" CssClass="btn btn-default btn-sm"><i class="glyphicon glyphicon-pencil"></i></asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:BoundField HeaderText="Id Prestazione Cup" DataField="IdPrestazioneCup" />
                                    <asp:BoundField HeaderText="Specialità Esame Cup" DataField="SpecialitaEsameCup" />
                                    <asp:BoundField HeaderText="Id Prestazione Erogante" DataField="IdPrestazioneErogante" />
                                    <asp:BoundField HeaderText="Descrizione" DataField="Descrizione" />


                                </Columns>

                                <PagerStyle CssClass="pagination-gridview" />
                                <EmptyDataTemplate>
                                    Nessun elemento da visualizzare.
                                </EmptyDataTemplate>

                            </asp:GridView>
                        </div>

                    </ContentTemplate>
                </asp:UpdatePanel>

                <div class="panel-footer">
                    <div class="text-center">
                        <asp:LinkButton runat="server" ID="BtnIndietro" CssClass="btn btn-default"><span class="glyphicon glyphicon-menu-left"></span> Indietro </asp:LinkButton>
                        <asp:LinkButton runat="server" ID="BtnAvanti" CssClass="btn btn-primary"> Avanti <span class="glyphicon glyphicon-menu-right"></span> </asp:LinkButton>
                    </div>
                    <div class="clearfix"></div>
                </div>

            </div>
        </div>
    </div>

    <!-- Modal Di Modifica  -->
    <div class="modal fade" id="myModal" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog">

            <!-- UpdatePanel per gestire i Postback solo sulla Modal Dialog
                 Consente anche di modifiare i controllo lato server -->
            <asp:UpdatePanel ID="UpdatePanelModalForm" runat="server" ChildrenAsTriggers="true" UpdateMode="Conditional">
                <ContentTemplate>

                    <div class="modal-content">
                        <div class="modal-header">
                            <!-- Chiude la dialog, non serve un aspnet:button -->
                            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                            <h4 class="modal-title">
                                <asp:Label ID="LabelModalTitle" runat="server" Text="Modifica elemento"></asp:Label></h4>
                        </div>

                        <div class="modal-body">
                            <!-- Campi in BIND -->
                            <div id="ModalBody" runat="server" role="form">
                                
                                        <div class="form-group">
                                            <label class="col-sm-6 control-label">Codice Agenda Cup</label>
                                            <div class="col-sm-6" style="padding-top: 7px;">
                                                <asp:Label runat="server" Text="<%# Agenda.CodiceAgendaCup %>" /></p>
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label class="col-sm-6 control-label">Id Prestazione Erogante</label>
                                            <div class="col-sm-6">
                                                <asp:TextBox
                                                    runat="server"
                                                    ID="TxtIdPrestazioneErogante"
                                                    Text="<%# PrestazioneSelected.IdPrestazioneErogante %>"
                                                    MaxLength="16" placeholder="Id Prestazione Erogante"
                                                    CssClass="form-control">
                                                </asp:TextBox>
                                            </div>
                                        </div>
                            </div>
                        </div>

                        <div class="modal-footer">

                            <div class="btn-group">
                                <div class="pull-right text-right">
                                    <asp:Button ID="ButtonUpdate" CssClass="btn btn-primary" runat="server" Text="OK" />
                                    <asp:Button ID="ButtonCancel" CssClass="btn btn-default" runat="server" Text="Annulla" />
                                </div>
                                <div class="clearfix"></div>
                            </div>
                        </div>

                    </div>

                </ContentTemplate>
            </asp:UpdatePanel>

        </div>
    </div>


    <%--DETTAGLIO PRESTAZIONE--%>
    <%--<div class="panel panel-default">
        <div class="panel-heading">
            <h3 class="panel-title">Modifica elemento</h3>
        </div>

        <div class="panel-body">
            <div class="form-horizontal" role="form">

                <div class="form-group">
                    <label class="col-sm-4 control-label" for="ContentPlaceHolder1_FormView1_ctl05_ctl00___CodiceAgendaCup_Literal1">Codice Agenda Cup</label>
                    <div class="col-sm-8">
                        <p class="form-control-static"><span id="ContentPlaceHolder1_FormView1_ctl05_ctl00___CodiceAgendaCup_Literal1">AL032</span></p>
                    </div>
                </div>

                <div class="form-group">
                    <label class="col-sm-4 control-label">Id Prestazione Cup</label>
                    <div class="col-sm-8">
                        <input class="form-control" type="text" size="16" maxlength="16" placeholder="Id Prestazione Cup" value="AL1">
                    </div>
                </div>

            </div>
        </div>
        <div class="panel-footer">
        <div class="pull-right text-right">
                <a class="btn btn-primary" href='javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions("ctl00$ContentPlaceHolder1$FormView1$ctl03", "", true, "", "", false, true))'>Ok</a>
                <a class="btn btn-default" href="javascript:__doPostBack('ctl00$ContentPlaceHolder1$FormView1$ctl04','')">Annulla</a>
            </div>
            <div class="clearfix"></div>
        </div>
        </div>
    --%>
</asp:Content>

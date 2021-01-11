<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.master" CodeBehind="Step4.aspx.vb" Inherits=".Step4" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">


    <%--TITOLO PAGINA--%>
    <div class="row">
        <div class="col-sm-12">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h3 class="panel-title">Connettori / OeConnCup / Completato</h3>
                </div>
            </div>
        </div>
    </div>

    <%--WIZARD--%>
    <div class="row form-group">
        <div class="col-xs-10">
            <ul class="nav nav-pills nav-justified thumbnail">
                <li>
                    <a class="list-group-item-success">
                        <span class="h4">1</span>
                        <span>Dettaglio Agenda</span>
                    </a>
                </li>
                <li>
                    <a class="list-group-item-success">
                        <span class="h4">2</span>
                        <span>Prestazioni Associate</span>
                    </a>
                </li>
                <li>
                    <a class="list-group-item-success">
                        <span class="h4">3</span>
                        <span>Riepilogo Agenda</span>
                    </a>
                </li>
                <li>
                    <a class="list-group-item-warning">
                        <span class="h4">4</span>
                        <span>Completato</span>
                    </a>
                </li>
            </ul>
        </div>
    </div>

    <%--Esito inserimento--%>
    <div class="row">
        <div class="col-sm-12 col-md-10">
            <asp:UpdatePanel ID="UpdatePanelEsito" runat="server">
                <ContentTemplate>
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">Esito operazione</h4>
                        </div>

                        <div class="panel-body">

                            <% If Agenda.IsAlreadyExisting Then %>
                                <p>L'agenda <%# Agenda.CodiceAgendaCup %> è stata configurata correttamente.</p>
                            <% Else %>
                               <p>L'agenda <%# Agenda.CodiceAgendaCup %> è stata inserita correttamente.</p>
                            <% End If %>


                            <div runat="server" id="DivSuccessi" class="alert alert-success" visible="false">
                                <asp:Label runat="server" ID="LblPrestazioniCompletate"></asp:Label>
                            </div>

                            <div class="alert alert-danger" runat="server" id="DivFallite" visible="false">
                                <asp:Label runat="server" ID="LblPrestazioniFallite"></asp:Label>

                                <%-- Griglia lista prestazioni fallite --%>
                                <asp:UpdatePanel ID="UpdatePanelPrestazioniFallite" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>

                                        <div class="table-responsive" style="margin: 10px">
                                            <asp:GridView ID="GridViewPrestazioniFallite" runat="server" AllowPaging="True"
                                                PageSize="10" AutoGenerateColumns="false" DataKeyNames="IdPrestazioneErogante" GridLines="None"
                                                CssClass="table table-striped table-bordered table-condensed table-custom-padding" EmptyDataText="Non ci sono Prestazioni">

                                                <Columns>

                                                    <asp:BoundField HeaderText="Id Prestazione Cup" DataField="IdPrestazioneCup" />
                                                    <asp:BoundField HeaderText="Specialità Esame Cup" DataField="SpecialitaEsameCup" />
                                                    <asp:BoundField HeaderText="Id Prestazione Erogante" DataField="IdPrestazioneErogante" />
                                                    <asp:BoundField HeaderText="Descrizione" DataField="Descrizione" />

                                                </Columns>

                                                <PagerStyle CssClass="pagination-gridview" />

                                            </asp:GridView>
                                        </div>

                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>

                            <p>Premere "OK" per tornare alla lista</p>

                        </div>

                        <div class="panel-footer text-center">
                            <asp:Button runat="server" ID="BtnOk" Text="OK" CssClass="btn btn-primary" CausesValidation="false" />
                        </div>
                    </div>

                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>

</asp:Content>

<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RicercaOrdini.aspx.cs" Inherits="OrderEntryPlanner.Pages.RicercaOrdini" %>

<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server" EnableViewState="false">

    <style>
        #lblDataNascita {
            padding-left: 0px !important;
            padding-right: 0px !important;
        }
    </style>
    
    <%-- UPDATE PROGRESS per l'aggiornamento della pagina --%>
    <asp:UpdateProgress ID="UpdateProgress1" AssociatedUpdatePanelID="UpdPanelFiltri" runat="server" DisplayAfter="25">
        <ProgressTemplate>
            <div class="alert alert-success" style="position: absolute; z-index: 1200; right: 10px">
                <h5><strong>Caricamento in corso...</strong></h5>
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <div class="row">
        <div class="col-sm-12">
            <div class="alert alert-danger" id="divError" visible="false" runat="server" enableviewstate="false">
                <asp:Label ID="lblError" EnableViewState="false" runat="server" />
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">

            <asp:UpdatePanel runat="server" ID="UpdPanelFiltri" UpdateMode="Conditional">
                <ContentTemplate>
                    <div class="panel panel-default">

                        <div class="panel-heading">
                            Ricerca Ordine&nbsp;&nbsp;
                            <small>
                                <asp:LinkButton runat="server" ID="BtnRicercaAvanzata" OnClick="BtnRicercaAvanzata_Click" Text="(Ricerca avanzata)">                            
                                </asp:LinkButton>
                            </small>
                        </div>

                        <div class="panel-body" id="divFiltri" runat="server">
                            <div class="form-horizontal">
                                <div class="row">

                                    <%-- Colonna Periodo-Cognome-Nome --%>
                                    <div class="col-sm-5">

                                        <%-- DropDownList Periodo e Non prenotati--%>
                                        <div class="form-group form-group-sm">
                                            <label for="txtPeriodo" class="col-sm-4 control-label">Periodo</label>
                                            <div class="col-sm-8">
                                                <asp:DropDownList ID="ddlPeriodo" CssClass="form-control" ClientIDMode="Static" runat="server">
                                                    <asp:ListItem Text="Non prenotati" Value="-1" />
                                                    <asp:ListItem Text="Tutti" Value="0" />
                                                    <asp:ListItem Text="Oggi" Value="1" Selected="True"/>
                                                    <asp:ListItem Text="Domani" Value="2" />
                                                    <asp:ListItem Text="Prossimi 3 giorni" Value="3" />
                                                    <asp:ListItem Text="Prossimi 7 giorni" Value="7" />
                                                    <asp:ListItem Text="Prossimi 30 giorni" Value="30" />
                                                </asp:DropDownList>
                                            </div>
                                        </div>

                                        <%-- Cognome --%>
                                        <div class="form-group form-group-sm">
                                            <label for="txtCognome" class="col-sm-4 control-label">Cognome</label>
                                            <div class="col-sm-8">
                                                <asp:TextBox ID="txtCognome" CssClass="form-control" ClientIDMode="Static" runat="server" placeholder="Cognome" />
                                            </div>
                                        </div>

                                        <%-- Nome --%>
                                        <div class="form-group form-group-sm">
                                            <label for="txtNome" class="col-sm-4 control-label">Nome</label>
                                            <div class="col-sm-8">
                                                <asp:TextBox ID="txtNome" CssClass="form-control" ClientIDMode="Static" runat="server" placeholder="Nome" />
                                            </div>
                                        </div>
                                    </div>

                                    <%-- Colonna Sistema erogante-Prenotato-Prenotazione Variata --%>
                                    <div class="col-sm-5">

                                        <%-- Sistema erogante --%>
                                        <div class="form-group form-group-sm">
                                            <label for="ddlErogante" class="col-sm-4 control-label">Sistema erogante</label>
                                            <div class="col-sm-8">
                                                <asp:DropDownList ID="ddlErogante" runat="server" CssClass="form-control" DataSourceID="odsErogante"
                                                    DataTextField="Value" DataValueField="Key" AppendDataBoundItems="true" ClientIDMode="Static">
                                                </asp:DropDownList>
                                            </div>
                                        </div>

                                        <%-- Anno di nascita --%>
                                        <div class="form-group form-group-sm">
                                            <label for="txtAnnoNascita" class="col-sm-4 control-label">Anno di nascita</label>
                                            <div class="col-sm-8">
                                                <asp:TextBox ID="txtAnnoNascita" CssClass="form-control form-control-datatimepicker" ClientIDMode="Static" runat="server" placeholder="aaaa" />
                                                <asp:RangeValidator ID="RangeValidator1" Type="Integer" MinimumValue="1900"
                                                    MaximumValue="2099" EnableClientScript="true" SetFocusOnError="true" ControlToValidate="txtAnnoNascita" CssClass="label label-danger"
                                                    runat="server" ErrorMessage="Inserire un'anno tra il 1900 e 2099" Display="Dynamic"></asp:RangeValidator>
                                            </div>
                                        </div>

                                        <%-- Data di nascita --%>
                                        <div class="form-group form-group-sm">
                                            <label for="txtDataNascita" class="col-sm-4 control-label">Data di nascita</label>
                                            <div class="col-sm-8">
                                                <asp:TextBox ID="txtDataNascita" CssClass="form-control form-control-datatimepicker" ClientIDMode="Static" runat="server" placeholder="dd/mm/aaaa" />
                                                <asp:RangeValidator ID="rv1" Type="Date" MinimumValue="1900-01-01"
                                                    MaximumValue="2099-01-01" EnableClientScript="true" SetFocusOnError="true" ControlToValidate="txtDataNascita" CssClass="label label-danger"
                                                    runat="server" ErrorMessage="Inserire una data nell'intervallo 01/01/1900 e 01/01/2099" Display="Dynamic"></asp:RangeValidator>
                                            </div>
                                        </div>
                                    </div>

                                    <%-- Bottoni --%>
                                    <div class="col-sm-2">
                                        <div class="btn-group button-custom-align">
                                            <asp:Button ID="btnCerca" OnClick="btnCerca_Click" Text="Cerca" CssClass="btn btn-sm btn-primary" runat="server" />
                                            <asp:Button ID="btnAnnulla" OnClick="btnAnnulla_Click" Text="Annulla" CssClass="btn btn-sm btn-default" runat="server" />
                                        </div>
                                    </div>

                                    <%-- Ricerca avanzata --%>
                                    <div class='<%= FiltriAdvancedCss %>'>
                                        <div class="col-sm-12">
                                            <hr />
                                        </div>

                                        <%-- Colonna Numero nosologico-Data Prenotazione / Richiesta --%>
                                        <div class="col-sm-5">

                                            <%-- Numero nosologico --%>
                                            <div class="form-group form-group-sm">
                                                <label for="txtNumeroNosologico" class="col-sm-4 control-label">Numero nosologico</label>
                                                <div class="col-sm-8">
                                                    <asp:TextBox ID="txtNumeroNosologico" CssClass="form-control" ClientIDMode="Static" runat="server" placeholder="Numero nosologico" />
                                                </div>
                                            </div>

                                            <%-- Data Prenotazione / Richiesta --%>
                                            <div class="form-group form-group-sm">
                                                <label class="col-sm-4 control-label small" for="txtUnitaOperativa">Data Prenotazione / Richiesta</label>
                                                <div class="col-sm-8">
                                                    <div class="input-group input-group-sm">
                                                        <span class="input-group-addon">Dal</span>
                                                        <asp:TextBox ID="txtDataDal" runat="server" CssClass="form-control form-control-datatimepicker" ClientIDMode="Static" MaxLength="10" placeholder="Es: 22/11/1996" />
                                                        <span class="input-group-addon">Al</span>
                                                        <asp:TextBox ID="txtDataAl" runat="server" CssClass="form-control form-control-datatimepicker" ClientIDMode="Static" MaxLength="10" placeholder="Es: 22/11/1996" />
                                                    </div>
                                                    <asp:RangeValidator ID="rv2" Type="Date" MinimumValue="1900-01-01"
                                                        MaximumValue="3000-01-01" EnableClientScript="true" SetFocusOnError="true" ControlToValidate="txtDataDal" CssClass="label label-danger"
                                                        runat="server" ErrorMessage="Inserire una data nell'intervallo 01/01/1900 e 01/01/3000" Display="Dynamic"></asp:RangeValidator>
                                                    <asp:RangeValidator ID="rv3" Type="Date" MinimumValue="1900-01-01"
                                                        MaximumValue="3000-01-01" EnableClientScript="true" SetFocusOnError="true" ControlToValidate="txtDataAl" CssClass="label label-danger"
                                                        runat="server" ErrorMessage="Inserire una data nell'intervallo 01/01/1900 e 01/01/3000" Display="Dynamic"></asp:RangeValidator>
                                                </div>
                                            </div>
                                        </div>

                                        <%-- Colonna Priorità-Regime --%>
                                        <div class="col-sm-5">

                                            <%-- Priorità --%>
                                            <div class="form-group form-group-sm">
                                                <label for="ddlPriorita" class="col-sm-4 control-label">Priorità</label>
                                                <div class="col-sm-8">
                                                    <asp:DropDownList ID="ddlPriorita" runat="server" ClientIDMode="static" CssClass="form-control" DataSourceID="odsPriorita"
                                                        DataTextField="Descrizione" DataValueField="Codice" AppendDataBoundItems="true">
                                                        <asp:ListItem Text="Tutti" Value="" Selected="True"></asp:ListItem>
                                                    </asp:DropDownList>
                                                </div>
                                            </div>

                                            <%-- Regime --%>
                                            <div class="form-group form-group-sm">
                                                <label for="ddlRegime" class="col-sm-4 control-label">Regime</label>
                                                <div class="col-sm-8">
                                                    <asp:DropDownList ID="ddlRegime" runat="server" CssClass="form-control" DataSourceID="odsRegimi"
                                                        DataTextField="Descrizione" DataValueField="Codice" AppendDataBoundItems="true" ClientIDMode="Static">
                                                        <asp:ListItem Text="Tutti" Value="" Selected="True"></asp:ListItem>
                                                    </asp:DropDownList>
                                                </div>
                                            </div>

                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>

        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <asp:UpdatePanel runat="server" ID="UpdPanelGriglia" UpdateMode="Conditional">
                <ContentTemplate>

                    <asp:GridView ID="gvRicerche" runat="server" DataKeyNames="Id" DataSourceID="odsRicerche"
                        OnRowDataBound="gvRicerche_RowDataBound" OnPreRender="gvRicerche_PreRender" OnRowCommand="gvRicerche_RowCommand"
                        CssClass="table small table-bordered table-condensed" AllowSorting="true" AllowPaging="true" PageSize="100"
                        AutoGenerateColumns="False" ViewStateMode="Disabled" EmptyDataText="Nessun risultato.">
                        <Columns>
                            <asp:TemplateField HeaderText="Data Prenotazione" SortExpression="DataPrenotazione">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server" CssClass="btn btn-xs btn-default" CommandName="Pianifica" ToolTip="Prenota Ordine...">
                                    <span class="glyphicon glyphicon-calendar"></span>
                                    </asp:LinkButton>
                                    <%# Eval("DataPrenotazione", "{0:g}")  %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Paziente" SortExpression="PazienteCognome">
                                <ItemTemplate>
                                    <%# Eval("PazienteCognome").ToString() + " " + Eval("PazienteNome").ToString()%>
                                    <br />
                                    (<%# Eval("PazienteDataNascita", "{0:d}") %>)
                            <%--<%# GetColumnPaziente(Eval("IdSac").ToString()) %>--%>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Ordine" ItemStyle-Width="120px" SortExpression="IdOrderEntry">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server" ID="btnDettaglioOrdineLink" CssClass="btn btn-xs btn-default" CommandName="Apri" ToolTip="Dettaglio Ordine...">
                                <span class="glyphicon glyphicon-folder-open"></span>
                                    </asp:LinkButton>
                                    <%# Eval("IdOrderEntry")  %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="AnteprimaPrestazioni" HeaderText="Prestazioni" SortExpression="AnteprimaPrestazioni"></asp:BoundField>
                            <asp:BoundField DataField="RegimeDescrizione" HeaderText="Regime" SortExpression="RegimeDescrizione"></asp:BoundField>
                            <asp:BoundField DataField="PrioritaDescrizione" HeaderText="Priorità" SortExpression="PrioritaDescrizione"></asp:BoundField>

                            <asp:TemplateField HeaderText="Richiedente">
                                <ItemTemplate>
                                    <%# Eval("SistemaRichiedenteAziendaCodice")  %>
                                    <br />
                                    <%# Eval("UnitaOperativaDescrizione")  %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- <asp:TemplateField HeaderText="Episodio">
                        <ItemTemplate>
                            <%# GetColumnEpisodio(Container.DataItem) %>
                        </ItemTemplate>
                    </asp:TemplateField>--%>
                        </Columns>
                    </asp:GridView>

                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>

    <asp:ObjectDataSource ID="odsPriorita" runat="server" SelectMethod="GetData"
        TypeName="DI.OrderEntryPlanner.Data.Ordini.OrdiniPrioritaListaTableAdapter" OldValuesParameterFormatString="{0}" />

    <asp:ObjectDataSource ID="odsRegimi" runat="server" SelectMethod="GetData"
        TypeName="DI.OrderEntryPlanner.Data.Ordini.OrdiniRegimiListaTableAdapter" OldValuesParameterFormatString="{0}" />

    <asp:ObjectDataSource ID="odsStati" runat="server" SelectMethod="GetData"
        TypeName="DI.OrderEntryPlanner.Data.Ordini.OrdiniErogatiStatiListaTableAdapter" OldValuesParameterFormatString="original_{0}">
        <SelectParameters>
            <asp:Parameter Name="EscludiCodice" Type="String"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="odsErogante" runat="server" SelectMethod="getData"
        TypeName="OrderEntryPlanner.Components.CustomDataSource+SistemiErogantiTableAdapter" />

    <asp:ObjectDataSource ID="odsRicerche" runat="server" SelectMethod="GetData" OnSelecting="odsRicerche_Selecting"
        TypeName="DI.OrderEntryPlanner.Data.Ordini.OrdiniTestateCercaTableAdapter" OldValuesParameterFormatString="original_{0}">
        <SelectParameters>
            <asp:Parameter Name="Top" Type="Int32" DefaultValue="1000"></asp:Parameter>
            <asp:Parameter Name="DataDal" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="DataAl" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="SistemiEroganti" Type="Object"></asp:Parameter>
            <asp:Parameter Name="Prenotato" Type="Boolean" DefaultValue="true"></asp:Parameter>
            <asp:Parameter Name="PrenotazioneModificabile" Type="Boolean" DefaultValue="true"></asp:Parameter>
            <asp:Parameter Name="PrenotazioneVariata" Type="Boolean" DefaultValue="" ConvertEmptyStringToNull="true"></asp:Parameter>
            <asp:ControlParameter ControlID="txtCognome" PropertyName="Text" DefaultValue="" Name="PazienteCognome" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtNome" PropertyName="Text" Name="PazienteNome" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtDataNascita" PropertyName="Text" Name="PazienteDataNascita" Type="DateTime"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtAnnoNascita" PropertyName="Text" Name="PazienteAnnoNascita" Type="Int32"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtNumeroNosologico" PropertyName="Text" DefaultValue="" Name="NumeroNosologico" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="ddlPriorita" PropertyName="SelectedValue" Name="PrioritaCodice" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="ddlRegime" PropertyName="SelectedValue" Name="RegimeCodice" Type="String"></asp:ControlParameter>
        </SelectParameters>
    </asp:ObjectDataSource>

</asp:Content>

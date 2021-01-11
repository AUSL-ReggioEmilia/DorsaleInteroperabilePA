<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PazienteCercaPosCollegata.aspx.vb" Inherits=".PazienteCercaPosCollegata" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <div class="row" id="divErrorMessage" runat="server" visible="false" enableviewstate="false">
        <div class="col-sm-12">
            <div class="alert alert-danger">
                <asp:Label ID="LabelError" runat="server" CssClass="text-danger" EnableViewState="False"></asp:Label>
            </div>
        </div>
    </div>

    <div id="MainTable" runat="server" class="row">
        <div class="col-sm-12">
            <div id="pannelloFiltri" runat="server" class="panel panel-default">
                <div class="panel-body">
                    <div class="form-horizontal">
                        <div class="col-sm-5">
                            <div class="form-group form-group-sm">
                                <asp:Label ID="lblFiltroCodicePosCollegata" CssClass="col-sm-5 control-label" AssociatedControlID="txtFiltroCodicePosCollegata" runat="server" Text="Codice posizione collegata:"></asp:Label>
                                <div class="col-sm-7">
                                    <asp:TextBox placeholder="Inserire codice posizione collegata" ID="txtFiltroCodicePosCollegata" CssClass="form-control" runat="server"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-2">
                            <div class="form-group form-group-sm">
                                <asp:Button ID="btnRicercaButton" runat="server" CssClass="btn btn-sm btn-primary" Text="Cerca" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-12">
            <asp:FormView ID="MainFormView" runat="server" RenderOuterTable="false" DataKeyNames="IdPosizioneCollegata" DataSourceID="MainObjectDataSource" EmptyDataText="Dati non disponibili!"
                EnableModelValidation="True">
                <ItemTemplate>

                    <div class="well well-sm">
                        <asp:HyperLink ID="hlGoToPosOriginale" CssClass="btn btn-default" runat="server" NavigateUrl='<%#String.Format("~/Pazienti/PazienteDettaglio.aspx?Id={0}", Eval("IdSacOriginale")) %>'>
                            <span class="glyphicon glyphicon-link" aria-hidden="true"></span>&nbsp;Vai a posizione originale</asp:HyperLink>
                        <asp:HyperLink ID="hlGoToPosCollegata" CssClass="btn btn-default" runat="server" NavigateUrl='<%#String.Format("~/Pazienti/PazienteDettaglio.aspx?Id={0}", Eval("IdSacPosizioneCollegata")) %>'>
                            <span class="glyphicon glyphicon-link" aria-hidden="true"></span>&nbsp;Vai a posizione collegata</asp:HyperLink>
                    </div>
                    <div class="panel panel-default">
                        <div class="panel-body">
                            <div class="form-horizontal">
                                <div class="form-group form-group-sm">
                                     <label class="col-sm-2 control-label">Utente</label>
                                    <div class="col-sm-10">
                                        <p id="lblUtente" class="form-control-static"> <%# Eval("Utente") %></p>
                                    </div>
                                </div>

                                <div class="form-group form-group-sm">
                                    <label class="col-sm-2 control-label">Data creazione</label>
                                    <div class="col-sm-9">
                                        <p class="form-control-static"> <%# Eval("DataInserimento", "{0:g}") %></p>
                                    </div>
                                </div>
                                <div class="form-group form-group-sm">
                                     <label class="col-sm-2 control-label">Motivo posizione collegata</label>
                                    <div class="col-sm-9">
                                        <p class="form-control-static"> <%# Eval("Note") %></p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
                <EmptyDataRowStyle CssClass="empty-row-style" />
                <EmptyDataTemplate>
                    <div class="well well-sm">
                       Nessun risultato! Modificare i valori di filtro. 
                    </div>
                </EmptyDataTemplate>
            </asp:FormView>
        </div>
    </div>

    <asp:ObjectDataSource ID="MainObjectDataSource" runat="server" SelectMethod="GetData" TypeName="PazientiPosizioniCollegateDataSetTableAdapters.PazientiPosizioniCollegateSelectTableAdapter"
        CacheKeyDependency="CKD_PosizioniCollegate_DataSourceMain">
        <SelectParameters>
            <asp:QueryStringParameter Name="IdPosizioneCollegata" QueryStringField="IdPosizioneCollegata" DbType="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>


<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="ucModaleInvioLinkPerAccessoDiretto.ascx.vb" Inherits="DwhClinico.Web.ucModaleInvioLinkPerAccessoDiretto" %>
<style>
    /*
    STILI PER CUSTOM INPUT E CUSTOM TEXT-AREA
    Stili usati per affiancare verticalmente una textbox e una text-area eliminado i bordi arrotondati
    ----------------------------------------------------------------------------------
    */
    .mail-input-custom-control {
        border-bottom: none;
        border-bottom-right-radius: 0px;
        border-bottom-left-radius: 0px;
    }

    .mail-text-area-custom-control {
        border-top-right-radius: 0px;
        border-top-left-radius: 0px;
    }

    /*
        Classe css che imposta una line-height diversa per i bottoni del token field.
      
        Motivo:
        Con i Bootstrap-css compattati per il dwh è stata modificata la line-height di tutti i Bootstrap-btn. 
        In questo modo reimposto la line-height dei bottoni come da css originale in modo da essere "compatibili" con il token field.
        Doc Ufficiale TokenFields: http://sliptree.github.io/bootstrap-tokenfield/
    */
    .tokenfield-btn {
        line-height: 1.4285 !important;
    }
</style>

<asp:UpdatePanel ID="updatePanelAlertSuccess" runat="server" ChildrenAsTriggers="false" UpdateMode="Conditional">
    <ContentTemplate>
        <%-- ALERT DI INVIO AVVENUTO CON SUCCESSO --%>
        <div id="customAlert" clientidmode="Static" class="alert alert-success" runat="server" visible="False" enableviewstate="false">
            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                <span aria-hidden="true">&times;</span>
            </button>
            <strong>
                <span class="glyphicon glyphicon-ok"></span>&nbsp;&nbsp;<asp:Label Text="Email inviata." ID="lblMessage" runat="server" />
            </strong>
        </div>
    </ContentTemplate>
</asp:UpdatePanel>

<!-- Split button -->
<asp:UpdatePanel ID="updPreferiti" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <div class="btn-group" style="width: 100%; margin-bottom: 5px">
            <button id="btnApriInvioMail" class="btn btn-sm btn-default" style="width: 70%; height: 30px" type="button" onclick="window.scrollTo(0, 0);">
                Invia Link Accesso Diretto
            </button>
            <button runat="server" id="btnPreferiti" type="button" class="btn btn-default btn-sm" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" title="Preferiti" style="width: 15%; height: 30px">
                <span class="glyphicon glyphicon-triangle-bottom" />
            </button>
            <button id="btnCopia" type="button" clientidmode="Static" runat="server" class="btn btn-default btn-sm btn-sm dropdown-toggle" title="Copia nella clipboard" style="width: 15%; height: 30px">
                <span class="glyphicon glyphicon-copy" />
            </button>
            <ul class="dropdown-menu">
                <asp:Repeater ID="rptPreferiti" runat="server" DataSourceID="DataSourcePreferiti">
                    <ItemTemplate>
                        <li>
                            <!-- La classe "btn-email" viene utilizzata oer catturare l'onclick sul singolo item della lista dei preferiti 
                                Il custo attribute data-email viene utilizzato da jquery per ottenere l'item(=indirizzo email) selezionato -->
                            <a class="btn-email" data-email='<%# Eval("Email") %>' href="#"><%# Eval("Email") %></a>
                        </li>
                    </ItemTemplate>
                </asp:Repeater>
            </ul>
        </div>

        <script type="text/javascript" src="../Scripts/clipboard.min.js"></script>
        <script type="text/javascript">
            //creo il bottone per copiare nella clipboard.
            new ClipboardJS('#btnCopia');
        </script>
    </ContentTemplate>
</asp:UpdatePanel>

<%-- MODALE INVIO MAIL PER LINK ACCESSO DIRETTO data-keyboard="false" fa si che non funziomi il tasto ESC, cosi l'utente deve usare il pulsante ANNULLA --%>
<div class="modal fade" id="modaleInvioEmail" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" data-backdrop="static" data-keyboard="false">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-body">

                <asp:UpdatePanel runat="server" ID="updInvioEmail" UpdateMode="Conditional" ChildrenAsTriggers="false">
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnCancellaDest" EventName="Click" />
                        <asp:AsyncPostBackTrigger ControlID="btnCercaUtenti" EventName="Click" />
                        <asp:AsyncPostBackTrigger ControlID="gvListaDestinatari" EventName="RowCommand" />
                        <asp:AsyncPostBackTrigger ControlID="gvListaDestinatari" EventName="PageIndexChanged" />
                        <asp:AsyncPostBackTrigger ControlID="btnMostraRicerca" EventName="Click" />
                        <asp:AsyncPostBackTrigger ControlID="btnAnnullaInvio" EventName="Click" />
                        <asp:AsyncPostBackTrigger ControlID="btnChiudiRicerca" EventName="Click" />
                        <asp:AsyncPostBackTrigger ControlID="btnInviaMail" EventName="Click" />
                    </Triggers>
                    <ContentTemplate>
                        <div class="row">
                            <div class="col-sm-12 alert alert-danger" id="divErroreModale" runat="server" enableviewstate="false" visible="false">
                                <asp:Label ID="lblErroreModale" runat="server" CssClass="text-danger" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-12">
                                <div id="divRicercaDestinatari" runat="server" clientidmode="Static" style="display: none">
                                    <div class="row">
                                        <div class="col-sm-12">
                                            <h4 class="modal-title" id="myModalLabel1"><span class="glyphicons glyphicons-envelope"></span>&nbsp;Ricerca destinatari</h4>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <hr />
                                        <div class="col-sm-12">
                                            <div class="panel panel-default">
                                                <div class="panel-body">
                                                    <div class="form">
                                                        <div class="row">
                                                            <div class="form-group form-group-sm col-sm-5">
                                                                <asp:Label Text="Cognome" runat="server" AssociatedControlID="txtCognome" />
                                                                <asp:TextBox CssClass="form-control" ID="txtCognome" runat="server" placeholder="Cognome" ClientIDMode="Static" />
                                                            </div>
                                                            <div class="form-group form-group-sm col-sm-5">
                                                                <asp:Label Text="Nome" runat="server" AssociatedControlID="txtNome" />
                                                                <asp:TextBox CssClass="form-control" ID="txtNome" runat="server" placeholder="Nome" />
                                                            </div>
                                                        </div>
                                                        <div class="row">
                                                            <div class="form-group form-group-sm col-sm-10">
                                                                <asp:Label Text="Email" runat="server" AssociatedControlID="txtEmail" />
                                                                <asp:TextBox CssClass="form-control" ID="txtEmail" runat="server" placeholder="Email" />
                                                            </div>
                                                            <div class="form-group form-group-sm col-sm-2 text-right">
                                                                <asp:Button ClientIDMode="Static" CssClass="btn btn-sm btn-primary" Text="Cerca" runat="server" ID="btnCercaUtenti" Style="margin-top: 20px;" />
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="col-sm-12">
                                            <div class="table-responsive">
                                                <asp:GridView ID="gvListaDestinatari" runat="server" DataSourceID="odsListaDestinatari" AutoGenerateColumns="False" CssClass="table table-condensed table-bordered" PageSize="10" AllowPaging="true">
                                                    <Columns>
                                                        <asp:TemplateField HeaderStyle-Width="20px">
                                                            <ItemTemplate>
                                                                <asp:LinkButton CssClass="btn btn-xs btn-link" ToolTip="Aggiungi utente" CommandArgument='<%# Eval("Email") %>' CommandName="AggiungiUtente" ID="btnAggiungiUtente" NavigateUrl="navigateurl" runat="server">
                                                <span class="glyphicons glyphicons-user-add"></span>
                                                                </asp:LinkButton>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:BoundField DataField="Cognome" HeaderText="Cognome" SortExpression="Cognome"></asp:BoundField>
                                                        <asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome"></asp:BoundField>
                                                        <asp:BoundField DataField="Email" HeaderText="Email" SortExpression="Email"></asp:BoundField>
                                                    </Columns>
                                                    <EmptyDataRowStyle CssClass="gv-emptyDataRow" BorderWidth="0" BorderColor="Transparent" />
                                                    <EmptyDataTemplate>
                                                        Non è stato trovato nessun destinatario. Modificare i parametri di filtro!
                                                    </EmptyDataTemplate>
                                                </asp:GridView>
                                            </div>
                                        </div>

                                        <asp:ObjectDataSource ID="odsListaDestinatari" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataDistinct" TypeName="DwhClinico.Web.CustomDataSource.SacUtentiCerca">
                                            <SelectParameters>
                                                <asp:Parameter Name="Ordinamento" Type="String"></asp:Parameter>
                                                <asp:Parameter Name="Utente" Type="String"></asp:Parameter>
                                                <asp:Parameter Name="Descrizione" Type="String"></asp:Parameter>
                                                <asp:ControlParameter ControlID="txtCognome" PropertyName="Text" Name="Cognome" Type="String"></asp:ControlParameter>
                                                <asp:ControlParameter ControlID="txtNome" PropertyName="Text" Name="Nome" Type="String"></asp:ControlParameter>
                                                <asp:Parameter Name="CodiceFiscale" Type="String"></asp:Parameter>
                                                <asp:Parameter Name="Matricola" Type="String"></asp:Parameter>
                                                <asp:ControlParameter ControlID="txtEmail" PropertyName="Text" Name="Email" Type="String"></asp:ControlParameter>
                                                <asp:Parameter Name="Attivo" Type="Boolean"></asp:Parameter>
                                                <asp:Parameter Name="CodiceRuolo" Type="String"></asp:Parameter>
                                            </SelectParameters>
                                        </asp:ObjectDataSource>
                                    </div>
                                    <div class="row">
                                        <hr />
                                        <div class="col-sm-12 text-right">
                                            <asp:Button ID="btnChiudiRicerca" runat="server" Text="Annulla" CssClass="btn btn-default" />
                                        </div>
                                    </div>

                                </div>
                                <div id="divInvioMail" runat="server" clientidmode="Static" style="display: none">
                                    <div class="row">
                                        <div class="col-sm-12">
                                            <h4 class="modal-title"><span class="glyphicons glyphicons-envelope"></span>&nbsp;Invia il link per Accesso Diretto</h4>
                                        </div>
                                    </div>
                                    <div class="form-horizontal">
                                        <hr />
                                        <div class="form-group">
                                            <div class="input-group">
                                                <span class="input-group-addon" id="basic-addon1">A:</span>
                                                <asp:TextBox runat="server" CssClass="form-control" Enabled="false" ClientIDMode="Static" ID="txtListaDestinatari" placeholder="Destinatario..." />
                                                <span class="input-group-btn">
                                                    <asp:LinkButton ID="btnCancellaDest" CssClass="btn btn-danger tokenfield-btn" runat="server" title="Rimuovi tutti i destinatari." ClientIDMode="Static">
                                                             <span class="glyphicons glyphicons-remove"></span>
                                                    </asp:LinkButton>
                                                    <asp:LinkButton ID="btnMostraRicerca" CssClass="btn btn-default tokenfield-btn" runat="server"><span class="glyphicons glyphicons-search"></span></asp:LinkButton>
                                                </span>
                                            </div>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ValidationGroup="mail" runat="server" ErrorMessage="Campo obbligatorio: selezionare almeno un destinatario." CssClass="label label-danger" ControlToValidate="txtListaDestinatari" Display="Dynamic"></asp:RequiredFieldValidator>
                                        </div>
                                        <div class="form-group">
                                            <div class="input-group">
                                                <span class="input-group-addon" id="basic-addon2">Oggetto:</span>
                                                <asp:TextBox runat="server" CssClass="form-control" Enabled="true" ClientIDMode="Static" ID="txtOggettoMail" placeholder="Oggetto..." />

                                            </div>
                                            <asp:RequiredFieldValidator ID="rqdOggetto" runat="server" ValidationGroup="mail" ErrorMessage="Campo obbligatorio: specificare un oggetto." CssClass="label label-danger" ControlToValidate="txtOggettoMail" Display="Dynamic"></asp:RequiredFieldValidator>
                                            </span>
                                        </div>

                                        <div class="form-group">
                                            <div class="checkbox" style="margin-left: 20px !important; margin-bottom: 5px">
                                                <asp:CheckBox ID="chkInviaMessaggioAlMittente" runat="server" Checked="True" />Invia messaggio al mittente
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <input type="text" disabled="disabled" class="form-control mail-input-custom-control" value="Messaggio (Il link all'Accesso Diretto viene inserito automaticamente in coda al messaggio)" />
                                            <asp:TextBox ID="txtCorpoMessaggio" ClientIDMode="Static" runat="server" Rows="10" TextMode="MultiLine" class="form-control mail-text-area-custom-control" placeholder="Inserire un messaggio." />
                                        </div>
                                    </div>
                                    <div class="row">
                                        <hr />
                                        <div class="col-sm-12 text-right">
                                            <asp:Button ID="btnAnnullaInvio" runat="server" Text="Annulla" CssClass="btn btn-default" CausesValidation="false" />
                                            <asp:Button CausesValidation="true" ValidationGroup="mail" CssClass="btn btn-primary" runat="server" ID="btnInviaMail" ClientIDMode="Static" Text="Invia" />

                                        </div>
                                    </div>
                                </div>

                            </div>
                        </div>
                        <script type="text/javascript">
                            //definisco qui la variabile che identifica l'update panel, che verrà usata all'interno dello script successivo
                            var upd = '<%= updInvioEmail.UniqueID %>';
                        </script>
                        <script type="text/javascript" src="<%= Page.ResolveUrl(String.Format("~/Scripts/uc-modale-invio-link-accesso-diretto.js?{0}", DwhClinico.Web.Utility.GetAssemblyVersion()))%>"></script>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
    </div>
</div>

<asp:ObjectDataSource ID="DataSourcePreferiti" runat="server" SelectMethod="GetData" TypeName="DwhClinico.Web.CustomDataSource.EmailDestinatariPreferitiCerca" OldValuesParameterFormatString="{0}">
    <SelectParameters>
        <asp:Parameter Name="EmailMittente" Type="String"></asp:Parameter>
    </SelectParameters>
</asp:ObjectDataSource>


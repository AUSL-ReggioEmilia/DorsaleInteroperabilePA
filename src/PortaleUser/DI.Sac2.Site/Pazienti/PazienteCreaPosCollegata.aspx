<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="PazienteCreaPosCollegata.aspx.vb" Inherits=".PazienteCreaPosCollegata" EnableEventValidation="false" %>

<%@ Register Src="~/UserControl/DettaglioPaziente.ascx" TagPrefix="uc1" TagName="DettaglioPaziente" %>


<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <div class="row" id="divErrorMessage" runat="server" visible="false">
        <div class="col-sm-12">
            <div class="alert alert-danger">
                <asp:Label ID="LabelError" runat="server" CssClass="text-danger" EnableViewState="False"></asp:Label>
            </div>
        </div>
    </div>

    <div id="MainTable" runat="server">
        <uc1:DettaglioPaziente runat="server" ID="DettaglioPaziente" />

        <div class="row">
            <div class="col-sm-12 col-md-6 col-md-offset-3">
                <asp:FormView ID="PazienteDettaglioFormView" runat="server" RenderOuterTable="False" DataKeyNames="Id" DataSourceID="PazienteDettaglioObjectDataSource"
                    EmptyDataText="Dettaglio non disponibile!" EnableModelValidation="True">
                    <ItemTemplate>
                        <h5>Dati posizione collegata</h5>
                        <div class="panel panel-default">
                            <div class="panel-body">
                                <div class="form-horizontal">
                                    <div class="form-group form-group-sm">
                                        <label for="lblSessoPosCollegata" class="col-sm-3 control-label">Sesso</label>
                                        <div class="col-sm-9">
                                            <asp:DropDownList CssClass="form-control" ID="ddlSessoPosCollegata" runat="server" OnDataBinding="ddlSessoPosCollegata_DataBinding">
                                                <asp:ListItem Selected="True"></asp:ListItem>
                                                <asp:ListItem>M</asp:ListItem>
                                                <asp:ListItem>F</asp:ListItem>
                                            </asp:DropDownList>
                                            <asp:RequiredFieldValidator ID="ddlSessoPosCollegataRequiredFieldValidator" runat="server" ControlToValidate="ddlSessoPosCollegata"
                                                ErrorMessage='Campo obbligatorio!' CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                                        </div>
                                    </div>
                                    <!-- DATA NASCITA -->
                                    <div class="form-group form-group-sm">
                                        <label for="lblDataNascitaPosCollegata" class="col-sm-3 control-label">Data nascita</label>
                                        <div class="col-sm-9">
                                            <asp:TextBox CssClass="form-control form-control-dataPicker" ID="txtDataNascitaPosCollegata" runat="server" MaxLength="10"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="DataNascitaPosCollegataRequiredFieldValidator" runat="server" ControlToValidate="txtDataNascitaPosCollegata"
                                                ErrorMessage='Campo obbligatorio!' CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                                            <asp:CompareValidator ID="cvalDataNascitaPosCollegata" runat="server" ControlToValidate="txtDataNascitaPosCollegata"
                                                ErrorMessage='Valore non valido!' CssClass="text-danger small" Display="Dynamic"
                                                Operator="DataTypeCheck" Type="Date"></asp:CompareValidator>
                                        </div>
                                    </div>
                                    <!-- COMUNE NASCITA -->
                                    <div class="form-group form-group-sm">
                                        <label for="lblComuneNascitaPosCollegata" class="col-sm-3 control-label">Comune nascita</label>
                                        <div class="col-sm-9">
                                            <progel:ProgelDropDownList ID="pddlComuneNascitaPosCollegata" runat="server"
                                                ServicePath="~/App_Services/Istat.asmx" ParentCategory="Province" ParentServiceMethod="GetProvinceIstat"
                                                ParentLoadingText="caricamento province..." Enabled="true"
                                                ParentBindValue="035" ChildCategory="Comuni"
                                                ChildServiceMethod="GetComuniIstat" ChildPromptText="- seleziona il comune -"
                                                ChildLoadingText="caricamento comuni..." />
                                            <%--ParentBindValue="035" --> 035 è il codice di Reggio nell'Emilia, richiesto come default--%>
                                        </div>
                                    </div>
                                    <div class="form-group form-group-sm">
                                        <label for="txtNote" class="col-sm-3 control-label">Motivo</label>
                                        <%--<asp:Label Text="Motivo" AssociatedControlID="txtNote" runat="server" />--%>
                                        <div class="col-sm-9">
                                            <asp:TextBox Style="width: 100%; max-width: none" ID="txtNote" CssClass="form-control" runat="server" MaxLength="2048" Rows="7" TextMode="MultiLine" placeholder="Inserire il motivo"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="txtNoteRequiredFieldValidator" runat="server" ControlToValidate="txtNote"
                                                ErrorMessage='Campo obbligatorio!' CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                                        </div>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </ItemTemplate>
                </asp:FormView>
                <div class="btn-group pull-right">
                    <asp:Button ID="btnConferma" runat="server" CssClass="btn btn-primary" Text="Conferma"
                        Causevalidation="True" />
                    <asp:Button ID="btnAnnulla" runat="server" CssClass="btn btn-default" Text="Annulla" CausesValidation="False" />
                </div>

            </div>
        </div>
    </div>

    <asp:ObjectDataSource ID="PazienteDettaglioObjectDataSource" runat="server" SelectMethod="GetData"
        TypeName="PazientiPosizioniCollegateDataSetTableAdapters.PazientiPosizioniCollegatePazienteSelectTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter Name="Id" QueryStringField="id" DbType="Guid" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <script type="text/javascript">
        // CREO I BOOTSTRAP DATEPICKER
        $('.form-control-dataPicker').datetimepicker({
            locale: moment.locale('it'),
            format: 'L',
            showTodayButton: true,
            useStrict: true,
            minDate: "01/01/1900"
        });
    </script>
</asp:Content>

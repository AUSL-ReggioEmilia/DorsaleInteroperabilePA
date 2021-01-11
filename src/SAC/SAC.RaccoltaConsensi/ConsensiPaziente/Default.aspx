<%@ Page Title="Raccolta dei Consensi Privacy" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="Default.aspx.vb" Inherits="._Default" %>

<%@ MasterType VirtualPath="~/Site.Master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">

    <script type="text/javascript">
        //CURSORE DI ATTESA SU RICERCA
        function ShowWaitCursor(sender) {
            try {
                if (Page_ClientValidate()) {
                    document.body.style.cursor = 'wait';
                    sender.style.cursor = 'wait';
                }
            } catch (e) { }
        }
    </script>

    <div id="divRicerca" class="visible" runat="server">
        <label class="h3">Raccolta dei Consensi Privacy</label>

        <div class="row" id="pannelloFiltri" runat="server">
            <div class="col-sm-12">
                <div class="panel panel-default small">
                    <div class="panel-body">
                        <div class="form-horizontal">
                            <div class="row">
                                <div class="col-sm-5">
                                    <div class="form-group form-group-sm">
                                        <asp:Label Text="Cognome:" runat="server" AssociatedControlID="txtFiltriCognome" CssClass="control-label col-sm-5" />
                                        <div class="col-sm-7">
                                            <asp:TextBox ID="txtFiltriCognome" runat="server" CssClass="form-control" MaxLength="64" placeholder="Cognome"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-5">
                                    <div class="form-group form-group-sm">
                                        <asp:Label Text="Nome:" runat="server" AssociatedControlID="txtFiltriNome" CssClass="control-label col-sm-5" />
                                        <div class="col-sm-7">
                                            <asp:TextBox ID="txtFiltriNome" runat="server" CssClass="form-control" MaxLength="64" placeholder="Nome"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-5">
                                    <div class="form-group form-group-sm">
                                        <asp:Label Text="Anno di nascita:" runat="server" AssociatedControlID="txtAnnoNascita" CssClass="control-label col-sm-5" />
                                        <div class="col-sm-7">
                                            <asp:TextBox ID="txtAnnoNascita" runat="server" CssClass="form-control" MaxLength="4" placeholder="es: 1999"></asp:TextBox>
                                            <asp:RangeValidator ID="RangeValidator1" runat="server" ErrorMessage="Anno non valido." ControlToValidate="txtAnnoNascita"
                                                Display="Dynamic" CssClass="label label-danger" Type="Integer" MinimumValue="1900" MaximumValue="2100" />
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-5">
                                    <div class="form-group form-group-sm">
                                        <asp:Label Text="Codice Fiscale:" runat="server" AssociatedControlID="txtCodfisc" CssClass="control-label col-sm-5" />
                                        <div class="col-sm-7">
                                            <asp:TextBox ID="txtCodfisc" runat="server" CssClass="form-control" MaxLength="16" placeholder="Codice Fiscale"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-2">
                                    <asp:Button ID="butFiltriRicerca" runat="server" CssClass="btn btn-primary btn-sm" Text="Cerca" OnClientClick="ShowWaitCursor(this);" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-sm-12">
                <div class="table-responsive small">
                    <asp:GridView ID="gvLista" runat="server" AllowSorting="false" AllowPaging="true" AutoGenerateColumns="False" DataSourceID="odsLista"
                        EnableModelValidation="True" EmptyDataText="Nessun risultato!" CssClass="table table-condensed table-bordered table-striped"
                        DataKeyNames="Id" PageSize="100">
                        <Columns>
                            <asp:HyperLinkField DataNavigateUrlFormatString="Consensi.aspx?Id={0}" ItemStyle-CssClass="text-center" DataNavigateUrlFields="Id" Text="&lt;span class='glyphicon glyphicon-folder-open' aria-hidden='true'/&gt" />
                            <asp:BoundField DataField="Cognome" HeaderText="Cognome" SortExpression="Cognome" />
                            <asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome" />
                            <asp:BoundField DataField="DataNascita" HeaderText="Data di&nbsp;Nascita" SortExpression="DataNascita" DataFormatString="{0:d}" />
                            <asp:BoundField DataField="Sesso" HeaderText="Sesso" SortExpression="Sesso" />
                            <asp:BoundField DataField="CodiceFiscale" HeaderText="Codice&nbsp;Fiscale" SortExpression="CodiceFiscale" />
                            <asp:BoundField DataField="ComuneNascitaNome" HeaderText="Comune di&nbsp;Nascita" SortExpression="ComuneNascitaNome" />
                            <asp:ImageField HeaderText="Residenza">
                            </asp:ImageField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

    <asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="PazientiCerca" TypeName="WcfSacPazientiHelper"
        OldValuesParameterFormatString="original_{0}">
        <SelectParameters>
            <asp:ControlParameter ControlID="txtFiltriCognome" Name="Cognome" PropertyName="Text" Type="String" ConvertEmptyStringToNull="False" />
            <asp:ControlParameter ControlID="txtFiltriNome" Name="Nome" PropertyName="Text" Type="String" ConvertEmptyStringToNull="False" />
            <asp:ControlParameter ControlID="txtAnnoNascita" Name="AnnoNascita" PropertyName="Text" Type="String" ConvertEmptyStringToNull="False" />
            <asp:ControlParameter ControlID="txtCodfisc" Name="CodiceFiscale" PropertyName="Text" Type="String" ConvertEmptyStringToNull="False" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="odsConsensi" runat="server" SelectMethod="ConsensiCerca" TypeName="WcfSacConsensiHelper"
        OldValuesParameterFormatString="original_{0}">
        <SelectParameters>
            <asp:QueryStringParameter DbType="Guid" Name="IdPaziente" QueryStringField="Id" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>

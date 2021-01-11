<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PazientiRinotificaMassiva.aspx.vb" Inherits=".PazientiRinotificaMassiva" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
     <style type="text/css">
        .ui-progressbar {
            position: relative;
        }

        .progress-label {
            position: absolute;
            left: 25%;
            top: 4px;
            font-weight: bold;
            text-shadow: 1px 1px 0 #fff;
        }
    </style>

    <asp:ScriptManager runat="server" />

    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />

    <div class="toolbar">
        <table id="pannelloFiltri" runat="server" style="padding: 13px;">
            <tr>
                <td>
                    <asp:Label ID="lbDataModificaDal" runat="server" Text="Data modifica dal (dd/MM/yyyy hh:mm)"></asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="txtDataModificaDal" runat="server" Width="120px" MaxLength="16"></asp:TextBox>
                </td>
                <td>
                    <asp:Label ID="lbDataModificaAl" runat="server" Text="Data modifica al (dd/MM/yyyy hh:mm)"></asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="txtDataModificaAl" runat="server" Width="120px" MaxLength="16"></asp:TextBox>
                </td>
                <td>
                    <asp:Button Text="Cerca" runat="server" CssClass="TabButton" ID="btnCerca" />
                </td>
            </tr>
        </table>
    </div>
    <br />
    <table>
        <tr>
            <td>
                <%-- NON E' STATO POSSIBILE INSERIRLO DENTRO ALL'UPDATE PANEL PERCHE' ALTRIMENTI NON FUNZIONA IL DOWNLOAD DEL FILE EXCEL. --%>
                <asp:Button ID="btnEsportaPazienti" CssClass="Button btn-esporta" Text="Esporta in Excel" Style="display: none; margin-bottom: 5px;" Width="120px" runat="server" UseSubmitBehavior="true" />
            </td>
            <td style="width: 500px">
                <asp:UpdatePanel runat="server" ID="UpdatePanel1" UpdateMode="Conditional">
                    <ContentTemplate>
                        <%-- OnClientClick="ChangeCursor();"--%>
                        <asp:Button CssClass="Button btn-rinotifica" EnableViewState="false" Enabled="false" Width="100px" ID="btnRinotifica" runat="server" Text="Rinotifica Tutti" />
                        <asp:Button CssClass="Button btn-annullaRinotifica" EnableViewState="false" Enabled="false" Width="120px" ID="btnAnnullaRinotifica" runat="server" Text="Annulla Rinotifica" />
                        <asp:Timer runat="server" ID="timerRinotifica" Enabled="false" Interval="1000"></asp:Timer>
                        <div id="progressbar" class="progressbar" style="width: 100%; margin-top: 5px;" runat="server">
                            <div id="progressLabel" class="progress-label">
                                <asp:Label runat="server" Text="Inizio Rinotifica..." ID="lblStatoNotifica" />
                            </div>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>

    <br />
    <asp:Label ID="lblMaxNumRow" Visible="false" Text="" runat="server" />

    <asp:GridView ID="gvPazientiModificati" runat="server" DataSourceID="odsPazientiModificati" AllowPaging="True" AllowSorting="True"
        AutoGenerateColumns="False" BackColor="White" BorderColor="White" BorderStyle="Solid"
        BorderWidth="1px" CellPadding="4" PagerSettings-Position="TopAndBottom" GridLines="Horizontal" PageSize="100" DataKeyNames="Id"
        Width="100%" EnableModelValidation="True">
        <Columns>
            <asp:TemplateField HeaderText="Nome" SortExpression="Cognome">
                <ItemTemplate>
                    <%# String.Format("{0} {1}", Eval("Cognome"), Eval("Nome")) %>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="DataNascita" HeaderText="Data di nascita" SortExpression="DataNascita"
                DataFormatString="{0:d}" HtmlEncode="False" />
            <asp:BoundField DataField="ComuneNascita" HeaderText="Comune di nascita" SortExpression="ComuneNascita" />
            <asp:BoundField DataField="CodiceFiscale" HeaderText="Codice Fiscale" SortExpression="CodiceFiscale" />
            <asp:BoundField DataField="DataDecesso" HeaderText="Data di decesso" SortExpression="DataDecesso"
                DataFormatString="{0:d}" HtmlEncode="False" />
            <asp:BoundField DataField="Provenienza" HeaderText="Provenienza" SortExpression="Provenienza" />
        </Columns>
        <EmptyDataTemplate>
            <b>Nessun risultato!</b>
        </EmptyDataTemplate>
        <RowStyle BackColor="White" ForeColor="#333333" />
        <PagerStyle CssClass="GridPager" />
        <HeaderStyle Font-Bold="True" ForeColor="Black" HorizontalAlign="Left" CssClass="GridHeader" />
    </asp:GridView>

    <asp:ObjectDataSource ID="odsPazientiModificati" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.PazientiDataSetTableAdapters.PazientiUiNotificaListaTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="DataModificaDal" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="DataModificaAl" Type="DateTime"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>


    <script type="text/javascript">
        /*
        * MOSTRA UN CONFIRM QUANDO SI PREME IL PULSANTE DI RINOTIFICA DEI PAZIENTI.
        */
        $(".btn-rinotifica").click(function () {
            var numeroPazienti = '<%= numPazienti %>'
            return confirm('Verranno rinotificati ' + numeroPazienti + ' pazienti.\nProseguire comunque?');
        });

        /*
        *MOSTRA UN CONFIRM QUANDO SI PREME SUL PULSANTE DI ANNULLAMENTO DELLA RINOTIFICA.
        */
        $(".btn-annullaRinotifica").click(function () {
            return confirm('Verrà annullata la rinotifica dei pazeinti mancanti. \n Proseguire comunque?');
        });

        function MouseWait(sender) {
            try {
                sender.style.cursor = 'wait';
                document.body.style.cursor = 'wait';
                //DOPO 3 SECONDI RIMETTE A POSTO IL CURSORE
                setTimeout(function () {
                    sender.style.cursor = 'auto';
                    document.body.style.cursor = 'auto';
                }, 3000);
            } catch (e) {
            }
        }

        function ChangeCursor() {
            $("body").css("cursor", "progress");
            $(".btn-cerca-annulla").attr("disabled", "disabled");
        };
    </script>
</asp:Content>

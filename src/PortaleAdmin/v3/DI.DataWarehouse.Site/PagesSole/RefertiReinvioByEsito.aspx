<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="RefertiReinvioByEsito.aspx.vb" Inherits=".RefertiReinvioByEsito" %>
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

        div.legenda {
            display: inline-block;
            overflow: hidden;
            margin: 0px 30px 0px 10px;
        }

            div.legenda ul {
                margin-top: 6px;
                margin-left: 15px;
                margin-bottom: 0px;
            }

        .StileRicoveroOscurato {
            cursor: default;
            background-color: #C4C4C4;
            color: #6F6F6F;
        }
    </style>

    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />

    <div Id="divLegenda" class="Title" style="width: 600px;">
        Imposta il reinvio a SOLE dei referti il cui esito dell'invio è "In Errore" o "Da inviare"
    </div>

    <asp:ScriptManager runat="server" />

    <fieldset runat="server" id="pannelloFiltri" class="filters">
        <legend>Ricerca</legend>
        <table>
            <tr>
                <td><asp:Label ID="lblFilterEsito" runat="server" Text="Esito"></asp:Label></td>
                <td><asp:Label ID="lblFilterDallaData" runat="server" Text="Data Invio Sole Dal"></asp:Label> (dd/MM/yyyy hh:mm)</td>
                <td><asp:Label ID="lblFilterAllaData" runat="server" Text="Data Invio Sole Al"></asp:Label> (dd/MM/yyyy hh:mm)</td>
                <td><asp:Label ID="lblFilterMaxRecords" runat="server" Text="Max Records"></asp:Label></td>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td>
                    <asp:DropDownList ID="cmbEsiti" runat="server" Width="150px">
                    </asp:DropDownList>
                </td>
                <td><asp:TextBox ID="txtDallaData" runat="server" Width="150px" MaxLength="16"></asp:TextBox></td>
                <td><asp:TextBox ID="txtAllaData" runat="server" Width="150px" MaxLength="16"></asp:TextBox></td>
                <td><asp:TextBox ID="txtMaxNumRecords" runat="server" Width="150px" MaxLength="16"></asp:TextBox></td>
                <td><asp:Button CssClass="Button" ID="btnCerca" runat="server" Text="Cerca" CausesValidation="true" /></td>
                <td><asp:Button CssClass="Button" ID="btnAnnulla" runat="server" Text="Annulla" /></td>
            </tr>
        </table>
    </fieldset>

    <br />
    <%-- ATTENZIONE:
                         1) VIENE ESEGUITA LA STORED PROCEDURE DI INSERIMENTO OGNI 100ms IN MODO DA PROCESSARE N OGGETTI ALLA VOLTA.
                         2) QUESTO PER EVITARE CHE SQL VADA IN TIMEOUT NEL CASO GLI OGGETTI DA PROCESSARE SIANO UN NUMERO ELEVATO.
                         3) OGNI VOLTA CHE VENGONO INVIATI N OGGETTI AGGIORNO LA LABEL lblStatoNotifica           
    --%>
    <table>
        <tr>
            <td>
                <%-- NON E' STATO POSSIBILE INSERIRLO DENTRO ALL'UPDATE PANEL PERCHE' ALTRIMENTI NON FUNZIONA IL DOWNLOAD DEL FILE EXCEL. --%>
                <asp:Button ID="btnEsportaInExcel" CssClass="Button btn-esporta" Text="Esporta in Excel" Style="display: none; margin-bottom: 5px;" Width="120px" runat="server" UseSubmitBehavior="true" />
            </td>
            <td style="width: 500px">
                <asp:UpdatePanel runat="server" ID="UpdatePanel1" UpdateMode="Conditional">
                    <ContentTemplate>
                        <%-- OnClientClick="ChangeCursor();"--%>
                        <asp:Button CssClass="Button btn-riprocessa" EnableViewState="false" Enabled="false" Width="120px" ID="btnRiprocessa" runat="server" Text="Riprocessa Tutti" />
                        <asp:Button CssClass="Button btn-annullaRiprocessamento" EnableViewState="false" Enabled="false" Width="120px" ID="btnAnnullaRiprocessa" runat="server" Text="Annulla" />
                        <asp:Timer runat="server" ID="Timer1" Enabled="false" Interval="1000"></asp:Timer>
                        <div id="progressbar" class="progressbar" style="width: 100%; margin-top: 5px;" runat="server">
                            <div class="progress-label">
                                <asp:Label runat="server" Text="Inizio riprocessamento..." ID="lblStatoNotifica" />
                            </div>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>

    <br />
    <asp:Label ID="lblMaxNumRow" Visible="false" Text="" runat="server" />

    <asp:GridView ID="gvReferti" runat="server" DataSourceID="odsReferti" AllowPaging="True" AllowSorting="true" AutoGenerateColumns="False"
        PageSize="100" CssClass="Grid" Width="700px" EmptyDataText="Nessun risultato!">
        <RowStyle CssClass="GridItem" />
        <SelectedRowStyle CssClass="GridSelected" />
        <PagerStyle CssClass="GridPager" />
        <HeaderStyle CssClass="GridHeader" />
        <AlternatingRowStyle CssClass="GridAlternatingItem" />
        <FooterStyle CssClass="GridFooter" />
        <Columns>
            <asp:BoundField DataField="DataQueue" HeaderText="Data Queue" SortExpression="DataQueue"></asp:BoundField>
            <asp:BoundField DataField="IdReferto" HeaderText="IdReferto" SortExpression="IdReferto"></asp:BoundField>
            <asp:BoundField DataField="DataModifica" HeaderText="Data Modifica" SortExpression="DataModifica"></asp:BoundField>
            <asp:BoundField DataField="AziendaErogante" HeaderText="Azienda Erogante" SortExpression="AziendaErogante"></asp:BoundField>
            <asp:BoundField DataField="SistemaErogante" HeaderText="Sistema Erogante" SortExpression="SistemaErogante"></asp:BoundField>
            <asp:BoundField DataField="DataReferto" HeaderText="Data Referto" SortExpression="DataReferto"></asp:BoundField>
            <asp:BoundField DataField="NumeroReferto" HeaderText="Numero Referto" SortExpression="NumeroReferto"></asp:BoundField>
            <asp:BoundField DataField="DataInvioSole" HeaderText="Data Invio Sole" SortExpression="DataInvioSole"></asp:BoundField>
        </Columns>
    </asp:GridView>

    <asp:ObjectDataSource ID="odsReferti" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DI.DataWarehouse.Admin.Data.SoleTableAdapters.RefertiReinvioMassivoCercaTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="DallaData" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="AllaData" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="MaxReinvii" Type="Int32"></asp:Parameter>
            <asp:Parameter Name="Filtro_Stato_AE" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="Filtro_Stato_NULL" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="Filtro_Stato_IV" Type="Boolean"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <script type="text/javascript">
        /*
        * MOSTRA UN CONFIRM QUANDO SI PREME IL PULSANTE DI RINOTIFICA DEI REFERTI.
        */
        $(".btn-riprocessa").click(function () {
            var numero = '<%= NumOggettiTrovati %>'
            return confirm('Verranno riprocessati ' + numero + ' referti. \nProseguire?');

        });

        $(".btn-annullaRiprocessamento").click(function () {
            return confirm('Verrà annullato il riprocessamento dei referti mancanti. \n Proseguire?');
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

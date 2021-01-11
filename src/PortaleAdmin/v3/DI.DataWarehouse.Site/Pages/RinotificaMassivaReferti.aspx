<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="RinotificaMassivaReferti.aspx.vb" Inherits=".RinotificaMassivaReferti" %>

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
    <asp:ScriptManager runat="server" />

    <fieldset runat="server" id="pannelloFiltri" class="filters">
        <legend>Ricerca</legend>
        <table>
            <tr>
                <td>Azienda Erogante
                </td>
                <td>Sistema Erogante
                </td>
                <td>Id Paziente
                </td>
                <td></td>
            </tr>
            <tr>
                <td>
                       <asp:DropDownList ID="cmbAziendaErogante" runat="server" DataSourceID="AziendeObjectDataSource" DataTextField="Descrizione"
                        DataValueField="Codice" Width="210px">
                    </asp:DropDownList>

                    <asp:ObjectDataSource ID="AziendeObjectDataSource" runat="server" SelectMethod="GetData"
                        TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.AziendeErogantiListaTableAdapter"
                        OldValuesParameterFormatString="{0}" EnableCaching="true" CacheDuration="120"></asp:ObjectDataSource>
                </td>
                <td>
                    <asp:DropDownList ID="cmbSistemaErogante" runat="server" DataSourceID="odsSistemiEroganti" DataTextField="Descrizione"
                        DataValueField="Codice" Width="150px">
                    </asp:DropDownList>
                </td>
                <td>
                    <asp:TextBox ID="txtIdPaziente" runat="server" Width="150px"></asp:TextBox>
                </td>
                <td>
                    <asp:Button CssClass="Button" ID="butFiltriRicerca" runat="server" Text="Cerca" CausesValidation="true" />
                </td>
            </tr>
            <tr>
                <td colspan="2">Data Modifica (dal / al) (dd/MM/yyyy hh:mm) </td>
                <td></td>
                <td></td>
                <td></td>
            </tr>
            <tr>
                <td colspan="2">
                    <asp:TextBox ID="txtDallaData" runat="server" Width="150px" MaxLength="16"></asp:TextBox>
                    <asp:TextBox ID="txtAllaData" runat="server" Width="150px" MaxLength="16"></asp:TextBox>
                </td>
                <td></td>
                <td>
                    <asp:Button CssClass="Button" ID="btnAnnulla" runat="server" Text="Annulla" /></td>
            </tr>
            <tr>
                <td colspan="9">
                    <div>
                        <b>Compilare almeno una delle seguenti combinazioni di filtri:</b>
                    </div>
                </td>
            </tr>
            <tr>
                <td colspan="9">
                    <div class="legenda">
                        <ul>
                            <li>Id Paziente,Data Modifica</li>
                        </ul>
                    </div>
                    <div class="legenda">
                        <ul>
                            <li>Azienda Erogante,Sistema Erogante,Data Modifica</li>
                        </ul>
                    </div>
                </td>
            </tr>
        </table>
    </fieldset>

    <br />
    <%-- ATTENZIONE:
                         1) VIENE ESEGUITA LA STORED PROCEDURE DI INSERIMENTO OGNI 100ms IN MODO DA INVIARE 100 REFERTI ALLA VOLTA.
                         2) QUESTO PER EVITARE CHE SQL VADA IN TIMEOUT NEL CASO I REFERTI DA RINOTIFICARE SIANO UN NUMERO ELEVATO.
                         3) OGNI VOLTA CHE VENGONO INVIATI 100 REFERTI AGGIORNO LA LABEL Label1           
    --%>
    <table>
        <tr>
            <td>
                <%-- NON E' STATO POSSIBILE INSERIRLO DENTRO ALL'UPDATE PANEL PERCHE' ALTRIMENTI NON FUNZIONA IL DOWNLOAD DEL FILE EXCEL. --%>
                <asp:Button ID="btnEsportaReferti" CssClass="Button btn-esporta" Text="Esporta in Excel" Style="display: none; margin-bottom: 5px;" Width="120px" runat="server" UseSubmitBehavior="true" />
            </td>
            <td style="width: 500px">
                <asp:UpdatePanel runat="server" ID="UpdatePanel1" UpdateMode="Conditional">
                    <ContentTemplate>
                        <%-- OnClientClick="ChangeCursor();"--%>
                        <asp:Button CssClass="Button btn-rinotifica" EnableViewState="false" Enabled="false" Width="100px" ID="btnRinotifica" runat="server" Text="Rinotifica Tutti" />
                        <asp:Button CssClass="Button btn-annullaRinotifica" EnableViewState="false" Enabled="false" Width="120px" ID="btnAnnullaRinotifica" runat="server" Text="Annulla Rinotifica" />
                        <asp:Timer runat="server" ID="Timer1" Enabled="false" Interval="1000"></asp:Timer>
                        <div id="progressbar" class="progressbar" style="width: 100%; margin-top: 5px;" runat="server">
                            <div class="progress-label">
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

    <asp:GridView ID="gvReferti" runat="server" DataSourceID="RefertiOds" AllowPaging="True" AllowSorting="true" AutoGenerateColumns="False"
        PageSize="100" CssClass="Grid" Width="700px" EmptyDataText="Nessun risultato!">
        <RowStyle CssClass="GridItem" />
        <SelectedRowStyle CssClass="GridSelected" />
        <PagerStyle CssClass="GridPager" />
        <HeaderStyle CssClass="GridHeader" />
        <AlternatingRowStyle CssClass="GridAlternatingItem" />
        <FooterStyle CssClass="GridFooter" />
        <Columns>
            <asp:BoundField DataField="Id" HeaderText="Id Referto" SortExpression="Id" />
            <asp:BoundField DataField="IdEsterno" ItemStyle-CssClass="breakword" HeaderText="Id Esterno" SortExpression="IdEsterno" />
            <asp:BoundField DataField="DataInserimento" HeaderText="Data Inserimento" SortExpression="DataInserimento" />
            <asp:BoundField DataField="DataModifica" HeaderText="Data Modifica" SortExpression="DataModifica" />
            <asp:BoundField DataField="AziendaErogante" HeaderText="Azienda Erogante" SortExpression="AziendaErogante" />
            <asp:BoundField DataField="SistemaErogante" HeaderText="Sistema Erogante" SortExpression="SistemaErogante" />
            <asp:BoundField DataField="StatoRichiestaDescr" HeaderText="Stato Richiesta" ReadOnly="True" SortExpression="StatoRichiestaDescr" />
            <asp:BoundField DataField="RepartoErogante" HeaderText="Reparto Erogante" SortExpression="RepartoErogante" />
            <asp:BoundField DataField="DataReferto" HeaderText="Data Referto" SortExpression="DataReferto" DataFormatString="{0:d}" />
            <asp:BoundField DataField="NumeroReferto" HeaderText="Numero Referto" SortExpression="NumeroReferto" />
            <asp:BoundField DataField="NumeroNosologico" HeaderText="Numero Nosologico" SortExpression="NumeroNosologico" />
            <asp:BoundField DataField="NumeroPrenotazione" HeaderText="Numero Prenotazione" SortExpression="NumeroPrenotazione" />
            <asp:TemplateField HeaderText="Paziente" SortExpression="Cognome">
                <ItemStyle HorizontalAlign="Left" />
                <ItemTemplate>
                    <b>
                        <%#Eval("Nome") & "&nbsp;" & Eval("Cognome")%></b><br />
                    Nato
					<%#If(Eval("ComuneNascita") Is DBNull.Value, "", " a " & Eval("ComuneNascita"))%>
					il&nbsp;<%#Eval("DataNascita", "{0:d}") %><br />
                    <%#If(Eval("CodiceFiscale") Is DBNull.Value, "", "C.F.&nbsp;" & Eval("CodiceFiscale"))%>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Reparto Richiedente" SortExpression="RepartoRichiedenteCodice">
                <ItemTemplate>
                    <%#Eval("RepartoRichiedenteCodice") & "-" & Eval("RepartoRichiedenteDescr") %>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="CodiceOscuramento" HeaderText="Codice Oscuramento" />
        </Columns>
    </asp:GridView>

    <asp:ObjectDataSource ID="RefertiOds" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="RefertiDataSetTableAdapters.BeRefertiNotificaListaTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="aziendaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="sistemaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="idPaziente" DbType="Guid"></asp:Parameter>
            <asp:Parameter Name="DallaData" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="AllaData" Type="DateTime"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="odsSistemiEroganti" runat="server" SelectMethod="GetDataByAziendaETipo"
        TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.SistemiErogantiListaTableAdapter"
        EnableCaching="false" OldValuesParameterFormatString="{0}">
        <SelectParameters>
            <asp:Parameter Name="AziendaErogante" Type="String" />
            <asp:Parameter DefaultValue="referti" Name="Tipo" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <script type="text/javascript">
        /*
        * MOSTRA UN CONFIRM QUANDO SI PREME IL PULSANTE DI RINOTIFICA DEI REFERTI.
        */
        $(".btn-rinotifica").click(function () {
            var numeroReferti = '<%= numReferti %>'
            return confirm('Verranno rinotificati ' + numeroReferti + ' referti.\nLa rinotifica interesserà tutti i dipartimentali compreso "SOLE".\nProseguire comunque?');


        });

        $(".btn-annullaRinotifica").click(function () {
            return confirm('Verrà annullata la rinotifica dei referti mancanti. \n Proseguire comunque?');
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

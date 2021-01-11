<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/SitePopup.Master" CodeBehind="DettaglioSistemiDatoAccessorio.aspx.vb" Inherits=".DettaglioSistemiDatoAccessorio" %>

<asp:Content ID="Content1" ContentPlaceHolderID="OrderEntryContentPlaceHolder" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />
    <div style="width: 100%">
        <div style="width: 45%; float: left;">
            <fieldset style="height: 400px;">
                <legend>Sistemi che comprendono il Dato Accessorio</legend>
                <div style="height: 400px; overflow-y: auto; margin-top: 10px;">
                    <asp:GridView ID="gvSistemiDatoAccessorio" Style="width: 100%; border: 1px silver solid;" border="1"
                        class="Grid" DataKeyNames="IDSistema" GridLines="none" runat="server" DataSourceID="odsSistemiDatoAccessorio" AutoGenerateColumns="False">
                        <Columns>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <asp:CheckBox ID="chkSistemi" AutoPostBack="true" OnCheckedChanged="chekAllSistemiDatoAccessorio" runat="server" />
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:CheckBox ID="chkSistemiDatoAccessorio" AutoPostBack="false" runat="server" />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:ImageButton class="ImageButton" BorderWidth="0px" ImageUrl="~/Images/edititem.gif" ID="ImageButton1" runat="server" ToolTip="modifica dati accessori"  OnClientClick='<%# "ShowPopUpSistemi(""" & Me.Request.QueryString("id").ToString() & """, """ & Eval("IDSistema").ToString & """, """ & Eval("ID").ToString & """, """ & Eval("Descrizione").ToString() & """, """ & Eval("Codice").ToString() & """); return false;"%>' />
                                </ItemTemplate>
                            </asp:TemplateField>
							<asp:TemplateField>
								<HeaderTemplate>
									Sistema Erogante
								</HeaderTemplate>
								<ItemTemplate>
									<asp:label runat="server"><%# String.Format("{0}-{1}", Eval("Azienda").ToString, Eval("Codice").ToString) %></asp:label>
								</ItemTemplate>
							</asp:TemplateField>
                            <%--<asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"></asp:BoundField>--%>
                            <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" ReadOnly="True" SortExpression="Descrizione"></asp:BoundField>
							<%--<asp:BoundField DataField="Azienda" HeaderText="Azienda" ReadOnly="True" SortExpression="Azienda"></asp:BoundField>--%>
                            <asp:CheckBoxField DataField="Attivo" HeaderText="Attivo" SortExpression="Attivo"></asp:CheckBoxField>
                        </Columns>
                    </asp:GridView>
                </div>
            </fieldset>
        </div>

        <div style="width: 10%; margin-top: 30px; float: left; text-align: center; height: 25px;">
            <asp:ImageButton class="ImageButton" ImageUrl="~/Images/back.gif" ID="addButton"  Text="Aggiungi" runat="server" />
            <asp:ImageButton class="ImageButton" ImageUrl="~/Images/next.gif" ID="removeButton"  Text="Aggiungi" runat="server" />
        </div>

        <div style="width: 45%; float: left">
            <fieldset style="height: 400px;">
                <legend>Sistemi</legend>
                Codice o Descrizione:
                <asp:TextBox ID="codiceDescrizioneTxb" ToolTip="Codice o Descrizione" runat="server" />
                <asp:Button runat="server" ID="cercaBtn" Text="Cerca" />
                <div style="height: 400px; overflow-y: auto;">
                    <asp:GridView Style="width: 100%; border: 1px silver solid;" border="1"
                        class="Grid" ID="gvSistemi" runat="server" DataSourceID="odsSistemi" AutoGenerateColumns="False" DataKeyNames="ID">
                        <Columns>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <asp:CheckBox ID="chkSistemi" AutoPostBack="true" OnCheckedChanged="chekAllSistemi" runat="server" />
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:CheckBox ID="chkSistemiLista" AutoPostBack="false" runat="server" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <%--<asp:BoundField DataField="ID" HeaderText="ID" Visible="false" ReadOnly="True" SortExpression="ID"></asp:BoundField>--%>
							<asp:TemplateField>
								<HeaderTemplate>
									Sistema Erogante
								</HeaderTemplate>
								<ItemTemplate>
									<asp:Label runat="server"><%# String.Format("{0}-{1}", Eval("Azienda").ToString, Eval("Codice").ToString) %></asp:Label>
								</ItemTemplate>
							</asp:TemplateField>
							<%--<asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"></asp:BoundField>--%>
                            <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" ReadOnly="True" SortExpression="Descrizione"></asp:BoundField>
							<%--<asp:BoundField DataField="Azienda" HeaderText="Azienda" ReadOnly="True" SortExpression="Azienda"></asp:BoundField>--%>
                            <asp:CheckBoxField DataField="Attivo" HeaderText="Attivo" SortExpression="Attivo"></asp:CheckBoxField>
                            <%--<asp:CheckBoxField DataField="Erogante" HeaderText="Erogante" ReadOnly="True" SortExpression="Erogante"></asp:CheckBoxField>
            <asp:CheckBoxField DataField="Richiedente" HeaderText="Richiedente" ReadOnly="True" SortExpression="Richiedente"></asp:CheckBoxField>
            <asp:BoundField DataField="Azienda" HeaderText="Azienda" SortExpression="Azienda"></asp:BoundField>
            
            <asp:CheckBoxField DataField="CancellazionePostInoltro" HeaderText="CancellazionePostInoltro" ReadOnly="True" SortExpression="CancellazionePostInoltro"></asp:CheckBoxField>--%>
                        </Columns>
                    </asp:GridView>
                </div>
            </fieldset>
        </div>
    </div>

    <div style="width: 100%;">
        <button style="float: right; margin-top: 50px;" onclick="window.parent.commonModalDialogClose(0);" class="asp_button">
            Chiudi</button>
    </div>

    <asp:ObjectDataSource ID="odsSistemiDatoAccessorio" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.DatiAccessoriTableAdapters.UiDatiAccessoriSistemiTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter QueryStringField="id" Name="CodiceDatoAccessorio" Type="String"></asp:QueryStringParameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="odsSistemi" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.SistemiTableAdapters.UiSistemiSelectTableAdapter">
        <SelectParameters>
            <asp:Parameter DbType="Guid" Name="ID"></asp:Parameter>
            <asp:Parameter Name="CodiceDescrizione" Type="String"></asp:Parameter>
            <asp:Parameter Name="Azienda" Type="String"></asp:Parameter>
            <asp:Parameter Name="Erogante" Type="Boolean" DefaultValue="true"></asp:Parameter>
            <asp:Parameter Name="Richiedente" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="Attivo" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="CancellazionePostInoltro" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="CancellazionePostInCarico" Type="Boolean"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>


    <script type="text/javascript">
        function ShowPopUpSistemi(idDatoAccessorio, idSistema, Id, descrizioneSistema,codiceSistema) {

            if (idDatoAccessorio == undefined || idDatoAccessorio == '') {
                commonModalDialogOpen('DettaglioAssociazioneSistemiDatoAccessorio.aspx', '', 300, 300);
            }
            else {
                commonModalDialogOpen('DettaglioAssociazioneSistemiDatoAccessorio.aspx?IdDatoAccessorio=' + idDatoAccessorio + '&idSistema=' + idSistema + '&id=' + Id + '&descrizione=' + descrizioneSistema, 'Modifica Dati Accessori Sistemi   [' + codiceSistema + '] - ' + descrizioneSistema, 300, 300);
            }
            return false;
        }
    </script>
</asp:Content>

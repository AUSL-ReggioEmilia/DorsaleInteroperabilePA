<%@ Page Title="Ordini" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
  CodeBehind="AbbonamentiStampeDettaglio.aspx.vb" Inherits="DI.DataWarehouse.Admin.AbbonamentiStampeDettaglio" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
  <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
    Visible="False"></asp:Label>
  <table style="width: 100%;">
    <tr>
      <td class="toolbar">
        <a id="SalvaButton" href="#" onclick="salva(true); return false;" style="background-image: url(../Images/save.png);">
          Salva</a> | <a id="ApplicaButton" href="#" style="background-image: url(../Images/save.png);"
            onclick="salva(); return false;">Applica</a> | <a id="EliminaButton" href="#" onclick="elimina(); return false;"
              style="background-image: url(../Images/trash.gif);">Elimina</a> | <a id="AttivaDisattivaButton"
                href="#" onclick="cambiaAttivazione(); return false;" style="background-image: url(../Images/stato.gif);">
                Attiva</a>
      </td>
    </tr>
  </table>
  <fieldset id="testata" class="filters">
    <legend>Dettaglio</legend>
    <div>
      <span>Nome</span>
      <br />
      <input type="text" id="NomeTextBox" data-bind="Nome" data-validate />
    </div>
    <div>
      <span>Account</span><br />
      <input type="text" id="AccountTextBox" data-bind="Account" disabled />
    </div>
    <div>
      <span>Stato</span><br />
      <input type="text" id="StatoText" data-bind="Stato" disabled />
    </div>
    <div>
      <span>Data fine</span><br />
      <input type="text" id="DataFineAlTextBox" class="DateInput" data-bind="DataFine"
        data-validate />
    </div>
    <div>
      <span>Tipo referto</span><br />
      <select id="TipoRefertoSelect" data-bind="IdTipoReferto" data-validate>
      </select>
    </div>

    <div>
      <span>Server di stampa</span><br />
      <input type="text" id="ServerDiStampaTextBox" data-bind="ServerDiStampa" data-validate />
    </div>
    <div>
      <span>Stampante</span>
      <br />
      <input type="text" id="StampanteTextBox" data-bind="Stampante" data-validate />
    </div>
    
    <div>
      <span>Numero copie</span>
      <br />
      <input type="text" id="NumeroCopieTextBox" data-bind="NumeroCopie" data-validate />
    </div>

    <%-- Ho messo una table altrimenti i due check non vanno a capo correttamente ma l'ultimo si incolonna sotto al primo --%>
    <table><tr><td>
        <div>
            <span>Stampa&nbsp;Confidenziali</span><br />
            <input id="chkStampaConfidenziali" type="checkbox" data-bind="StampaConfidenziali" />
        </div>
        </td>
        <td>
        <div>
            <span>Stampa&nbsp;Oscurati</span><br />
            <input id="chkStampaOscurati" type="checkbox" data-bind="StampaOscurati" />
        </div>
    </td></tr></table>
       

    <div class="separator">
    </div>
    <div style="width: 100%;">
      <span>Descrizione</span><br />
      <textarea id="DescrizioneTextarea" maxlength="1024" style="width: 98%; height: 80px;"
        data-bind="Descrizione"></textarea>
    </div>
  </fieldset>
  <div class="separator">
  </div>
  <fieldset class="filters" style="width: 98%;">
    <legend>Reparti richiedenti</legend>
    <div style="width: 100%">
      <input type="button" id="EliminaSelezionatiButton" class="deleteButton" value="Elimina selezionati"
        onclick="eliminaRepartiRichiedenti(); return false;" />
      <input type="button" id="AggiungiRepartiButton" class="newButton" value="Aggiungi reparti"
        onclick="mostraDialogAggiungiRepartiRichiedenti(); return false;" />
    </div>
    <div id="Sistemi" style="width: 100%;">
      <table id="sistemiGrid" class="tablesorter" style="border: 1px silver solid; border-collapse: collapse;
        width: 100%; margin-top: 5px;">
        <thead>
          <th style="text-align: center; width: 30px; padding: 0px;">
            <input type="checkbox" style="background: transparent; border-style: none; cursor: pointer;"
              onclick="SelectDeselectAll($(this), $('#sistemiGrid'));" />
          </th>
          <th>
            Azienda
          </th>
          <th>
            Sistema
          </th>
          <th>
            Codice
          </th>
          <th>
            Descrizione
          </th>
        </thead>
        <tbody>
        </tbody>
      </table>
    </div>
  </fieldset>
  <div style="display: none;" id="AggiungiRepartiRichiedentiDiv">
    <div id="selettoreReparti" style="padding: 5px;">
      <div id="selettoreRepartiFiltro" style="padding: 4px;">
        <div style="float: left; padding: 4px;">
          <span>Azienda:</span>
          <select id="aziendaFiltro" style="height: 22px; width: 100px;" onchange="caricaSistemi(); return false;">
            <option selected="selected" value=""></option>
          </select>
        </div>
        <div style="float: left; padding: 4px;">
          <span>Sistema:</span>
          <select id="sistemaFiltro" disabled style="height: 22px; width: 100px;">
            <option selected="selected" value=""></option>
          </select>
        </div>
        <div style="float: left; padding: 4px;">
          <span>Descrizione:</span>
          <input id="descrizioneFiltro" type="text" onkeydown="if(event.keyCode == 13){return false;}"
            onkeyup="if(event.keyCode == 13){CercaReparti();} return false;" style="width: 100px;" />
        </div>
        <div style="float: left; text-align: right; margin: 1px;">
          <input id="searchRepertiButton" type="button" class="ImageButton" style="width: 20px;
            background: white url('../Images/view.png') no-repeat; height: 19px; margin-top: 5px;"
            onclick="CercaReparti(); return false;" />
        </div>
        <img id="loader" src="../Images/refresh.gif" style="display: none; float: left; margin-top: 7px;" />
      </div>
      <div class="separator">
      </div>
      <div id="listaRepartiRichiedenti" style="overflow-y: auto; height: 260px; margin: 0px;">
        <table id="selettoreGrid" class="tablesorter" style="border: 1px silver solid; border-collapse: collapse;
          width: 96%; margin-top: 5px;">
          <thead>
            <th style="text-align: center; width: 30px; padding: 0px;">
              <input type="checkbox" style="background: transparent; border-style: none; cursor: pointer;"
                onclick="SelectDeselectAll($(this), $('#selettoreGrid'));" />
            </th>
            <th>
              Azienda
            </th>
            <th>
              Sistema
            </th>
            <th>
              Codice
            </th>
            <th>
              Descrizione
            </th>
          </thead>
          <tbody>
          </tbody>
        </table>
      </div>
    </div>
  </div>
  <textarea id="rowTemplate" style="display: none;">
                        <tr id="{Id}" style="height: 25px;" class="GridItem">
                            <td style="text-align: center; padding: 0px;">
                                <input type="checkbox" class="gridCheckBox" />
                            </td>
                            <td style="text-align: center; width: 80px;">
                                {Azienda}
                            </td>
                            <td style="text-align: center;">
                                {Sistema}
                            </td>
                            <td style="text-align: center;">
                                {Codice}
                            </td>
                            <td style="text-align: center;">
                                {Descrizione}
                            </td>                            
                        </tr>
                    </textarea>
  <textarea id="selettoreTemplate" style="display: none;">
                        <tr id="{Id}" style="height: 25px;" class="GridItem newItem">
                            <td style="text-align: center; padding: 0px;">
                                <input type="checkbox" class="gridCheckBox" />
                            </td>
                            <td style="text-align: center; width: 80px;">
                                {Azienda}
                            </td>
                            <td style="text-align: center;">
                                {Sistema}
                            </td>
                             <td style="text-align: center;">
                                {Codice}
                            </td>
                            <td style="text-align: center;">
                                {Descrizione}
                            </td>
                        </tr>
                    </textarea>
  <script src="../Scripts/jquery.tablesorter.min.js" type="text/javascript"></script>
  <script src="../Scripts/abbonamenti-stampe-dettaglio.js" type="text/javascript"></script>
  <script type="text/javascript">

        
  </script>
  <style type="text/css">
    .filters select
    {
      width: 153px;
    }
    
    .filters div
    {
      float: left;
      width: 100px;
    }
    
    .filters div.separator
    {
      float: none;
      width: 100%;
      height: 1px;
      margin: 0px;
    }
  </style>
</asp:Content>

<%@ Page Title="Order Entry - Configurazione Ennuple" Language="vb" AutoEventWireup="false"
    MasterPageFile="~/OrderEntry.Master" CodeBehind="Accessi.aspx.vb" Inherits="DI.OrderEntry.Admin.Accessi" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder"
    runat="server">
    <h1>
        Accessi</h1>
    <div id="contenuto">
        <p>
            <span>I diritti di accesso specificano quali operazioni si possono eseguire e possono
                essere configurati a livello di singolo utente o gruppo e possono fare riferimento
                a un singolo sistema erogante.</span></p>
        <b>Utenti:</b><br />
        In questa sezione è possibile modificare la lista degli utenti codifiacti nell'Order
        Entry.
        <br />
        <br />
        <b>Gruppi di utenti:</b>
        <br />
        <span>Un gruppo è un insieme di utenti che hanno diritti comuni. Sono utilizzati esclusivamente
            nelle ennuple.</span>
        <br /><br />
        <b>Permessi:</b>
        <br />
        <span>I permessi specificano quali operazioni si possono eseguire e possono assumere
            i seguenti valori: </span>
        <ol>
            <li><span>Lettura</span></li>
            <li><span>Scrittura (preparazione dell’ordine)</span></li>
            <li><span>Inoltro (invio dell’ordine al sistema erogante)</span></li>
        </ol>
        <p>
            <span>Sono utilizzabili esclusivamente nelle ennuple.</span></p>
    </div>
</asp:Content>

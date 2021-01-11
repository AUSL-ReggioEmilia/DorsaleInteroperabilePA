<%@ Page Title="Order Entry - Configurazione Ennuple" Language="vb" AutoEventWireup="false"
	MasterPageFile="~/OrderEntry.Master" CodeBehind="Prestazioni.aspx.vb" Inherits="DI.OrderEntry.Admin.Prestazioni" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder"
	runat="server">
	<h1>Prestazioni</h1>
	<div id="contenuto">
		<b>Prestazioni:</b><br />
		In questa sezione è possibile modificare le prestazioni esistenti o aggiungerne
        di nuove e assegnare gli eventuali dati accessori.<br />
		<br />
		<b>Profili:</b><br />
		I Profili sono insiemi predefiniti di prestazioni. Possono essere di due tipi:<br />
		<ol>
			<li><span><em>Scomponibili</em>: possono essere scomposti e quindi utilizzati anche
                parzialmente</span></li>
			<li><span><em>Non scomponibili</em>: possono essere utilizzati solo nella loro interezza</span></li>
		</ol>
		<p>
			<span>I profili possono poi essere configurati a due livelli:</span>
		</p>
		<ol>
			<li><span><em>Personali</em>: configurati a livello d&#39;utente (possono essere solo
                scomponibili)</span></li>
			<li><span><em>Amministrativi</em>: configurati dagli amministratori e condivisi tra
                utenti</span></li>
		</ol>
		<p>
			<span>Un profilo amministrativo è un raggruppamento di prestazioni configurato tramite
                il portale amministrativo; può essere scomponibile o non scomponibile. </span>
		</p>
		<p>
			<span>Un profilo non scomponibile può essere utilizzato nella sua interezza; una volta
                selezionato ed aggiunto alla richiesta rimarrà visualizzato e salvato come tale
                fino al momento dell&#39;inoltro dell&#39;ordine. Durante la modifica potrà essere
                cancellato solo per intero. </span>
		</p>
		<p>
			<span>Un profilo scomponibile è invece utilizzabile per intero o anche parzialmente
                nelle singole prestazioni che lo compongono, può essere espanso anche durante la
                compilazione della richiesta, in modo che&nbsp; l&#39;utente possa ad esempio cancellare
                singole prestazioni dall&#39;ordine. Dopo tale operazione si perderà ogni riferimento
                al profilo e l&#39;ordine sarà composto solo dalle singole prestazioni.</span>
		</p>
		<p>
			<span>Ogni utente può definire un proprio profilo personalizzato e scomponibile sul
                portale delle richieste, mentre l&#39;amministratore all&#39;interno del portale
                amministrativo potrà definire dei profili condivisi utilizzandoli tramite le configurazioni
                delle ennuple.</span>
		</p>
		<b>Ruoli:</b>
		<br />
		<span>E&#39; un insieme di utenti che condividono hanno gli stessi diritti d&#39;accesso.
            Definiscono le unità operative di pertinenza (un ruolo può essere collegato a più
            Unità Operative).</span>
		<br />
		<br />
		<b>Gruppi di prestazioni:</b>
		<br />
		<span>E&#39; un insieme di prestazioni utilizzabile all&#39;interno delle ennuple.</span><br />
		<br />
		<b>Ennuple:</b>
		<br />
		<span>Le ennuple sono insiemi di configurazioni che hanno lo scopo di concedere o negare
            la richiesta di una prestazione per un determinato utente in un determinato momento.</span>
		<p>
			Se per il contesto della richiesta esiste una ennupla che &quot;corrisponde&quot;,
            allora la prestazione è erogabile; se la richiesta di una stessa prestazione è &quot;concessa&quot;
            in una ennupla e &quot;negata&quot; in un&#39;altra, allora sarà negata. Secondo
            la logica sopra definita è possibile estrarre, dato il contesto generale dell&#39;ordine
            e il sistema erogante, l&#39;elenco delle prestazioni erogabili.
		</p>
		<p>
			Una ennupla è composta dalle seguenti configurazioni:
            <ul>
							<li><span><em>Stato</em>: lo stato della ennupla, può assumere i valori abilitato, disabilitato,
                    simulazione (permette di simulare l&#39;esito nella sezione di simulazione)</span></li>
							<li>
								<span><em>Not</em>: permette di distinguere tra il “permesso” e il “negato”</span></li>
							<li>
								<span><em>Orario</em> <em>inizio</em>: l&#39;ora d&#39;inizio pertinenza dell&#39;ennupla</span></li>
							<li>
								<span><em>Orario fine</em>: l&#39;ora di fine pertinenza dell&#39;ennupla</span></li>
							<li>
								<span><em>Giorni</em>: i giorni pertinenza dell&#39;ennupla (ora inizio, ora fine e
                                        giorni fanno riferimento all&#39;intervallo orario in cui viene eseguita la richiesta)</span></li>
							<li>
								<span><em>Unità operativa:</em> l&#39;unità operativa a cui fa riferimento l&#39;ennupla,
                                                si riferisce all&#39;unità operativa dalla quale viene eseguita la richiesta</span>
							</li>
							<li><span><em>Gruppo utente:</em> il gruppo di utenti a cui fa riferimento l&#39;ennupla</span></li>
							<li>
								<span><em>Sistema richiedente</em>: il sistema richiedente a cui fa riferimento l&#39;ennupla</span></li>
							<li>
								<span><em>Regime</em>: il regime di ricovero del paziente per cui si sta eseguendo la
                            richiesta</span></li>
							<li><span><em>Priorità</em>: la priorità della richiesta</span>
							</li>
							<li><span><em>Gruppo di prestazioni</em>: il gruppo di prestazioni di pertinenza dell&#39;ennupla</span></li>
						</ul>
			<b>Simulazione ennuple:</b><br />
			In questa sezione è possibile testare le ennuple configurate ottenendo la lista
            delle prestazioni erogabili secondo i parametri specificati.<br />
			<br />
	</div>
</asp:Content>

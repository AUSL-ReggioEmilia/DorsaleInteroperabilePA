

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-11-21
-- Description:	Accesso alla lista dei dati aggiuntivi delle righe dei degli ordini
-- =============================================
CREATE VIEW [DataAccess].[OrdiniRigheRichiesteListaDatiAggiuntivi]
AS
	SELECT 
		  D.ID
		, D.IDRigaRichiesta
		, R.IDOrdineTestata
		, R.IDPrestazione

		--DatoAggiuntivo
		, D.Nome
		, D.TipoDato
		, D.TipoContenuto
		, D.ValoreDato
		, D.ValoreDatoVarchar
	FROM 
			dbo.OrdiniRigheRichiesteDatiAggiuntivi D WITH(NOLOCK) 
			INNER JOIN dbo.OrdiniRigheRichieste R WITH(NOLOCK) ON D.IDRigaRichiesta = R.ID


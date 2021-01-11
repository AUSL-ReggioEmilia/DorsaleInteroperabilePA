------------------------------
-- Modificta: 2015-02-13 Sandro: nuovi codici di ritorno da GetMinStatoErogatoTestateOrderEntry()
-- Modificta: 2017-09-27 Sandro: @statoErogato VARCHAR(4) invece di VARCHAR(MAX)
------------------------------
CREATE FUNCTION [dbo].[GetWsDescrizioneStato2]
	(@idOrdineTestata UNIQUEIDENTIFIER)
RETURNS VARCHAR (MAX)
AS
BEGIN
--Inserito = 0
--Inoltrato = 1
--Modificato = 2
--Cancellato = 3
--Accettato = 4
--Rifiutato = 5
--Errato = 6
--Incarico = 7
--Programmato = 8
--Erogato = 9
--Annullato = 10

	DECLARE @stato VARCHAR(4) -- HD, IN, SR, MD, CA
	SELECT @stato = StatoOrderEntry FROM dbo.OrdiniTestate WITH(NOLOCK) WHERE ID = @idOrdineTestata

	--Controllo operazione testata
	IF @stato = 'CA'
		RETURN 'Cancellato'

	IF @stato = 'HD'
		RETURN 'Inserito'

	IF @stato IN ('IN', 'SR', 'MD')
	BEGIN
		--Calcolo stato da Erogante
		DECLARE @statoErogato VARCHAR(4) = dbo.GetMinStatoErogatoTestateOrderEntry(@idOrdineTestata)

		IF @statoErogato = 'CA' RETURN 'Annullato'
		IF @statoErogato = 'CM' RETURN 'Erogato'
		IF @statoErogato = 'IP' RETURN 'Programmato'
		IF @statoErogato = 'IC' RETURN 'Incarico'

		IF @statoErogato = 'AA' RETURN 'Accettato'
		IF @statoErogato = 'SE' RETURN 'Accettato'
		IF @statoErogato = 'AR' RETURN 'Rifiutato'
		IF @statoErogato = 'AE' RETURN 'Errato'

		RETURN 'Inoltrato'
	END

	RETURN 'Inoltrato'
END

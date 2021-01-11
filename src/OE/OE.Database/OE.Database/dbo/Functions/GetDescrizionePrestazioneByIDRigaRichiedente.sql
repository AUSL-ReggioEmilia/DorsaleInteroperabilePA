







-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-03-09
-- Modify date: 2011-03-09
-- Description:	Ritorna la descrizione della prestazione
-- =============================================
CREATE FUNCTION [dbo].[GetDescrizionePrestazioneByIDRigaRichiedente](
	  @IDOrdineTestata uniqueidentifier
	, @IDRigaRichiedente varchar(64)
)

RETURNS varchar(256)

AS
BEGIN

	-- Descrizione per riga richiesta
	DECLARE @DescrizioneRR varchar(256)
	
	SELECT @DescrizioneRR = Prestazioni.Descrizione
	FROM Prestazioni 
		INNER JOIN  OrdiniRigheRichieste ON OrdiniRigheRichieste.IDPrestazione = Prestazioni.ID
	WHERE OrdiniRigheRichieste.IDOrdineTestata = @IDOrdineTestata AND OrdiniRigheRichieste.IDRigaRichiedente = @IDRigaRichiedente
		
	IF @DescrizioneRR = '[vuoto]' SET @DescrizioneRR = NULL
	
	
	-- Descrizione per riga erogata
	DECLARE @DescrizioneRE varchar(256)
	SELECT @DescrizioneRE = Prestazioni.Descrizione
	FROM Prestazioni 
		INNER JOIN OrdiniRigheErogate ON OrdiniRigheErogate.IDPrestazione = Prestazioni.ID
		INNER JOIN OrdiniErogatiTestate ON OrdiniRigheErogate.IDOrdineErogatoTestata = OrdiniErogatiTestate.ID
	WHERE OrdiniErogatiTestate.IDOrdineTestata = @IDOrdineTestata AND OrdiniRigheErogate.IDRigaRichiedente = @IDRigaRichiedente
	
	IF @DescrizioneRE = '[vuoto]' SET @DescrizioneRE = NULL

	-- Return	
	RETURN COALESCE(@DescrizioneRE, @DescrizioneRR)

END










-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE PROCEDURE [dbo].[RefertoDettaglio]
	@ID AS uniqueidentifier
AS

/****** Referto ************/

DECLARE @XmlReferto xml
	SET @XmlReferto = (
		SELECT Referto.Id,  Referto.AziendaErogante, 
			Referto.SistemaErogante, Referto.RepartoErogante, 
			Referto.DataReferto, Referto.NumeroReferto, 
			Referto.NumeroPrenotazione, Referto.NumeroNosologico,
			Referto.Cancellato, Referto.StatoRichiestaCodice,
			Referto.RepartoRichiedenteCodice, Referto.RepartoRichiedenteDescr,
			Attributo.Nome, Attributo.Valore
		FROM store.RefertiBase AS Referto INNER JOIN store.RefertiAttributi AS Attributo
			ON Referto.Id = Attributo.IdRefertiBase
		WHERE Referto.Id = @ID
		FOR XML AUTO, ELEMENTS
				)

DECLARE @xmlDoc int
	EXEC sp_xml_preparedocument @xmlDoc OUTPUT, @XmlReferto

/******* Join e Union dati ************/

	SELECT a.Nome, CONVERT(varchar(8000), b.Valore) AS Valore
	FROM (
		SELECT id, localname AS Nome
		FROM OPENXML (@xmlDoc, '/Referto', 1)
		WHERE parentid=0
		) a 
	INNER JOIN
		(
		SELECT parentid, [text] AS Valore
		FROM OPENXML (@xmlDoc, '/Referto', 1)
		WHERE parentid<>0 AND localname='#text'
		) b 
	ON a.id = b.parentid

	UNION

	SELECT Nome, Valore
	FROM OPENXML (@xmlDoc, '/Referto/Attributo', 2)
		WITH (Nome  varchar(32),
			  Valore varchar(8000))
	
	ORDER BY Nome

	EXEC sp_xml_removedocument @xmlDoc


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[RefertoDettaglio] TO [ExecuteFrontEnd]
    AS [dbo];


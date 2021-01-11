
CREATE VIEW [dbo].[PrescrizioniAllegati]
AS
/*
	Tutti gli ALLEGATI delle PRESCRIZIONI a livello di singlo STORE

	NUOVA SANDRO 2016-08-09
*/
	SELECT ID, DataPartizione
		, IdPrescrizioniBase, IdEsterno
		, DataInserimento, DataModifica
		, TipoContenuto
		, dbo.decompress(ContenutoCompresso) AS Contenuto

		, dbo.[GetPrescrizioniAllegatiAttributi2Xml](ID, DataPartizione) Attributi

	FROM [dbo].[PrescrizioniAllegatiBase]
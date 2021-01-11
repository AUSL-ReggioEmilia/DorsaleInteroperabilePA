

CREATE VIEW [DataAccess].[PrescrizioniHl7Testata]
/*
	CREATA DA SANDRO 2015-10-11: 
		Nuova vista ad uso esclusivo accesso ESTERNO

*/
AS
	SELECT Id, DataPartizione, TipoPrescrizione,  T.*
	FROM [store].[PrescrizioniBase] I WITH(NOLOCK)
		OUTER APPLY [dbo].[GetPrescrizioniHL7TestataPerIdPrescrizione](Id, DataPartizione) T
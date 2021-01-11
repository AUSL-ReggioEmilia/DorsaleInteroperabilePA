

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-11-03
-- Description:	Controlla se esiste una prescrizione 
--					usando come chiave @IdEsternoPrescrizione
-- =============================================
CREATE PROCEDURE [dbo].[ExtPrescrizioniEsiste](
  @IdEsternoPrescrizione			varchar (64)
-- Ritorna la PK del record inserito
, @IdPrescrizione					uniqueidentifier = NULL OUTPUT
, @DataPartizione					smalldatetime = NULL OUTPUT
, @DataModificaEsterno				datetime = NULL OUTPUT
) AS
BEGIN

	SET NOCOUNT ON

	------------------------------------------------------
	--  Cerco se esiste gia IdEsterno
	------------------------------------------------------	

	-- Join con la tabella perchè [GetPrescrizioniPk] usa NOLOCK
	SELECT @IdPrescrizione = PK.[ID], @DataPartizione = PK.[DataPartizione]
			,@DataModificaEsterno = PK.[DataModificaEsterno]
		FROM [store].[PrescrizioniBase] Prescrizioni
			INNER JOIN [dbo].[GetPrescrizioniPk](RTRIM(@IdEsternoPrescrizione)) PK
				ON PK.[ID] = Prescrizioni.Id
				AND PK.[DataPartizione] = Prescrizioni.[DataPartizione]

	SELECT DataModificaEsterno = @DataModificaEsterno
	RETURN 0
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtPrescrizioniEsiste] TO [ExecuteExt]
    AS [dbo];


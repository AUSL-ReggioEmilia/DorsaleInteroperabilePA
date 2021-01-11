
-- =============================================
-- Author:		ETTORE
-- Create date: 2020-10-21
-- Description:	Inserice nella tabella degli scartati i dati relativi ad IdSac (che si riferiscono ad anagrafiche ARA)
--				il cui aggiornamento è andato in errore
-- =============================================
CREATE PROCEDURE [ara_svc].[CodaAnagraficheDaAggiornareInputScartatiInserisce]
(
@DataProcessoUtc DATETIME
, @IdSequenza INT
, @IdSac UNIQUEIDENTIFIER
, @Motivo VARCHAR(1024)
)
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO ara_svc.CodaAnagraficheDaAggiornareInputScartati
		(DataProcessoUtc , IdSequenza, IdSac, Motivo) 
	VALUES 
		(@DataProcessoUtc , @IdSequenza, @IdSac, @Motivo) 
END